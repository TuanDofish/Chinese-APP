import {
  Injectable,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import { DataSource } from 'typeorm';

type GrammarError = {
  type: string;
  explanation: string;
  fix?: string;
};

type GrammarSuggestion = {
  cn: string;
  py: string;
  vi: string;
};

type GrammarResult = {
  score: number;
  isCorrect: boolean;
  summary: string;
  errors: GrammarError[];
  correction: {
    cn: string;
    py: string;
    vi: string;
  };
  suggestions: GrammarSuggestion[];
  style_tips: string;
  source: 'gemini' | 'gemini-recovered' | 'validation';
  provider: string;
  model: string;
};

@Injectable()
export class AppService {
  private readonly logger = new Logger(AppService.name);
  private aiRuntime = {
    grammarUsable: null as boolean | null,
    status: 'not_checked',
    lastCheckedAt: null as string | null,
    lastErrorCategory: '',
  };

  constructor(private readonly dataSource: DataSource) {}

  private profile = {
    name: 'Người học VNChinese',
    level: 'HSK 2',
    streakDays: 0,
    weeklyProgress: 0,
    savedWords: 0,
    speakingScore: 0,
    readingArticles: 0,
    dailyGoalWords: 18,
    dailyGoalMinutes: 25,
    reminderTime: '20:30',
    storage: 'Thiết bị hiện tại',
  };

  getHello(): string {
    return 'VNChinese API is running';
  }

  getHealth() {
    const apiKey =
      process.env.GEMINI_API_KEY || process.env.GOOGLE_API_KEY || '';
    const hasKey = Boolean(apiKey);
    const keyLooksValid = this.looksLikeGoogleApiKey(apiKey);
    return {
      status: 'ok',
      service: 'VNChinese API',
      timestamp: new Date().toISOString(),
      ai: {
        configured: hasKey,
        keyFormat: keyLooksValid ? 'valid-pattern' : 'unknown',
        provider: this.geminiProvider(apiKey),
        model: process.env.GEMINI_MODEL || 'automatic',
        usable: !hasKey || !keyLooksValid ? false : this.aiRuntime.grammarUsable,
        status: !hasKey
          ? 'missing_key'
          : !keyLooksValid
            ? 'invalid_key_format'
            : this.aiRuntime.status,
        lastCheckedAt: this.aiRuntime.lastCheckedAt,
        lastErrorCategory: this.aiRuntime.lastErrorCategory,
      },
    };
  }

  async checkGrammar(text: string): Promise<GrammarResult> {
    const requestId = this.newRequestId('grammar');
    const startedAt = Date.now();
    const sentence = text.trim();
    this.logAction('ai.grammar.received', {
      requestId,
      textLength: sentence.length,
      preview: this.preview(sentence),
    });

    if (!sentence) {
      this.logAction('ai.grammar.validation_failed', {
        requestId,
        reason: 'empty_text',
      });
      return {
        score: 0,
        isCorrect: false,
        summary: 'Chưa có câu để kiểm tra.',
        errors: [
          {
            type: 'Thiếu dữ liệu',
            explanation: 'Hãy nhập một câu tiếng Trung trước khi kiểm tra.',
          },
        ],
        correction: { cn: '', py: '', vi: '' },
        suggestions: [],
        style_tips: 'Ví dụ: 我想去中国。',
        source: 'validation',
        provider: 'VNChinese API',
        model: 'none',
      };
    }

    const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_API_KEY;
    if (!apiKey) {
      this.setAiRuntime(false, 'missing_key', 'missing_api_key');
      this.logAction(
        'ai.grammar.config_error',
        { requestId, reason: 'missing_api_key' },
        'warn',
      );
      throw new ServiceUnavailableException(
        'Backend chưa được cấu hình GEMINI_API_KEY hoặc GOOGLE_API_KEY.',
      );
    }
    if (!this.looksLikeGoogleApiKey(apiKey)) {
      this.setAiRuntime(false, 'invalid_key_format', 'invalid_api_key_pattern');
      this.logAction(
        'ai.grammar.config_error',
        { requestId, reason: 'invalid_api_key_pattern' },
        'warn',
      );
      throw new ServiceUnavailableException(
        'GEMINI_API_KEY không đúng định dạng Google AI Studio (AIza...) hoặc Vertex AI Express Mode (AQ...).',
      );
    }
    const provider = this.geminiProvider(apiKey);

    const models = this.geminiCandidateModels();
    this.logAction('ai.grammar.start', {
      requestId,
      provider,
      models,
    });

    const prompt = [
      'Bạn là giáo viên tiếng Trung cho người Việt.',
      'Hãy chấm câu nghiêm túc về ngữ pháp, trật tự từ, từ loại, ngữ nghĩa và độ tự nhiên.',
      'Nếu câu sai, sửa thành câu đúng và giữ ý gần nhất với người học.',
      'Nếu câu mơ hồ hoặc vô nghĩa, phải giải thích rõ bằng tiếng Việt.',
      'Không cho điểm cao nếu câu thiếu động từ, sai phủ định, sai bổ ngữ hoặc sai trật tự.',
      'Nếu correction.cn khác đáng kể với câu gốc, score phải dưới 80.',
      'Pinyin phải có dấu thanh đầy đủ.',
      'Chỉ nêu tối đa 2 lỗi chính và tối đa 2 gợi ý, viết ngắn gọn.',
      'Chỉ trả về JSON hợp lệ, không dùng markdown.',
      'Schema:',
      '{"score": number, "isCorrect": boolean, "summary": string, "errors": [{"type": string, "explanation": string, "fix": string}], "correction": {"cn": string, "py": string, "vi": string}, "suggestions": [{"cn": string, "py": string, "vi": string}], "style_tips": string}',
      'Ví dụ: 我不学校去学习 là câu sai; cần chỉ rõ lỗi phủ định và trật tự từ.',
      `Câu cần kiểm tra: ${sentence}`,
    ].join('\n');

    let lastError = 'Gemini không phản hồi.';
    let lastRecoveredResult: GrammarResult | null = null;
    for (const model of models) {
      const modelStartedAt = Date.now();
      try {
        this.logAction('ai.grammar.model_attempt', {
          requestId,
          provider,
          model,
        });
        const response = await fetch(this.geminiEndpoint(apiKey, model), {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey.trim(),
          },
          body: JSON.stringify({
            contents: [{ role: 'user', parts: [{ text: prompt }] }],
            generationConfig: {
              temperature: 0.12,
              topP: 0.75,
              maxOutputTokens: 1800,
              responseMimeType: 'application/json',
            },
          }),
          signal: AbortSignal.timeout(18000),
        });

        if (response.status === 404) {
          lastError = `Model ${model} không khả dụng.`;
          this.logAction(
            'ai.grammar.model_unavailable',
            {
              requestId,
              provider,
              model,
              status: response.status,
              durationMs: Date.now() - modelStartedAt,
            },
            'warn',
          );
          continue;
        }

        if (!response.ok) {
          const body = await response.text();
          lastError = this.describeGeminiError(response.status, body);
          this.setAiRuntime(
            false,
            this.aiRuntimeStatusFromGemini(response.status, body),
            this.geminiErrorStatus(body) || `http_${response.status}`,
          );
          this.logAction(
            'ai.grammar.model_error',
            {
              requestId,
              provider,
              model,
              status: response.status,
              geminiStatus: this.geminiErrorStatus(body),
              message: this.compactError(lastError),
              durationMs: Date.now() - modelStartedAt,
            },
            response.status >= 500 ? 'warn' : 'error',
          );
          if (this.shouldTryNextModel(response.status)) continue;
          break;
        }

        const data = (await response.json()) as any;
        const content =
          data?.candidates?.[0]?.content?.parts
            ?.map((part: { text?: string }) => part.text ?? '')
            .join('') ?? '';
        const result = this.normalizeGrammarResult(
          content,
          sentence,
          model,
          provider,
        );
        if (result.source === 'gemini-recovered') {
          lastRecoveredResult = result;
          lastError = 'Gemini trả về JSON chưa hoàn chỉnh.';
          this.logAction(
            'ai.grammar.parse_recovered',
            {
              requestId,
              provider,
              model,
              score: result.score,
              durationMs: Date.now() - modelStartedAt,
            },
            'warn',
          );
          continue;
        }
        this.logAction('ai.grammar.success', {
          requestId,
          provider,
          model,
          score: result.score,
          source: result.source,
          durationMs: Date.now() - startedAt,
        });
        this.setAiRuntime(true, 'usable', '');
        await this.saveAiInteraction({
          type: 'GRAMMAR_CHECK',
          input: sentence,
          response: result.summary,
          score: result.score,
          responseJson: result,
          provider,
          model,
          status: 'SUCCESS',
          durationMs: Date.now() - startedAt,
        });
        return result;
      } catch (error) {
        lastError =
          error instanceof Error
            ? `Không gọi được Gemini: ${error.message}`
            : String(error);
        this.setAiRuntime(false, 'network_or_runtime_error', 'exception');
        this.logAction(
          'ai.grammar.exception',
          {
            requestId,
            provider,
            model,
            message: this.compactError(lastError),
            durationMs: Date.now() - modelStartedAt,
          },
          'error',
        );
      }
    }

    if (lastRecoveredResult) {
      this.setAiRuntime(true, 'usable_recovered', '');
      await this.saveAiInteraction({
        type: 'GRAMMAR_CHECK',
        input: sentence,
        response: lastRecoveredResult.summary,
        score: lastRecoveredResult.score,
        responseJson: lastRecoveredResult,
        provider,
        model: lastRecoveredResult.model,
        status: 'SUCCESS',
        durationMs: Date.now() - startedAt,
      });
      return lastRecoveredResult;
    }

    this.logAction(
      'ai.grammar.failed',
      {
        requestId,
        provider,
        message: this.compactError(lastError),
        durationMs: Date.now() - startedAt,
      },
      'error',
    );
    await this.saveAiInteraction({
      type: 'GRAMMAR_CHECK',
      input: sentence,
      provider,
      status: 'ERROR',
      errorCode: 'GEMINI_UNAVAILABLE',
      errorMessage: lastError,
      durationMs: Date.now() - startedAt,
    });
    throw new ServiceUnavailableException(lastError);
  }

  private setAiRuntime(
    usable: boolean,
    status: string,
    lastErrorCategory: string,
  ) {
    this.aiRuntime = {
      grammarUsable: usable,
      status,
      lastCheckedAt: new Date().toISOString(),
      lastErrorCategory,
    };
  }

  async chat(
    message: string,
    level: string,
    history: { role?: string; text?: string }[],
  ) {
    const requestId = this.newRequestId('chat');
    const startedAt = Date.now();
    const cleanMessage = message.trim();
    this.logAction('ai.chat.received', {
      requestId,
      level,
      textLength: cleanMessage.length,
      historyCount: Array.isArray(history) ? history.length : 0,
      preview: this.preview(cleanMessage),
    });

    if (!cleanMessage) {
      this.logAction('ai.chat.validation_failed', {
        requestId,
        reason: 'empty_message',
      });
      return { reply: 'Bạn muốn luyện nội dung nào?' };
    }
    const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_API_KEY;
    if (!apiKey || !this.looksLikeGoogleApiKey(apiKey)) {
      this.logAction(
        'ai.chat.config_error',
        {
          requestId,
          reason: !apiKey ? 'missing_api_key' : 'invalid_api_key_pattern',
        },
        'warn',
      );
      throw new ServiceUnavailableException(
        'Chat AI chưa sẵn sàng vì Gemini API key chưa hợp lệ.',
      );
    }
    const provider = this.geminiProvider(apiKey);
    const models = this.geminiCandidateModels();
    this.logAction('ai.chat.start', {
      requestId,
      provider,
      models,
    });

    const recent = history
      .slice(-8)
      .map(
        (item) =>
          `${item.role === 'assistant' ? 'Gia sư' : 'Học viên'}: ${item.text ?? ''}`,
      )
      .join('\n');
    const prompt = [
      'Bạn là gia sư tiếng Trung VNChinese cho người Việt.',
      `Trình độ hiện tại của học viên: ${level}.`,
      'Trả lời ngắn gọn, thân thiện và chính xác.',
      'Khi đưa câu tiếng Trung, luôn kèm pinyin có dấu và nghĩa tiếng Việt.',
      'Nếu học viên viết sai, giải thích lỗi và cho một bài luyện ngắn.',
      'Không bịa nguồn tin, không tự chấm điểm phát âm khi không có âm thanh.',
      recent ? `Hội thoại gần đây:\n${recent}` : '',
      `Học viên: ${cleanMessage}`,
    ]
      .filter(Boolean)
      .join('\n\n');

    let lastError = 'Gemini không phản hồi.';
    for (const model of models) {
      const modelStartedAt = Date.now();
      try {
        this.logAction('ai.chat.model_attempt', {
          requestId,
          provider,
          model,
        });
        const response = await fetch(this.geminiEndpoint(apiKey, model), {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey.trim(),
          },
          body: JSON.stringify({
            contents: [{ role: 'user', parts: [{ text: prompt }] }],
            generationConfig: { temperature: 0.45, maxOutputTokens: 900 },
          }),
          signal: AbortSignal.timeout(18000),
        });

        if (response.status === 404) {
          lastError = `Model ${model} không khả dụng.`;
          this.logAction(
            'ai.chat.model_unavailable',
            {
              requestId,
              provider,
              model,
              status: response.status,
              durationMs: Date.now() - modelStartedAt,
            },
            'warn',
          );
          continue;
        }

        if (!response.ok) {
          const body = await response.text();
          lastError = this.describeGeminiError(response.status, body);
          this.logAction(
            'ai.chat.model_error',
            {
              requestId,
              provider,
              model,
              status: response.status,
              geminiStatus: this.geminiErrorStatus(body),
              message: this.compactError(lastError),
              durationMs: Date.now() - modelStartedAt,
            },
            response.status >= 500 ? 'warn' : 'error',
          );
          if (this.shouldTryNextModel(response.status)) continue;
          break;
        }

        const data = (await response.json()) as any;
        const reply =
          data?.candidates?.[0]?.content?.parts
            ?.map((part: { text?: string }) => part.text ?? '')
            .join('')
            .trim() ?? '';
        this.logAction('ai.chat.success', {
          requestId,
          provider,
          model,
          replyLength: reply.length,
          durationMs: Date.now() - startedAt,
        });
        await this.saveAiInteraction({
          type: 'TUTOR_CHAT',
          input: cleanMessage,
          response: reply,
          responseJson: { level, historyCount: history.length },
          provider,
          model,
          status: 'SUCCESS',
          durationMs: Date.now() - startedAt,
        });
        return { reply, provider, model };
      } catch (error) {
        lastError =
          error instanceof Error
            ? `Không gọi được Gemini: ${error.message}`
            : String(error);
        this.logAction(
          'ai.chat.exception',
          {
            requestId,
            provider,
            model,
            message: this.compactError(lastError),
            durationMs: Date.now() - modelStartedAt,
          },
          'error',
        );
      }
    }

    this.logAction(
      'ai.chat.failed',
      {
        requestId,
        provider,
        message: this.compactError(lastError),
        durationMs: Date.now() - startedAt,
      },
      'error',
    );
    await this.saveAiInteraction({
      type: 'TUTOR_CHAT',
      input: cleanMessage,
      provider,
      status: 'ERROR',
      errorCode: 'GEMINI_UNAVAILABLE',
      errorMessage: lastError,
      durationMs: Date.now() - startedAt,
    });
    throw new ServiceUnavailableException(lastError);
  }

  getProfile() {
    return this.profile;
  }

  updateGoal(body: { level?: string; words?: number; minutes?: number }) {
    this.profile = {
      ...this.profile,
      level: body.level || this.profile.level,
      dailyGoalWords: Number(body.words) || this.profile.dailyGoalWords,
      dailyGoalMinutes: Number(body.minutes) || this.profile.dailyGoalMinutes,
    };
    return this.profile;
  }

  getFlashcardImageSuggestion(q: string, meaning: string) {
    const keyword = [q, meaning].filter(Boolean).join(' ').trim();
    return {
      provider: 'local-flat-icon',
      keyword,
      style: 'rounded flat vector, bright, simple object, no text',
      flaticonSearchUrl: `https://www.flaticon.com/search?word=${encodeURIComponent(keyword)}`,
      note: 'Chỉ dùng ảnh có giấy phép phù hợp trong app.',
    };
  }

  scorePronunciation(
    target: string,
    recognized: string,
    meta: { targetPinyin?: string; lessonId?: string; lineIndex?: number } = {},
  ) {
    const requestId = this.newRequestId('pronunciation');
    const cleanTarget = this.normalizePronunciationText(target);
    const cleanRecognized = this.normalizePronunciationText(recognized);
    const targetPinyin = this.normalizePinyinText(meta.targetPinyin ?? '');
    const recognizedPinyin = this.hanziToPinyin(cleanRecognized);

    let score = 0;
    let matchedUnits = 0;
    let hanziSimilarity = 0;
    let pinyinSimilarity = 0;
    let lengthRatio = 0;
    if (cleanTarget && cleanRecognized) {
      matchedUnits = this.lcsLength(cleanTarget, cleanRecognized);
      hanziSimilarity = matchedUnits / cleanTarget.length;
      lengthRatio =
        Math.min(cleanTarget.length, cleanRecognized.length) /
        Math.max(cleanTarget.length, cleanRecognized.length);
      const hanziScore = Math.round(
        hanziSimilarity * 100 * (0.82 + lengthRatio * 0.18),
      );
      if (targetPinyin && recognizedPinyin) {
        const pinyinMatches = this.lcsLength(targetPinyin, recognizedPinyin);
        pinyinSimilarity = pinyinMatches / targetPinyin.length;
      }
      const phoneticScore = Math.round(
        pinyinSimilarity * 100 * (0.72 + lengthRatio * 0.18),
      );
      score = Math.max(hanziScore, phoneticScore);
    }
    score = Math.max(0, Math.min(100, score));

    const result = {
      score,
      feedback: this.pronunciationFeedback(score, cleanRecognized.length > 0),
      target,
      recognized,
      source: 'api-local-scorer',
      requestId,
      detail: {
        lessonId: meta.lessonId ?? '',
        lineIndex: Number.isFinite(meta.lineIndex) ? meta.lineIndex : null,
        targetUnits: cleanTarget.length,
        recognizedUnits: cleanRecognized.length,
        matchedUnits,
        targetPinyin,
        recognizedPinyin,
        hanziSimilarity: Number(hanziSimilarity.toFixed(3)),
        pinyinSimilarity: Number(pinyinSimilarity.toFixed(3)),
        lengthRatio: Number(lengthRatio.toFixed(3)),
        method: 'speech-to-text + hanzi LCS + pinyin similarity',
      },
    };

    this.logAction('pronunciation.score.completed', {
      requestId,
      score,
      targetLength: cleanTarget.length,
      recognizedLength: cleanRecognized.length,
      lessonId: meta.lessonId ?? '',
      lineIndex: meta.lineIndex ?? null,
    });
    return result;
  }

  private normalizePronunciationText(value: string) {
    const normalized = String(value ?? '').normalize('NFKC');
    const han = normalized.replace(/[^\u4e00-\u9fff]/g, '');
    if (han) return han;
    return normalized
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '');
  }

  private normalizePinyinText(value: string) {
    return String(value ?? '')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .replace(/ü/g, 'v')
      .replace(/[^a-z0-9]+/g, '');
  }

  private hanziToPinyin(value: string) {
    const map: Record<string, string> = {
      你: 'ni',
      好: 'hao',
      谢: 'xie',
      我: 'wo',
      是: 'shi',
      不: 'bu',
      去: 'qu',
      学: 'xue',
      习: 'xi',
      汉: 'han',
      语: 'yu',
      吃: 'chi',
      饭: 'fan',
      米: 'mi',
      饺: 'jiao',
      叫: 'jiao',
      咀: 'ju',
      子: 'zi',
      者: 'zhe',
      桌: 'zhuo',
      椅: 'yi',
      包: 'bao',
      水: 'shui',
      茶: 'cha',
      苹: 'ping',
      果: 'guo',
      老: 'lao',
      师: 'shi',
      生: 'sheng',
      朋: 'peng',
      友: 'you',
      天: 'tian',
      气: 'qi',
      热: 're',
      冷: 'leng',
      雨: 'yu',
      雪: 'xue',
      风: 'feng',
      家: 'jia',
      爸: 'ba',
      妈: 'ma',
      狗: 'gou',
      猫: 'mao',
      红: 'hong',
      色: 'se',
      飞: 'fei',
      机: 'ji',
      眼: 'yan',
      睛: 'jing',
      工: 'gong',
      作: 'zuo',
      经: 'jing',
      济: 'ji',
      喜: 'xi',
      欢: 'huan',
      中: 'zhong',
      国: 'guo',
    };
    return [...value].map((char) => map[char] ?? '').join('');
  }

  private lcsLength(a: string, b: string) {
    const previous = new Array(b.length + 1).fill(0);
    const current = new Array(b.length + 1).fill(0);
    for (let i = 1; i <= a.length; i++) {
      for (let j = 1; j <= b.length; j++) {
        current[j] =
          a[i - 1] === b[j - 1]
            ? previous[j - 1] + 1
            : Math.max(previous[j], current[j - 1]);
      }
      for (let j = 0; j <= b.length; j++) previous[j] = current[j];
    }
    return previous[b.length];
  }

  private pronunciationFeedback(score: number, hasRecognizedText: boolean) {
    if (!hasRecognizedText) {
      return 'Máy chưa nhận được giọng đọc. Hãy đưa micro gần hơn và thử lại.';
    }
    if (score >= 90) return 'Rất tốt. Nhịp đọc và âm chính khá sát câu mẫu.';
    if (score >= 75) return 'Tốt. Hãy đọc chậm hơn một chút để rõ từng âm.';
    if (score >= 55) return 'Tạm ổn. Nên nghe lại câu mẫu rồi nhại từng cụm.';
    return 'Cần luyện lại. Hãy bấm nghe câu mẫu trước khi ghi âm lần nữa.';
  }

  private looksLikeGoogleApiKey(value: string) {
    const key = value.trim();
    return (
      /^AIza[0-9A-Za-z_-]{20,}$/.test(key) ||
      /^AQ\.[0-9A-Za-z._-]{20,}$/.test(key)
    );
  }

  private geminiProvider(apiKey: string) {
    return apiKey.trim().startsWith('AQ.')
      ? 'Google Vertex AI Express Mode'
      : 'Google Gemini API';
  }

  private geminiEndpoint(apiKey: string, model: string) {
    const key = apiKey.trim();
    // generativelanguage.googleapis.com works for both AIza... and AQ. keys
    // without requiring Vertex AI API enabled or billing
    return `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(key)}`;
  }

  private geminiCandidateModels() {
    return [
      process.env.GEMINI_MODEL,
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-1.5-flash',
    ]
      .filter((model): model is string => Boolean(model))
      .filter((model, index, all) => all.indexOf(model) === index);
  }

  private shouldTryNextModel(status: number) {
    return status === 404 || status === 429 || status >= 500;
  }

  private describeGeminiError(status: number, body: string) {
    if (status === 400) {
      return 'Gemini từ chối yêu cầu. Hãy kiểm tra API key, model và quyền Generative Language API.';
    }
    if (status === 401 || status === 403) {
      if (
        body.includes('SERVICE_DISABLED') &&
        body.includes('aiplatform.googleapis.com')
      ) {
        return 'Khóa Vertex AI đã được nhận diện nhưng project chưa bật Vertex AI API. Hãy bật aiplatform.googleapis.com trong Google Cloud Console, đợi vài phút rồi thử lại.';
      }
      return 'Gemini không chấp nhận API key hoặc key chưa được cấp quyền.';
    }
    if (status === 429) {
      return 'Gemini đã vượt hạn mức hoặc đang giới hạn tần suất. Hãy kiểm tra quota.';
    }
    if (status === 503) {
      return 'Gemini đang quá tải tạm thời (503 UNAVAILABLE). Backend đã thử model dự phòng nếu có; hãy thử lại sau vài phút.';
    }
    return `Gemini API lỗi ${status}: ${body.slice(0, 240)}`;
  }

  private aiRuntimeStatusFromGemini(status: number, body: string) {
    const geminiStatus = this.geminiErrorStatus(body);
    if (geminiStatus === 'SERVICE_DISABLED') return 'service_disabled';
    if (status === 401 || status === 403) return 'permission_error';
    if (status === 429) return 'quota_error';
    if (status === 404) return 'model_unavailable';
    if (status === 503) return 'provider_unavailable';
    return `gemini_http_${status}`;
  }

  private geminiErrorStatus(body: string) {
    try {
      const parsed = JSON.parse(body) as {
        error?: { status?: string; message?: string };
      };
      return parsed.error?.status || '';
    } catch {
      return '';
    }
  }

  private newRequestId(prefix: string) {
    return `${prefix}_${Date.now().toString(36)}_${Math.random()
      .toString(36)
      .slice(2, 8)}`;
  }

  private preview(value: string) {
    return value.replace(/\s+/g, ' ').trim().slice(0, 80);
  }

  private compactError(value: string) {
    return value.replace(/\s+/g, ' ').trim().slice(0, 320);
  }

  private logAction(
    action: string,
    meta: Record<string, unknown>,
    level: 'log' | 'warn' | 'error' = 'log',
  ) {
    const payload = {
      action,
      at: new Date().toISOString(),
      ...meta,
    };
    const line = JSON.stringify(payload);
    if (level === 'error') this.logger.error(line);
    else if (level === 'warn') this.logger.warn(line);
    else this.logger.log(line);
  }

  private async saveAiInteraction(input: {
    type: 'GRAMMAR_CHECK' | 'TUTOR_CHAT';
    input: string;
    response?: string;
    score?: number;
    responseJson?: unknown;
    provider: string;
    model?: string;
    status: 'SUCCESS' | 'ERROR';
    httpStatus?: number;
    errorCode?: string;
    errorMessage?: string;
    durationMs: number;
  }) {
    try {
      await this.dataSource.query(
        `INSERT INTO ai_interactions
          (interaction_type, input_text, response_text, score, response_json,
           provider, model, status, http_status, error_code, error_message,
           duration_ms)
         VALUES ($1::ai_interaction_type, $2, $3, $4, $5::jsonb, $6, $7,
                 $8::ai_status, $9, $10, $11, $12)`,
        [
          input.type,
          input.input,
          input.response || null,
          input.score ?? null,
          JSON.stringify(input.responseJson || {}),
          input.provider,
          input.model || null,
          input.status,
          input.httpStatus || null,
          input.errorCode || null,
          input.errorMessage || null,
          input.durationMs,
        ],
      );
    } catch (error) {
      this.logger.error(
        JSON.stringify({
          action: 'ai.database_log_failed',
          at: new Date().toISOString(),
          message: error instanceof Error ? error.message : String(error),
        }),
      );
    }
  }

  private normalizeGrammarResult(
    raw: string,
    original: string,
    model: string,
    provider: string,
  ): GrammarResult {
    const jsonText = raw
      .trim()
      .replace(/^```json/i, '')
      .replace(/^```/, '')
      .replace(/```$/, '')
      .trim();
    const extracted = this.extractJsonObject(jsonText);
    const candidates = [
      jsonText,
      extracted,
      extracted.replace(/,\s*([}\]])/g, '$1'),
    ].filter((value, index, all) => value && all.indexOf(value) === index);
    let parsed: Partial<GrammarResult> | null = null;
    for (const candidate of candidates) {
      try {
        parsed = JSON.parse(candidate) as Partial<GrammarResult>;
        break;
      } catch {
        // Try the next repair candidate.
      }
    }
    if (!parsed) {
      const recoveredScore = this.recoverNumber(jsonText, 'score');
      return {
        score: recoveredScore,
        isCorrect:
          this.recoverBoolean(jsonText, 'isCorrect') ?? recoveredScore >= 85,
        summary:
          this.recoverJsonString(jsonText, 'summary') ||
          'AI đã chấm nhưng phản hồi bị thiếu một phần.',
        errors: [
          {
            type: 'Phản hồi AI chưa hoàn chỉnh',
            explanation:
              'Backend đã khôi phục phần điểm và câu sửa đọc được từ Gemini.',
            fix: 'Có thể kiểm tra lại để nhận phần giải thích đầy đủ hơn.',
          },
        ],
        correction: {
          cn: this.recoverJsonString(jsonText, 'cn') || original,
          py: this.recoverJsonString(jsonText, 'py'),
          vi: this.recoverJsonString(jsonText, 'vi'),
        },
        suggestions: [],
        style_tips: this.recoverJsonString(jsonText, 'style_tips'),
        source: 'gemini-recovered',
        provider,
        model,
      };
    }

    const score = Math.max(
      0,
      Math.min(100, Math.round(Number(parsed.score ?? 0))),
    );
    return {
      score,
      isCorrect: Boolean(parsed.isCorrect ?? score >= 85),
      summary: String(parsed.summary ?? ''),
      errors: Array.isArray(parsed.errors)
        ? parsed.errors.map((error: any) => ({
            type: String(error?.type ?? 'Góp ý'),
            explanation: String(error?.explanation ?? error?.message ?? ''),
            fix: error?.fix ? String(error.fix) : undefined,
          }))
        : [],
      correction: {
        cn: String(parsed.correction?.cn ?? original),
        py: String(parsed.correction?.py ?? ''),
        vi: String(parsed.correction?.vi ?? ''),
      },
      suggestions: this.normalizeSuggestions(parsed.suggestions),
      style_tips: String(parsed.style_tips ?? ''),
      source: 'gemini',
      provider,
      model,
    };
  }

  private extractJsonObject(value: string) {
    const start = value.indexOf('{');
    const end = value.lastIndexOf('}');
    return start >= 0 && end > start ? value.slice(start, end + 1) : value;
  }

  private recoverNumber(value: string, key: string) {
    const match = value.match(
      new RegExp(`"${key}"\\s*:\\s*(-?\\d+(?:\\.\\d+)?)`),
    );
    const parsed = match ? Number(match[1]) : 0;
    return Math.max(0, Math.min(100, Math.round(parsed)));
  }

  private recoverBoolean(value: string, key: string) {
    const match = value.match(new RegExp(`"${key}"\\s*:\\s*(true|false)`, 'i'));
    return match ? match[1].toLowerCase() === 'true' : null;
  }

  private recoverJsonString(value: string, key: string) {
    const match = value.match(
      new RegExp(`"${key}"\\s*:\\s*("(?:\\\\.|[^"\\\\])*")`),
    );
    if (!match) return '';
    try {
      return String(JSON.parse(match[1]));
    } catch {
      return '';
    }
  }

  private normalizeSuggestions(raw: unknown): GrammarSuggestion[] {
    if (!Array.isArray(raw)) return [];
    return raw.slice(0, 4).map((item) => {
      if (typeof item === 'string') return { cn: item, py: '', vi: '' };
      const suggestion = item as Record<string, unknown>;
      return {
        cn: String(suggestion.cn ?? suggestion.chinese ?? ''),
        py: String(suggestion.py ?? suggestion.pinyin ?? ''),
        vi: String(
          suggestion.vi ?? suggestion.meaning ?? suggestion.note ?? '',
        ),
      };
    });
  }
}

import { Injectable, ServiceUnavailableException } from '@nestjs/common';

type GrammarError = {
  type: string;
  explanation: string;
  fix?: string;
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
  suggestions: string[];
  style_tips: string;
};

@Injectable()
export class AppService {
  private profile = {
    name: 'Người học VNChinese',
    level: 'HSK 2',
    streakDays: 12,
    weeklyProgress: 0.68,
    savedWords: 42,
    speakingScore: 91,
    readingArticles: 4,
    dailyGoalWords: 18,
    dailyGoalMinutes: 25,
    reminderTime: '20:30',
    storage: 'Thiết bị hiện tại',
  };

  getHello(): string {
    return 'VNChinese API is running';
  }

  async checkGrammar(text: string): Promise<GrammarResult> {
    const sentence = text.trim();
    if (!sentence) {
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
        style_tips: 'Nhập câu bằng Hán tự, ví dụ: 我想去中国。',
      };
    }

    const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_API_KEY;
    if (!apiKey) {
      throw new ServiceUnavailableException(
        'Missing GEMINI_API_KEY or GOOGLE_API_KEY',
      );
    }

    const model = process.env.GEMINI_MODEL || 'gemini-3.5-flash';
    const prompt = [
      'Bạn là giáo viên tiếng Trung cho người Việt.',
      'Hãy kiểm tra câu tiếng Trung của người học thật nghiêm túc.',
      'Nếu câu sai, sửa thành câu đúng ngữ pháp và giữ nghĩa gần nhất với ý người học.',
      'Nếu câu mơ hồ, nêu rõ phần mơ hồ và đưa câu tự nhiên nhất.',
      'Không cho điểm cao nếu câu thiếu động từ, sai trật tự từ, sai bổ ngữ hoặc thiếu thành phần câu.',
      'Nếu correction.cn khác câu gốc đáng kể, score phải dưới 80.',
      'Trả lời duy nhất bằng JSON hợp lệ, không markdown.',
      'Schema:',
      '{"score": number 0-100, "isCorrect": boolean, "summary": string, "errors": [{"type": string, "explanation": string, "fix": string}], "correction": {"cn": string, "py": string, "vi": string}, "suggestions": string[], "style_tips": string}',
      `Câu cần kiểm tra: ${sentence}`,
    ].join('\n');

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: JSON.stringify({
          contents: [{ role: 'user', parts: [{ text: prompt }] }],
          generationConfig: {
            temperature: 0.15,
            topP: 0.8,
            responseMimeType: 'application/json',
          },
        }),
      },
    );

    if (!response.ok) {
      const body = await response.text();
      throw new ServiceUnavailableException(
        `Gemini API error ${response.status}: ${body}`,
      );
    }

    const data = (await response.json()) as any;
    const content =
      data?.candidates?.[0]?.content?.parts
        ?.map((part: { text?: string }) => part.text ?? '')
        .join('') ?? '';
    return this.normalizeGrammarResult(content, sentence);
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
      note: 'Flaticon cần tài khoản/giấy phép để dùng trực tiếp. App đang dùng minh họa vector nội bộ và có thể thay bằng asset/API ảnh có license.',
    };
  }

  private normalizeGrammarResult(raw: string, original: string): GrammarResult {
    const jsonText = raw
      .trim()
      .replace(/^```json/i, '')
      .replace(/^```/, '')
      .replace(/```$/, '')
      .trim();
    let parsed: Partial<GrammarResult>;
    try {
      parsed = JSON.parse(jsonText) as Partial<GrammarResult>;
    } catch {
      return {
        score: 45,
        isCorrect: false,
        summary: 'AI trả về không đúng định dạng JSON.',
        errors: [
          {
            type: 'Định dạng AI',
            explanation:
              'Gemini đã phản hồi nhưng backend không đọc được JSON chuẩn.',
            fix: 'Thử lại hoặc đổi GEMINI_MODEL trong backend.',
          },
        ],
        correction: { cn: original, py: '', vi: '' },
        suggestions: [],
        style_tips: raw.slice(0, 240),
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
      suggestions: Array.isArray(parsed.suggestions)
        ? parsed.suggestions.map(String)
        : [],
      style_tips: String(parsed.style_tips ?? ''),
    };
  }
}

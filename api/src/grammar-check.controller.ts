import {
  Controller,
  Post,
  Body,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

interface CheckGrammarDto {
  text: string;
}

@Controller('grammar')
export class GrammarCheckController {
  constructor(private readonly configService: ConfigService) {}

  @Post('check')
  async checkGrammar(@Body() dto: CheckGrammarDto) {
    const text = (dto?.text || '').trim();
    if (!text) {
      throw new HttpException('Text is required', HttpStatus.BAD_REQUEST);
    }

    const apiKey = this.configService.get<string>('GEMINI_API_KEY') || '';

    if (!apiKey) {
      // Fallback: offline mock analysis
      return this.mockCheck(text);
    }

    const models = [
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-1.5-flash',
      'gemini-pro',
    ];
    let lastError = 'Unknown error';

    for (const modelName of models) {
      try {
        const url = `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${apiKey}`;

        const prompt = `Bạn là giáo viên tiếng Trung chuyên nghiệp và nghiêm khắc. Phân tích câu sau một cách KỸ LƯỠNG.

TIÊU CHÍ CHẤM ĐIỂM (score từ 0-100):
- 90-100: Câu hoàn toàn đúng, tự nhiên, địa phương ngữ bản xứ
- 70-89: Câu đúng ngữ pháp nhưng có thể tự nhiên hơn
- 50-69: Câu có 1 lỗi nhỏ, vẫn hiểu được
- 30-49: Câu có lỗi rõ ràng, cần sửa
- 0-29: Câu sai nặng, vô nghĩa hoặc hoàn toàn không đúng cấu trúc

LỖI CẦN PHÁT HIỆN:
- Sai thứ tự từ (VD: 我学校去 thay vì 我去学校)
- Dùng từ không hợp nghĩa hoặc kết hợp từ sai
- Thiếu thành phần câu bắt buộc
- Câu lặp vô nghĩa (VD: 我学校学校)
- Sai động từ hướng (来/去 dùng sai)
- Sai phủ định (không phủ định được danh từ)

VÍ DỤ:
- "我不学校去学校" → score: 15 (sai cấu trúc hoàn toàn, 不 không đặt trước danh từ, thứ tự lộn xộn)
- "你们不纳入去" → score: 10 (vô nghĩa, 纳入+去 không dùng cùng nhau)
- "我去学校" → score: 92 (đúng và tự nhiên)
- "我昨天去了学校" → score: 95 (đúng hoàn toàn)

CHỈ trả về JSON (không thêm text nào khác):
{
  "score": <số nguyên 0-100>,
  "errors": [{"type": "<tên lỗi>", "explanation": "<giải thích lỗi bằng tiếng Việt, câu đúng là gì>"}],
  "correction": {"cn": "<câu đúng>", "py": "<pinyin>", "vi": "<nghĩa tiếng Việt>"},
  "suggestions": [{"cn": "<cách hay hơn>", "py": "<pinyin>", "vi": "<giải thích>"}],
  "style_tips": "<mẹo học tập ngắn bằng tiếng Việt>"
}

Câu cần phân tích: "${text}"`;

        const res = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }],
            generationConfig: {
              temperature: 0.2,
              topK: 10,
              topP: 0.8,
              maxOutputTokens: 1024,
              responseMimeType: 'application/json',
            },
          }),
          signal: AbortSignal.timeout(15000),
        });

        if (res.status === 404) {
          lastError = `Model ${modelName} not found`;
          continue;
        }
        if (!res.ok) {
          throw new Error(`Gemini API error: ${res.status}`);
        }

        const data = await res.json();
        let raw: string =
          data?.candidates?.[0]?.content?.parts?.[0]?.text ?? '{}';
        raw = raw.trim();

        // Strip markdown code fences if present
        if (raw.startsWith('```json')) {
          raw = raw.slice(7);
          const end = raw.lastIndexOf('```');
          if (end !== -1) raw = raw.slice(0, end);
        } else if (raw.startsWith('```')) {
          raw = raw.slice(3);
          const end = raw.lastIndexOf('```');
          if (end !== -1) raw = raw.slice(0, end);
        }
        raw = raw.trim();
        console.log('Raw Gemini Output:', raw);

        const parsed = JSON.parse(raw);

        // Normalize score: if AI returned 0-10 scale, convert to 0-100
        const rawScore = Number(parsed.score ?? 0);
        if (rawScore <= 10) {
          parsed.score = Math.round(rawScore * 10);
        }

        return parsed;
      } catch (e: any) {
        lastError = e.message || String(e);
        if (!lastError.includes('404')) break;
      }
    }

    return {
      score: 0,
      errors: [
        {
          type: 'Lỗi kết nối',
          explanation: `Không kết nối được AI: ${lastError}`,
        },
      ],
      correction: { cn: text, py: '', vi: 'Không thể phân tích.' },
      suggestions: [],
      style_tips: 'Vui lòng kiểm tra kết nối mạng và thử lại.',
    };
  }

  /** Offline mock – used when no GEMINI_API_KEY is configured */
  private mockCheck(text: string): object {
    const errors: { type: string; explanation: string }[] = [];
    let corrected = text;

    // Check: not Chinese
    const hasChinese = /[\u4e00-\u9fff]/.test(text);
    if (!hasChinese) {
      return {
        score: 5,
        errors: [
          {
            type: 'Không phải tiếng Trung',
            explanation: 'Câu không chứa ký tự Hán. Hãy nhập câu tiếng Trung.',
          },
        ],
        correction: { cn: text, py: '', vi: '' },
        suggestions: [],
        style_tips: 'Hãy nhập câu tiếng Trung để kiểm tra.',
      };
    }

    // Repeated characters (e.g. 学校学校, 很很)
    if (/(.{1,4})\1/.test(text)) {
      errors.push({
        type: 'Lặp từ bất thường',
        explanation: `Câu có cụm từ lặp lại bất thường: "${text.match(/(.{1,4})\1/)?.[0]}". Kiểm tra lại ý nghĩa.`,
      });
    }

    // 不 before a noun (not verb/adj) - heuristic
    if (
      /不[\u4e00-\u9fff]{0,1}(学校|医院|公司|学校|商店|公园|图书馆|银行|超市|饭店)/.test(
        text,
      )
    ) {
      errors.push({
        type: '不 dùng sai',
        explanation:
          '不 là phó từ phủ định, chỉ đặt trước động từ hoặc tính từ, không đặt trước danh từ. Ví dụ: 不去学校 ✓, 不学校 ✗',
      });
      corrected = corrected.replace(
        /不(学校|医院|公司|商店|公园|图书馆|银行|超市|饭店)/g,
        '不去$1',
      );
    }

    // 纳入去/来
    if (text.includes('纳入去') || text.includes('纳入来')) {
      errors.push({
        type: 'Kết hợp từ sai',
        explanation:
          "'纳入' không dùng kèm với '去/来'. Có thể bạn muốn nói '进去'(vào trong) hoặc '纳入计划'(đưa vào kế hoạch)?",
      });
    }

    // Wrong word order: verb after time + place without proper structure
    if (
      /去[\u4e00-\u9fff]+去/.test(text) ||
      /来[\u4e00-\u9fff]+来/.test(text)
    ) {
      errors.push({
        type: 'Lặp động từ hướng',
        explanation:
          'Động từ hướng (去/来) không nên lặp lại trong cùng một câu ngắn.',
      });
    }

    if (errors.length === 0) {
      return {
        score: 85,
        errors: [],
        correction: {
          cn: text.endsWith('。') ? text : text + '。',
          py: '',
          vi: 'Câu có vẻ đúng ngữ pháp cơ bản.',
        },
        suggestions: [],
        style_tips:
          '⚠️ Kiểm tra offline (không có AI). Cấu hình GEMINI_API_KEY trong backend để phân tích chính xác hơn.',
      };
    }

    const score = errors.length >= 3 ? 15 : errors.length === 2 ? 30 : 50;
    return {
      score,
      errors,
      correction: {
        cn: corrected.endsWith('。') ? corrected : corrected + '。',
        py: '',
        vi: 'Xem giải thích lỗi ở trên.',
      },
      suggestions: [],
      style_tips:
        '⚠️ Kiểm tra offline. Cấu hình GEMINI_API_KEY trong backend .env để dùng AI thật.',
    };
  }
}

part of '../../main.dart';

class GrammarChecker {
  static GrammarCheckResult check(String text) {
    final normalized = text
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[。！？!?]$'), '');
    final ruleResult = _checkCommonPatterns(normalized);
    if (ruleResult != null) return ruleResult;
    if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(normalized)) {
      return const GrammarCheckResult(
        score: 35,
        title: 'Cần nhập tiếng Trung',
        summary: 'Chưa nhận ra Hán tự trong câu.',
        correction: '',
        explanation:
            'Hãy nhập câu bằng chữ Hán để hệ thống kiểm tra trật tự từ và mẫu ngữ pháp.',
        errors: ['Không có chữ Hán để phân tích.'],
      );
    }
    if (normalized == '我不学校去') {
      return const GrammarCheckResult(
        score: 58,
        title: 'Cần sửa trật tự',
        summary: 'Phó từ 不 đứng trước động từ 去, địa điểm 学校 đặt sau động từ.',
        correction: '我不去学校。',
        explanation: 'Cấu trúc đúng: Chủ ngữ + 不 + Động từ + Tân ngữ/địa điểm.',
        errors: ['Sai trật tự: 不学校去 nên sửa thành 不去学校.'],
      );
    }
    if (normalized == '我去昨天学校') {
      return const GrammarCheckResult(
        score: 62,
        title: 'Cần sửa trạng ngữ thời gian',
        summary: '昨天 nên đứng trước động từ hoặc sau chủ ngữ.',
        correction: '我昨天去学校。',
        explanation:
            'Trong tiếng Trung, trạng ngữ thời gian thường đứng đầu câu hoặc sau chủ ngữ.',
        errors: [
          'Sai vị trí thời gian: 昨天 không đặt giữa động từ 去 và địa điểm 学校.',
        ],
      );
    }
    if (normalized.contains('很很')) {
      return GrammarCheckResult(
        score: 54,
        title: 'Lặp phó từ',
        summary: 'Không dùng 很 hai lần liên tiếp.',
        correction: normalized.replaceAll('很很', '很'),
        explanation: 'Nếu muốn nhấn mạnh hơn, có thể dùng 非常 hoặc 特别.',
        errors: const ['Lặp từ 很.'],
      );
    }
    return GrammarCheckResult(
      score: 92,
      title: 'Rất tốt',
      summary: 'Câu của bạn khá tự nhiên.',
      correction: normalized.endsWith('。') || normalized.endsWith('？')
          ? normalized
          : '$normalized。',
      explanation:
          'Chưa phát hiện lỗi lớn. Hãy tiếp tục luyện thêm câu dài hơn.',
      errors: const [],
    );
  }

  static GrammarCheckResult? _checkCommonPatterns(String normalized) {
    if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(normalized)) return null;

    var correction = normalized;
    final errors = <String>[];
    var score = 96;

    void issue(String message, {int penalty = 14}) {
      errors.add(message);
      score -= penalty;
    }

    final locationVerb = RegExp(
      r'^(.+?)不(学校|公司|医院|商店|市场|公园|图书馆|机场|北京|中国|越南|家)(去|来|到)$',
    ).firstMatch(correction);
    if (locationVerb != null) {
      correction =
          '${locationVerb.group(1)!}不${locationVerb.group(3)!}${locationVerb.group(2)!}';
      issue(
        'Sai trật tự phủ định với địa điểm: 不 phải đứng trước động từ, rồi mới đến địa điểm. Mẫu đúng: Chủ ngữ + 不 + 去/来/到 + địa điểm.',
        penalty: 30,
      );
    }

    final missingVerbLocation = RegExp(
      r'^(.+?)不(学校|公司|医院|商店|市场|公园|图书馆|机场|北京|中国|越南|家)$',
    ).firstMatch(correction);
    if (missingVerbLocation != null) {
      correction =
          '${missingVerbLocation.group(1)!}不去${missingVerbLocation.group(2)!}';
      issue(
        'Sau 不 cần một động từ rõ ràng. Với địa điểm, thường dùng 不去 + địa điểm.',
        penalty: 22,
      );
    }

    final timeAfterVerb = RegExp(
      r'^(.+?)(去|来|到|学习|工作|吃饭|看书|买东西|开会)(昨天|今天|明天|早上|上午|中午|下午|晚上)(.+)$',
    ).firstMatch(correction);
    if (timeAfterVerb != null) {
      correction =
          '${timeAfterVerb.group(1)!}${timeAfterVerb.group(3)!}${timeAfterVerb.group(2)!}${timeAfterVerb.group(4)!}';
      issue(
        'Trạng ngữ thời gian nên đặt trước động từ hoặc ngay sau chủ ngữ, không đặt kẹp giữa động từ và tân ngữ.',
        penalty: 22,
      );
    }

    if (correction.contains('很很')) {
      correction = correction.replaceAll('很很', '很');
      issue(
        'Không lặp 很 hai lần liên tiếp. Muốn nhấn mạnh có thể dùng 非常, 特别 hoặc 很 + tính từ.',
        penalty: 18,
      );
    }

    final shiAdjective = RegExp(
      r'^(.+?)是(很)?(好|忙|累|高兴|漂亮|热|冷|难|贵|便宜|舒服|开心)$',
    ).firstMatch(correction);
    if (shiAdjective != null) {
      correction =
          '${shiAdjective.group(1)!}${shiAdjective.group(2) ?? '很'}${shiAdjective.group(3)!}';
      issue(
        'Tính từ vị ngữ trong tiếng Trung thường không dùng 是. Nói "我很好", không nói "我是很好".',
        penalty: 18,
      );
    }

    final measureWordFixes = <String, String>{
      '一书': '一本书',
      '一苹果': '一个苹果',
      '一老师': '一位老师',
      '一学生': '一个学生',
      '一朋友': '一个朋友',
      '两书': '两本书',
      '两苹果': '两个苹果',
      '两学生': '两个学生',
    };
    for (final entry in measureWordFixes.entries) {
      if (correction.contains(entry.key)) {
        correction = correction.replaceAll(entry.key, entry.value);
        issue(
          'Danh từ đếm được thường cần lượng từ: ví dụ 一本书, 一个苹果, 一位老师.',
          penalty: 14,
        );
        break;
      }
    }

    if (RegExp(r'(了了|过过|吗吗)').hasMatch(correction)) {
      correction = correction
          .replaceAll('了了', '了')
          .replaceAll('过过', '过')
          .replaceAll('吗吗', '吗');
      issue('Trợ từ ngữ khí/trợ từ thể không nên lặp liên tiếp trong câu này.');
    }

    final hasPredicate = RegExp(
      r'(是|有|在|去|来|到|学|学习|喜欢|想|要|吃|喝|看|买|卖|做|工作|觉得|会|能|可以|很|不|没|吗|了|过|给|请|让|比|把|被|开|住|坐|听|说|读|写)',
    ).hasMatch(correction);
    if (errors.isEmpty && !hasPredicate && correction.length > 2) {
      issue(
        'Câu chưa có vị ngữ rõ ràng. Hãy thêm động từ hoặc tính từ để câu hoàn chỉnh hơn.',
        penalty: 18,
      );
    }

    if (errors.isEmpty) return null;

    score = score.clamp(35, 96);
    final punctuated = correction.endsWith('吗') || correction.endsWith('呢')
        ? '$correction？'
        : '$correction。';
    return GrammarCheckResult(
      score: score,
      title: score < 70 ? 'Cần sửa trước khi dùng' : 'Có điểm cần chỉnh',
      summary: errors.first,
      correction: punctuated,
      explanation:
          'Hãy đọc theo mẫu sửa, sau đó tự thay chủ ngữ, thời gian hoặc địa điểm để luyện lại cấu trúc.',
      errors: errors,
    );
  }
}

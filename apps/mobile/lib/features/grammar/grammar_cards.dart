part of '../../main.dart';

class GrammarLessonCard extends StatelessWidget {
  const GrammarLessonCard({
    super.key,
    required this.index,
    required this.lesson,
  });

  final int index;
  final GrammarLessonData lesson;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lesson.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F6FB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.blue.withValues(alpha: 0.16)),
            ),
            child: Text(
              lesson.pattern,
              style: const TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(lesson.explanation),
          const SizedBox(height: 12),
          const Text(
            'Ví dụ minh họa:',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          ...lesson.examples.map((ex) => ExampleTile(example: ex)),
          if (lesson.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            AppCard(color: const Color(0xFFFFFAEA), child: Text(lesson.note)),
          ],
        ],
      ),
    );
  }
}

class GrammarResultCard extends StatelessWidget {
  const GrammarResultCard({super.key, required this.result});

  final GrammarCheckResult result;

  @override
  Widget build(BuildContext context) {
    final unavailable = result.score <= 0 && !result.isAi;
    final good = result.score >= 85;
    final color = unavailable
        ? AppColors.blue
        : good
        ? AppColors.jade
        : result.score >= 60
        ? AppColors.amber
        : AppColors.cinnabar;
    return Column(
      children: [
        AppCard(
          child: Row(
            children: [
              Container(
                width: 78,
                height: 78,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 5),
                ),
                child: Text(
                  unavailable ? 'AI' : '${result.score}',
                  style: TextStyle(
                    color: color,
                    fontSize: unavailable ? 20 : 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(result.summary),
                    const SizedBox(height: 8),
                    StatusPill(
                      icon: result.isAi
                          ? Icons.auto_awesome
                          : Icons.offline_bolt_outlined,
                      label: result.provider,
                      color: color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          color: const Color(0xFFEFFAF4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Câu sửa lại chính xác:',
                style: TextStyle(
                  color: AppColors.jade,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              SelectableText(
                result.correction,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.explanation,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
        if (result.suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            color: const Color(0xFFF0F6FB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gợi ý diễn đạt:',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ...result.suggestions.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SelectableText(item),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (result.errors.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...result.errors.map(
            (error) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                color: const Color(0xFFFFF7E8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.amber,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(error)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

part of '../../main.dart';

class VideoLessonCard extends StatelessWidget {
  const VideoLessonCard({
    super.key,
    required this.lesson,
    required this.onOpen,
  });

  final VideoLessonData lesson;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(8),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 8.4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: Image.network(
                      lesson.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Container(color: const Color(0xFF1E2132)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.58),
                        ],
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: StatusPill(
                      label: lesson.level,
                      color: AppColors.jade,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${lesson.subtitles.length} câu',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lesson.titleCn,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusPill(
                        icon: Icons.ondemand_video_outlined,
                        label: lesson.source,
                        color: AppColors.cinnabar,
                      ),
                      StatusPill(
                        icon: lesson.hasTimedSubtitles
                            ? Icons.sync
                            : Icons.edit_note,
                        label: lesson.hasTimedSubtitles
                            ? 'Phụ đề đã khớp'
                            : 'Luyện câu thủ công',
                        color: lesson.hasTimedSubtitles
                            ? AppColors.jade
                            : AppColors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson.youtubeUrl,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.blue, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

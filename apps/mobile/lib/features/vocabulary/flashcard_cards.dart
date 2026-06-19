part of '../../main.dart';

bool _isRemoteFlashcardImagePath(String value) {
  final path = value.trim();
  return path.startsWith('http://') ||
      path.startsWith('https://') ||
      path.startsWith('//');
}

String? _resolveFlashcardImagePath(String topicId, Map raw) {
  final explicitPath = (raw['imagePath'] ?? raw['imageUrl'] ?? '')
      .toString()
      .trim();
  if (explicitPath.isNotEmpty) return explicitPath;

  final image = (raw['image'] ?? '').toString().trim();
  if (image.isEmpty) return null;
  if (_isRemoteFlashcardImagePath(image) ||
      image.startsWith('/uploads/') ||
      image.startsWith('assets/')) {
    return image;
  }
  return 'assets/images/flashcards/$topicId/$image';
}

Widget _flashcardImage(
  String imagePath, {
  required BoxFit fit,
  required Widget fallback,
}) {
  final path = imagePath.trim();
  if (path.isEmpty) return fallback;
  if (_isRemoteFlashcardImagePath(path) || path.startsWith('/uploads/')) {
    final url = path.startsWith('/uploads/')
        ? '${DictionaryRepository.apiBaseUrl}$path'
        : path;
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
  return Image.asset(
    path,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => fallback,
  );
}

class FlashcardTopicArt extends StatelessWidget {
  const FlashcardTopicArt({
    super.key,
    required this.topic,
    required this.color,
  });

  final FlashcardTopic topic;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.95),
            _pairedVisualColor(color).withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -8,
            child: Icon(
              topic.icon,
              size: 54,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          Center(child: Icon(topic.icon, color: Colors.white, size: 30)),
        ],
      ),
    );
    final imagePath = topic.imagePath;
    if (imagePath == null || imagePath.isEmpty) return fallback;

    return Stack(
      fit: StackFit.expand,
      children: [
        _flashcardImage(
          imagePath,
          fit: BoxFit.cover,
          fallback: fallback,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.48),
                Colors.black.withValues(alpha: 0.08),
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ],
    );
  }
}

class FlashcardWordArt extends StatelessWidget {
  const FlashcardWordArt({super.key, required this.entry});

  final VocabEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = _visualPalette(entry.simplified);
    final icon = _visualIconFor(entry);
    final fallback = _fallback(colors, icon);
    final imagePath = entry.imagePath;
    if (imagePath == null || imagePath.isEmpty) return fallback;

    return Stack(
      fit: StackFit.expand,
      children: [
        _flashcardImage(
          imagePath,
          fit: BoxFit.cover,
          fallback: fallback,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.02),
                Colors.black.withValues(alpha: 0.68),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          left: 28,
          right: 28,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.simplified,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  shadows: [Shadow(blurRadius: 12, color: Colors.black87)],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.meaning,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fallback(List<Color> colors, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -28,
            top: -34,
            child: Icon(
              icon,
              size: 180,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            left: -18,
            bottom: -24,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.13),
              ),
            ),
          ),
          Positioned(
            right: 22,
            bottom: 34,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Học bằng hình',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 24,
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, color: colors.first, size: 62),
            ),
          ),
          Positioned(
            left: 28,
            right: 28,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.simplified,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.meaning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopicCard extends StatelessWidget {
  const TopicCard({
    super.key,
    required this.topic,
    required this.savedCount,
    required this.onTap,
  });

  final FlashcardTopic topic;
  final int savedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(topic.level);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: FlashcardTopicArt(topic: topic, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      StatusPill(label: 'Flashcard', color: color),
                      const StatusPill(label: 'Quiz', color: AppColors.blue),
                    ],
                  ),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: topic.words.isEmpty
                          ? 0
                          : savedCount / topic.words.length,
                      minHeight: 5,
                      backgroundColor: AppColors.line,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$savedCount/${topic.words.length} từ',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

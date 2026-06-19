part of '../../main.dart';

class FlashcardImageSuggestion {
  const FlashcardImageSuggestion({
    required this.provider,
    required this.keyword,
    required this.style,
    required this.flaticonSearchUrl,
    required this.note,
  });

  final String provider;
  final String keyword;
  final String style;
  final String flaticonSearchUrl;
  final String note;

  factory FlashcardImageSuggestion.fromJson(Map<String, dynamic> json) {
    return FlashcardImageSuggestion(
      provider: (json['provider'] ?? 'local-flat-icon').toString(),
      keyword: (json['keyword'] ?? '').toString(),
      style: (json['style'] ?? '').toString(),
      flaticonSearchUrl: (json['flaticonSearchUrl'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
    );
  }

  factory FlashcardImageSuggestion.fallback(VocabEntry entry) {
    final keyword = '${entry.simplified} ${entry.meaning}'.trim();
    return FlashcardImageSuggestion(
      provider: 'fallback-flat-icon',
      keyword: keyword,
      style: 'rounded flat vector, bright, simple object, no text',
      flaticonSearchUrl:
          'https://www.flaticon.com/search?word=${Uri.encodeComponent(keyword)}',
      note:
          'Backend chưa phản hồi. Có thể dùng URL tìm kiếm này để lấy ảnh có license, hoặc thay bằng asset/API ảnh riêng.',
    );
  }
}

class FlashcardImageRepository {
  static Future<FlashcardImageSuggestion> suggest(VocabEntry entry) async {
    final uri = Uri.parse(
      '${DictionaryRepository.apiBaseUrl}/flashcard/image-suggestion'
      '?q=${Uri.encodeComponent(entry.simplified)}'
      '&meaning=${Uri.encodeComponent(entry.meaning)}',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 3));
    if (response.statusCode != 200) {
      throw Exception('Image suggestion API ${response.statusCode}');
    }
    return FlashcardImageSuggestion.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

class FlashcardView extends StatelessWidget {
  const FlashcardView({
    super.key,
    required this.entry,
    required this.saved,
    required this.isRecording,
    required this.isScoringPronunciation,
    required this.recognizedText,
    required this.pronunciationScore,
    required this.onSpeak,
    required this.onTogglePronunciation,
    required this.onToggleSaved,
  });

  final VocabEntry entry;
  final bool saved;
  final bool isRecording;
  final bool isScoringPronunciation;
  final String recognizedText;
  final VideoPronunciationScore? pronunciationScore;
  final VoidCallback onSpeak;
  final VoidCallback onTogglePronunciation;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final score = pronunciationScore;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (entry.imagePath != null && entry.imagePath!.isNotEmpty)
                    _flashcardImage(
                      entry.imagePath!,
                      fit: BoxFit.cover,
                      fallback: _FlashcardImageFallback(entry: entry),
                    )
                  else
                    _FlashcardImageFallback(entry: entry),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.12),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.cinnabar,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          entry.pinyin,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            color: AppColors.muted,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          entry.simplified,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'NotoSansSC',
            fontSize: 76,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          entry.meaning,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.cinnabar,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              tooltip: 'Nghe mẫu',
              onPressed: onSpeak,
              icon: const Icon(Icons.volume_up_outlined),
            ),
            const SizedBox(width: 16),
            IconButton.filledTonal(
              tooltip: saved ? 'Bỏ khỏi sổ tay' : 'Lưu vào sổ tay',
              onPressed: onToggleSaved,
              icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
            ),
            const SizedBox(width: 16),
            IconButton.filledTonal(
              tooltip: isRecording ? 'Dừng và chấm điểm' : 'Ghi âm phát âm',
              onPressed: isScoringPronunciation ? null : onTogglePronunciation,
              icon: Icon(
                isScoringPronunciation
                    ? Icons.hourglass_top
                    : isRecording
                    ? Icons.stop_rounded
                    : Icons.mic_none_outlined,
              ),
              style: IconButton.styleFrom(
                backgroundColor: isRecording
                    ? AppColors.cinnabar.withValues(alpha: 0.16)
                    : null,
                foregroundColor: isRecording ? AppColors.cinnabar : null,
              ),
            ),
          ],
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isRecording
              ? Padding(
                  key: const ValueKey('recording'),
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    recognizedText.isEmpty
                        ? 'Đang nghe... bấm lại để dừng'
                        : 'Máy nghe: $recognizedText',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.cinnabar,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : isScoringPronunciation
              ? const Padding(
                  key: ValueKey('scoring'),
                  padding: EdgeInsets.only(top: 14),
                  child: SizedBox(
                    width: 180,
                    child: LinearProgressIndicator(minHeight: 4),
                  ),
                )
              : score != null
              ? Container(
                  key: const ValueKey('score'),
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: score.score >= 80
                        ? AppColors.jade.withValues(alpha: 0.09)
                        : score.score >= 55
                        ? AppColors.amber.withValues(alpha: 0.12)
                        : AppColors.cinnabar.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: score.score >= 80
                          ? AppColors.jade.withValues(alpha: 0.35)
                          : score.score >= 55
                          ? AppColors.amber.withValues(alpha: 0.35)
                          : AppColors.cinnabar.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Điểm phát âm: ${score.score}/100',
                        style: TextStyle(
                          color: score.score >= 80
                              ? AppColors.jade
                              : score.score >= 55
                              ? AppColors.amber
                              : AppColors.cinnabar,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        score.source.startsWith('api')
                            ? 'Máy chấm tự động: nhận giọng nói + so khớp Hán tự/pinyin'
                            : 'App chấm tạm trên thiết bị khi backend chưa phản hồi',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (recognizedText.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Máy nghe: $recognizedText',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      if (score.feedback.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          score.feedback,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _FlashcardImageFallback extends StatelessWidget {
  const _FlashcardImageFallback({required this.entry});

  final VocabEntry entry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF6F0), Color(0xFFFFF1E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          entry.simplified,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 76,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

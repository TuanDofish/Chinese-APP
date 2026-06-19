import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile/features/vocabulary/vocabulary_list_screen.dart';
import 'package:mobile/core/services/progress_service.dart';
import 'package:mobile/features/vocabulary/vocab_data_helper.dart';
import 'package:mobile/features/vocabulary/dictionary_search_tab.dart';

class MagicVocabScreen extends StatefulWidget {
  const MagicVocabScreen({super.key});

  @override
  State<MagicVocabScreen> createState() => _MagicVocabScreenState();
}

class _MagicVocabScreenState extends State<MagicVocabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProgressService _progressService = ProgressService();
  final FlutterTts _tts = FlutterTts();

  Set<String> _favoriteWords = {};
  Set<String> _learnedWords = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tts.setLanguage("zh-CN");
    _tts.setSpeechRate(0.5);
    _loadData();
  }

  Future<void> _loadData() async {
    final favorites = await _progressService.getFavoriteWords();
    final learned = await _progressService.getLearnedWords();
    if (mounted) {
      setState(() {
        _favoriteWords = favorites;
        _learnedWords = learned;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sổ tay Từ vựng"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD32F2F),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD32F2F),
          tabs: [
            Tab(text: "Sổ tay (${_favoriteWords.length})"),
            const Tab(text: "Tra từ"),
            const Tab(text: "Bài học"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotebookTab(),
          const DictionarySearchTab(),
          const VocabularyListScreen(),
        ],
      ),
    );
  }

  Widget _buildNotebookTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favoriteWords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Chưa có từ nào trong sổ tay",
              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              "Nhấn ⭐ khi học từ vựng để lưu vào đây",
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _tabController.animateTo(1); // Go to Dictionary tab to search
              },
              icon: const Icon(Icons.search),
              label: const Text("Tra từ vựng"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _favoriteWords.length,
        separatorBuilder: (c, i) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          String word = _favoriteWords.elementAt(index);
          bool isLearned = _learnedWords.contains(word);
          return _buildWordCard(word, isLearned);
        },
      ),
    );
  }

  Widget _buildWordCard(String word, bool isLearned) {
    // Try to get data from manual map
    Map<String, dynamic> data = VocabDataHelper.getData(word, {"forms": []});
    String meaning = data['meaning'] ?? '';
    if (meaning == 'Đang tải...') meaning = '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hanzi
          GestureDetector(
            onTap: () => _tts.speak(word),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  word,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (meaning.isNotEmpty)
                  Text(
                    meaning,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          // Status & Actions
          Column(
            children: [
              if (isLearned)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "Đã học",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () async {
                  await _progressService.toggleFavorite(word);
                  _loadData();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'vocab_data_helper.dart';
import 'hanzii_detail_panel.dart';
import 'pinyin_utils.dart';
import 'text_sanitizer.dart';

class DictionarySearchTab extends StatefulWidget {
  const DictionarySearchTab({super.key});

  @override
  State<DictionarySearchTab> createState() => _DictionarySearchTabState();
}

class _DictionarySearchTabState extends State<DictionarySearchTab> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isSearching = false;
  bool _showSuggestions = false;
  List<Map<String, dynamic>> _suggestions = [];
  Map<String, dynamic>? _searchResult;
  String _errorMessage = '';
  final List<String> _recentSearches = [];
  Timer? _debounce;

  static const String _apiBase = AppConfig.apiBaseUrl;

  final List<String> _trendingWords = [
    '你好', '谢谢', '学习', '朋友', '工作', '喜欢', '中国', '汉语',
  ];

  bool _hasChineseText(String input) =>
      RegExp(r'[\u4e00-\u9fff]').hasMatch(input);
  bool _isBrokenText(String text) =>
      RegExp(r'[ÃÄÂðŸ]|�').hasMatch(text) || TextSanitizer.isLikelyMojibake(text);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    VocabDataHelper.preloadBundleIndex();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _searchResult = null;
        _errorMessage = '';
      });
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      _fetchAutocomplete(q);
    });
  }

  Future<void> _fetchAutocomplete(String q) async {
    try {
      final uri = Uri.parse('$_apiBase/dictionary/autocomplete?q=${Uri.encodeComponent(q)}');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 1200));
      if (res.statusCode == 200 && mounted) {
        final List<dynamic> list = json.decode(res.body);
        setState(() {
          _suggestions = list
              .map((e) => _normalizeVocab(Map<String, dynamic>.from(e as Map)))
              .toList();
          _showSuggestions = list.isNotEmpty;
        });
      }
    } catch (_) {}
  }

  Future<void> _performSearch(String q, {Map<String, dynamic>? suggestion}) async {
    q = q.trim();
    if (q.isEmpty) return;

    _focusNode.unfocus();
    setState(() {
      _isSearching = true;
      _showSuggestions = false;
      // Nếu có dữ liệu từ gợi ý, hiển thị ngay lập tức để tránh delay "Đang tải..."
      if (suggestion != null) {
        _searchResult = _normalizeVocab(suggestion);
      } else {
        _searchResult = null;
      }
      _errorMessage = '';
      if (!_recentSearches.contains(q)) {
        _recentSearches.insert(0, q);
        if (_recentSearches.length > 10) _recentSearches.removeLast();
      }
    });

    try {
      String chineseWord = q;

      if (!_hasChineseText(q)) {
        final viResult = await _searchLocalDB(q);
        if (viResult != null) {
          if (mounted) setState(() { _isSearching = false; _searchResult = viResult; });
          return;
        }
        chineseWord = await VocabDataHelper.translateViToZhAsync(q);
      }

      if (chineseWord.isEmpty) {
        if (mounted) setState(() { _isSearching = false; _errorMessage = 'Không tìm thấy kết quả.'; });
        return;
      }

      final detail = await _fetchDetail(chineseWord);
      if (detail != null) {
        if (mounted) setState(() { _isSearching = false; _searchResult = detail; });
        return;
      }

      final dbResult = await _searchLocalDB(chineseWord);
      if (dbResult != null) {
        if (mounted) setState(() { _isSearching = false; _searchResult = dbResult; });
        return;
      }
      final bundled = _fallbackFromBundledData(chineseWord);
      if (bundled != null) {
        if (mounted) setState(() { _isSearching = false; _searchResult = bundled; });
        return;
      }

      if (mounted) {
        setState(() {
          _isSearching = false;
          // Keep suggestion result if available when network lookups fail.
          if (_searchResult == null) {
            _searchResult = {'simplified': chineseWord, 'forms': []};
            _errorMessage = 'Không tìm thấy trong API, đang hiển thị dữ liệu tối giản.';
          }
        });
      }
    } catch (e) {
      final bundled = _fallbackFromBundledData(q);
      if (mounted) {
        setState(() {
          _isSearching = false;
          if (bundled != null) {
            _searchResult = bundled;
            _errorMessage = 'Đang offline: hiển thị từ dữ liệu có sẵn trên app.';
          } else {
            _errorMessage = 'Lỗi kết nối. Kiểm tra mạng.';
          }
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _fetchDetail(String word) async {
    try {
      final encoded = Uri.encodeComponent(word);
      final uri = Uri.parse('$_apiBase/dictionary/detail/$encoded');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data != null && data is Map<String, dynamic>) return _normalizeVocab(data);
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> _searchLocalDB(String q) async {
    try {
      final uri = Uri.parse('$_apiBase/dictionary/search?q=${Uri.encodeComponent(q)}');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List<dynamic> list = json.decode(res.body);
        if (list.isNotEmpty) return _normalizeVocab(list[0] as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Map<String, dynamic> _normalizeVocab(Map<String, dynamic> item) {
    List<Map<String, dynamic>> examples = [];
    if (item['examples'] is List) {
      examples = (item['examples'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    String meaning = (item['meaningVi']?.isNotEmpty == true ? item['meaningVi'] : null) ??
        (item['meaning_vi']?.isNotEmpty == true ? item['meaning_vi'] : null) ??
        (item['meaningEn']?.isNotEmpty == true ? item['meaningEn'] : null) ??
        (item['meaning_en']?.isNotEmpty == true ? item['meaning_en'] : null) ??
        item['meaning'] ??
        '';

    String pinyin = item['pinyin'] ?? '';
    final simplified = TextSanitizer.clean((item['simplified'] ?? '').toString());
    final traditional = TextSanitizer.clean((item['traditional'] ?? '').toString());
    meaning = TextSanitizer.clean(meaning);
    pinyin = TextSanitizer.clean(pinyin);

    if (_isBrokenText(meaning) || _isBrokenText(pinyin) || meaning.trim().isEmpty) {
      final local = VocabDataHelper.getData(simplified, {'simplified': simplified});
      final localMeaning = (local['meaning'] ?? '').toString();
      final localPinyin = (local['pinyin'] ?? '').toString();
      if (!_isBrokenText(localMeaning) && localMeaning.trim().isNotEmpty) {
        meaning = localMeaning;
      }
      if (!_isBrokenText(localPinyin) && localPinyin.trim().isNotEmpty) {
        pinyin = localPinyin;
      }
    }

    return {
      'simplified': simplified,
      'traditional': traditional,
      'pinyin': pinyin,
      'meaning': meaning,
      'hanViet': TextSanitizer.clean((item['hanViet'] ?? item['han_viet'] ?? '').toString()),
      'radical': TextSanitizer.clean((item['radical'] ?? '').toString()),
      'wordType': TextSanitizer.clean((item['wordType'] ?? item['word_type'] ?? '').toString()),
      'hskLevel': item['hskLevel'] ?? item['hsk_level'] ?? 0,
      'strokeCount': item['strokeCount'] ?? item['stroke_count'] ?? 0,
      'examples': examples,
      'forms': [],
    };
  }

  Map<String, dynamic>? _fallbackFromBundledData(String query) {
    final text = query.trim();
    if (text.isEmpty) return null;
    final data = VocabDataHelper.getData(text, {'simplified': text});
    final meaning = (data['meaning'] as String?)?.trim() ?? '';
    final pinyin = (data['pinyin'] as String?)?.trim() ?? '';
    final examples = data['examples'] is List ? data['examples'] as List : [];

    if (meaning.isEmpty && pinyin.isEmpty && examples.isEmpty) return null;

    return {
      'simplified': data['simplified'] ?? text,
      'traditional': data['traditional'] ?? '',
      'pinyin': pinyin,
      'meaning': meaning.isNotEmpty ? meaning : 'Đang cập nhật nghĩa',
      'hanViet': data['hanViet'] ?? '',
      'radical': data['radical'] ?? '',
      'wordType': data['wordType'] ?? '',
      'hskLevel': data['hskLevel'] ?? 0,
      'strokeCount': data['strokeCount'] ?? 0,
      'examples': examples,
      'forms': [],
    };
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: This widget is placed inside ScreenShell's ListView,
    // so we MUST NOT use Expanded. Use MediaQuery height instead.
    final screenH = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search bar ──────────────────────────────────────────────────────
        _buildSearchBar(),
        const SizedBox(height: 8),

        // ── Autocomplete dropdown ────────────────────────────────────────────
        if (_showSuggestions && _suggestions.isNotEmpty)
          _buildAutocompleteDropdown(),

        // ── Loading ──────────────────────────────────────────────────────────
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator(color: Color(0xFFC63D33))),
          ),

        // ── Error ────────────────────────────────────────────────────────────
        if (!_isSearching && _errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.search_off_rounded, size: 56, color: Color(0xFFE7DDD0)),
                  const SizedBox(height: 12),
                  Text(_errorMessage, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

        // ── Result: Hanzii detail panel (fixed height) ─────────────────────
        if (!_isSearching && _searchResult != null)
          SizedBox(
            height: screenH * 0.78,
            child: HanziiDetailPanel(
              key: ValueKey(_searchResult!['simplified']),
              wordData: _searchResult!,
              onSearchRelated: (word) {
                _searchController.text = word;
                _performSearch(word);
              },
            ),
          ),

        // ── Empty state + history + trending ────────────────────────────────
        if (!_isSearching && _searchResult == null && _errorMessage.isEmpty)
          _buildEmptyState(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onSubmitted: _performSearch,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Hãy gõ từ',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.normal),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 8),
                child: Icon(Icons.search_rounded, color: Color(0xFFC63D33), size: 22),
              ),
              prefixIconConstraints: const BoxConstraints(),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.cancel_rounded, color: Colors.grey, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _focusNode.requestFocus();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE7DDD0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE7DDD0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFC63D33), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _isSearching ? null : () => _performSearch(_searchController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC63D33),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isSearching
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Tra', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        ),
      ],
    );
  }

  Widget _buildAutocompleteDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7DDD0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: _suggestions.asMap().entries.map((entry) {
          final s = entry.value;
          final isFirst = entry.key == 0;
          final isLast = entry.key == _suggestions.length - 1;
          final hz = TextSanitizer.clean(s['simplified'] as String? ?? '');
          final py = PinyinUtils.convertSpaced(TextSanitizer.clean(s['pinyin'] as String? ?? ''));
          String vi = TextSanitizer.clean(s['meaningVi'] as String? ?? '');
          if (vi.isEmpty) {
             vi = TextSanitizer.clean(s['meaningEn'] as String? ?? '');
          }
          if (vi.isEmpty) {
            vi = TextSanitizer.clean(s['meaning'] as String? ?? '');
          }
          final traditional = TextSanitizer.clean(s['traditional'] as String? ?? '');
          
          return InkWell(
            onTap: () {
              _searchController.text = hz;
              _performSearch(hz, suggestion: s);
            },
            borderRadius: BorderRadius.vertical(
              top: isFirst ? const Radius.circular(14) : Radius.zero,
              bottom: isLast ? const Radius.circular(14) : Radius.zero,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF5F0EC), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 15, color: Color(0xFF18202A), fontFamily: 'sans-serif'),
                        children: [
                          TextSpan(
                            text: hz,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFC63D33)),
                          ),
                          if (traditional.isNotEmpty && traditional != hz)
                            TextSpan(
                              text: ' / $traditional',
                              style: const TextStyle(color: Color(0xFF667085)),
                            ),
                          if (py.isNotEmpty)
                            TextSpan(
                              text: ' [$py] ',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          if (vi.isNotEmpty)
                            TextSpan(
                              text: vi,
                              style: const TextStyle(color: Color(0xFF667085)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.north_west_rounded, size: 14, color: Color(0xFFCCC5BE)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Recent searches
        if (_recentSearches.isNotEmpty) ...[
          _sectionLabel('Lịch sử tìm kiếm', Icons.history_rounded),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _recentSearches.map((w) => _historyChip(w)).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Trending
        _sectionLabel('Từ thịnh hành', Icons.trending_up_rounded),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _trendingWords.map((w) => _trendingChip(w)).toList(),
        ),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFECB3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('💡', style: TextStyle(fontSize: 16)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hỗ trợ tra cứu đa chiều: Hán tự (学), Pinyin (xuexi), Tiếng Việt (học tập) và Hán Việt.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6D4C00), height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFFC63D33)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF667085))),
      ],
    );
  }

  Widget _historyChip(String word) {
    return GestureDetector(
      onTap: () { _searchController.text = word; _performSearch(word); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE7DDD0)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, size: 13, color: Colors.grey),
            const SizedBox(width: 5),
            Text(word, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _trendingChip(String word) {
    return GestureDetector(
      onTap: () { _searchController.text = word; _performSearch(word); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3F0),
          border: Border.all(color: const Color(0xFFFFCDD2)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(word,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFC63D33))),
      ),
    );
  }
}


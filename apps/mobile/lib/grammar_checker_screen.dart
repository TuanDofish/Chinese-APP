import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'app_config.dart';
import 'grammar_ai_service.dart';

class GrammarCheckerScreen extends StatefulWidget {
  const GrammarCheckerScreen({super.key});

  @override
  State<GrammarCheckerScreen> createState() => _GrammarCheckerScreenState();
}

class _GrammarCheckerScreenState extends State<GrammarCheckerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;

  // Grammar lessons organized by HSK level (Fallback data if API fails)
  Map<String, List<Map<String, dynamic>>> _grammarLessons = {
    "HSK 1": [
      {
        "title": "是 (shì) — Câu phán đoán",
        "pattern": "A + 是 + B",
        "explain": "\"Là\" dùng để xác định, giới thiệu thân phận.",
        "examples": [
          {"cn": "我是学生。", "py": "Wǒ shì xuésheng.", "vi": "Tôi là học sinh."},
          {"cn": "她是老师。", "py": "Tā shì lǎoshī.", "vi": "Cô ấy là giáo viên."},
        ]
      },
      {
        "title": "的 (de) — Sở hữu",
        "pattern": "A + 的 + B",
        "explain": "\"Của\" dùng để biểu thị sở hữu.",
        "examples": [
          {"cn": "我的书。", "py": "Wǒ de shū.", "vi": "Sách của tôi."},
        ]
      },
      {
        "title": "吗 (ma) — Câu hỏi Yes/No",
        "pattern": "Câu khẳng định + 吗？",
        "explain": "Thêm 吗 vào cuối câu để tạo câu hỏi Yes/No.",
        "examples": [
          {"cn": "你好吗？", "py": "Nǐ hǎo ma?", "vi": "Bạn khỏe không?"},
          {"cn": "你是学生吗？", "py": "Nǐ shì xuésheng ma?", "vi": "Bạn là học sinh phải không?"},
        ]
      },
      {
        "title": "不 (bù) — Phủ định",
        "pattern": "不 + Động từ/Tính từ",
        "explain": "\"Không\" đặt trước động/tính từ để phủ định.",
        "examples": [
          {"cn": "我不忙。", "py": "Wǒ bù máng.", "vi": "Tôi không bận."},
        ]
      },
      {
        "title": "很 (hěn) — Trạng từ mức độ",
        "pattern": "Chủ ngữ + 很 + Tính từ",
        "explain": "\"Rất\" dùng liên kết chủ ngữ với tính từ.",
        "examples": [
          {"cn": "她很漂亮。", "py": "Tā hěn piàoliang.", "vi": "Cô ấy rất đẹp."},
        ]
      },
    ],
    "HSK 2": [
      {
        "title": "了 (le) — Hoàn thành",
        "pattern": "Động từ + 了",
        "explain": "Biểu thị hành động đã hoàn thành.",
        "examples": [
          {"cn": "我吃了。", "py": "Wǒ chī le.", "vi": "Tôi ăn rồi."},
        ]
      },
      {
        "title": "过 (guò) — Kinh nghiệm",
        "pattern": "Động từ + 过",
        "explain": "Biểu thị kinh nghiệm đã trải qua.",
        "examples": [
          {"cn": "我去过北京。", "py": "Wǒ qùguò Běijīng.", "vi": "Tôi đã từng đi Bắc Kinh."},
        ]
      },
      {
        "title": "在 (zài) — Đang làm",
        "pattern": "在 + Động từ",
        "explain": "Biểu thị hành động đang xảy ra.",
        "examples": [
          {"cn": "我在学习。", "py": "Wǒ zài xuéxí.", "vi": "Tôi đang học."},
        ]
      },
      {
        "title": "比 (bǐ) — So sánh",
        "pattern": "A + 比 + B + Tính từ",
        "explain": "Cấu trúc so sánh hơn.",
        "examples": [
          {"cn": "他比我高。", "py": "Tā bǐ wǒ gāo.", "vi": "Anh ấy cao hơn tôi."},
        ]
      },
    ],
    "HSK 3": [
      {
        "title": "把 (bǎ) — Câu Bả",
        "pattern": "把 + Tân ngữ + Động từ + Bổ ngữ",
        "explain": "Nhấn mạnh tác động lên đối tượng.",
        "examples": [
          {"cn": "把门关上。", "py": "Bǎ mén guānshàng.", "vi": "Đóng cửa lại."},
        ]
      },
      {
        "title": "被 (bèi) — Bị động",
        "pattern": "Chủ ngữ + 被 + (Tác nhân) + Động từ",
        "explain": "Câu bị động trong tiếng Trung.",
        "examples": [
          {"cn": "书被他拿走了。", "py": "Shū bèi tā ná zǒu le.", "vi": "Sách bị anh ấy lấy đi rồi."},
        ]
      },
      {
        "title": "越来越 (yuè lái yuè) — Càng ngày càng",
        "pattern": "越来越 + Tính từ",
        "explain": "Biểu thị mức độ tăng dần.",
        "examples": [
          {"cn": "天气越来越冷。", "py": "Tiānqì yuè lái yuè lěng.", "vi": "Thời tiết càng ngày càng lạnh."},
        ]
      },
    ],
  };

  bool _isLoadingLessons = true;
  String _selectedLevel = "HSK 1";

  void _analyzeText() async {
    if (_textController.text.trim().isEmpty) return;
    setState(() => _isAnalyzing = true);

    try {
      final result = await GrammarAiService.checkGrammar(_textController.text.trim());
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _result = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _result = {
            "score": 0.0,
            "errors": [
              {"type": "Lỗi", "explanation": e.toString()}
            ],
            "correction": _textController.text,
            "suggestions": [],
            "style_tips": "Vui lòng thử lại sau."
          };
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGrammarLessons();
  }

  Future<void> _loadGrammarLessons() async {
    try {
      final baseUrl = AppConfig.apiBaseUrl;
      final response = await http
          .get(Uri.parse('$baseUrl/grammar'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data.isNotEmpty) {
          final Map<String, List<Map<String, dynamic>>> newLessons = {};

          for (var item in data) {
            String level = item['level']?.toString().toUpperCase() ?? 'HSK 1';
            if (!newLessons.containsKey(level)) {
              newLessons[level] = [];
            }

            // Parse examples array (kiểu jsonb từ API mới)
            List<Map<String, String>> parsedExamples = [];
            if (item['examples'] is List) {
              for (var ex in (item['examples'] as List)) {
                if (ex is Map) {
                  parsedExamples.add({
                    "cn": ex['cn']?.toString() ?? "",
                    "py": ex['py']?.toString() ?? "",
                    "vi": ex['vi']?.toString() ?? "",
                  });
                }
              }
            } else if (item['examples'] is String &&
                (item['examples'] as String).isNotEmpty) {
              // Hỗ trợ fallback từ chuỗi cũ nếu có
              final rawExample = item['examples'] as String;
              final parts = rawExample.split('/');
              parsedExamples.add({
                "cn": parts.isNotEmpty ? parts[0].trim() : rawExample,
                "py": parts.length > 1 ? parts[1].trim() : "",
                "vi": parts.length > 2 ? parts[2].trim() : "",
              });
            }

            newLessons[level]!.add({
              "title": item['title'] ?? "",
              "pattern": item['pattern'] ?? item['title'] ?? "",
              "explain": item['explanation'] ?? "",
              "examples": parsedExamples,
            });
          }

          if (mounted) {
            setState(() {
              _grammarLessons = newLessons;
              if (!_grammarLessons.containsKey(_selectedLevel)) {
                _selectedLevel = _grammarLessons.keys.first;
              }
              _isLoadingLessons = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("API Grammar load failed, using fallback: $e");
    }

    if (mounted) {
      setState(() => _isLoadingLessons = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ngữ pháp tiếng Trung"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD32F2F),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD32F2F),
          tabs: const [
            Tab(text: "Bài học"),
            Tab(text: "Kiểm tra"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLessonsTab(),
          _buildCheckerTab(),
        ],
      ),
    );
  }

  Widget _buildLessonsTab() {
    if (_isLoadingLessons) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFD32F2F)));
    }
    final List<Map<String, dynamic>> lessons =
        _grammarLessons[_selectedLevel] ?? [];
    return Column(
      children: [
        // Level selector
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: _grammarLessons.keys.map((level) {
              final bool isSelected = level == _selectedLevel;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(level),
                  selected: isSelected,
                  selectedColor: const Color(0xFFD32F2F),
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold),
                  onSelected: (_) =>
                      setState(() => _selectedLevel = level),
                ),
              );
            }).toList(),
          ),
        ),
        // Lessons list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              return _buildLessonCard(lessons[i], i);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson, int index) {
    final List<dynamic> examples = lesson['examples'] ?? [];
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
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                    child: Text("${index + 1}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD32F2F)))),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(lesson['title']?.toString() ?? "",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          // Pattern
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(8)),
            child: Text("📐 ${lesson['pattern'] ?? ""}",
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7B1FA2))),
          ),
          const SizedBox(height: 12),
          // Examples
          if (examples.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: examples.map<Widget>((ex) {
                  final cn = ex['cn']?.toString() ?? "";
                  final py = ex['py']?.toString() ?? "";
                  final vi = ex['vi']?.toString() ?? "";
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cn.isNotEmpty)
                          Text(cn,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                        if (py.isNotEmpty)
                          Text(py,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey)),
                        if (vi.isNotEmpty)
                          Text(vi,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.brown,
                                  fontStyle: FontStyle.italic)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8),
          // Explanation
          Text("💡 ${lesson['explain'] ?? ""}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildCheckerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Nhập câu tiếng Trung cần kiểm tra...\n(VD: 我去昨天学校)",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _analyzeText,
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_outline),
            label: Text(
                _isAnalyzing ? "Đang phân tích..." : "Kiểm tra Ngữ pháp"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              foregroundColor: Colors.white,
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            // Score Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: () {
                    final s = (_result!['score'] as num).toDouble();
                    if (s >= 85) {
                      return [
                        const Color(0xFF2E7D32),
                        const Color(0xFF66BB6A)
                      ];
                    }
                    if (s >= 65) {
                      return [
                        const Color(0xFF1565C0),
                        const Color(0xFF42A5F5)
                      ];
                    }
                    if (s >= 45) {
                      return [
                        const Color(0xFFE65100),
                        const Color(0xFFFFA726)
                      ];
                    }
                    return [
                      const Color(0xFFB71C1C),
                      const Color(0xFFEF5350)
                    ];
                  }(),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text("Độ chính xác",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                  "${(_result!['score'] as num).toInt()}",
                                  style: const TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.0)),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(" / 100",
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16)),
                              ),
                            ],
                          ),
                          Text(
                            () {
                              final s =
                                  (_result!['score'] as num).toDouble();
                              if (s >= 90) return "✨ Hoàn hảo!";
                              if (s >= 75) return "🌟 Rất tốt";
                              if (s >= 55) return "👍 Khá ổn";
                              if (s >= 35) return "⚠️ Cần sửa";
                              return "❌ Nhiều lỗi";
                            }(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value:
                          (_result!['score'] as num).toDouble() / 100,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Correction Box
            if ((_result!['score'] as num) < 90)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_fix_high,
                            color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text("Câu sửa lại chuẩn xác:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_result!['correction'] is Map) ...[
                      SelectableText(
                          _result!['correction']['cn'] ?? '',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black87)),
                      if ((_result!['correction']['py'] ?? '')
                          .toString()
                          .isNotEmpty)
                        Text(_result!['correction']['py'],
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      if ((_result!['correction']['vi'] ?? '')
                          .toString()
                          .isNotEmpty)
                        Text(_result!['correction']['vi'],
                            style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.brown)),
                    ] else ...[
                      SelectableText(
                          _result!['correction']?.toString() ?? '',
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black87)),
                    ]
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Errors List
            if (_result!['errors'] != null &&
                (_result!['errors'] as List).isNotEmpty)
              ...(_result!['errors'] as List).map((e) => Card(
                    elevation: 0,
                    color: const Color(0xFFFFF4E5),
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Color(0xFFFFCC80)),
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.deepOrange),
                            const SizedBox(width: 8),
                            Text(e['type'] ?? 'Lỗi cơ bản',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange)),
                          ]),
                          const SizedBox(height: 8),
                          Text(e['explanation'] ?? '',
                              style:
                                  const TextStyle(color: Colors.black87)),
                        ],
                      ),
                    ),
                  )),

            const SizedBox(height: 12),
            // Alternatives / Suggestions
            if (_result!['suggestions'] != null &&
                (_result!['suggestions'] as List).isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[200]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text("Cách diễn đạt gợi ý:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...(_result!['suggestions'] as List).map((s) {
                      if (s is Map) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText("• ${s['cn'] ?? ''}",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500)),
                              if ((s['py'] ?? '').toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Text(s['py'],
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey)),
                                ),
                              if ((s['vi'] ?? '').toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Text(s['vi'],
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.brown)),
                                ),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: SelectableText("• $s",
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black87)),
                        );
                      }
                    }),
                  ],
                ),
              ),

            const SizedBox(height: 16),
            // General Style Tips
            if (_result!['style_tips'] != null)
              Text("💡 ${_result!['style_tips']}",
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.grey)),

            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }
}

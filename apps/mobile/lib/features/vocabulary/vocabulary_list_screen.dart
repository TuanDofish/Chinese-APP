import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/features/vocabulary/vocabulary_detail_screen.dart';
import 'package:mobile/core/services/progress_service.dart';
import 'package:mobile/features/games/quiz_screen.dart';

class VocabularyListScreen extends StatefulWidget {
  const VocabularyListScreen({super.key});

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _allWords = [];
  String _selectedLevel = 'HSK 1';
  bool _isLoading = true;
  final ProgressService _progressService = ProgressService();
  Set<String> _learnedWords = {};
  bool _sortByProgressDesc = true;
  late TabController _tabController;

  final List<String> _levels = ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'];

  static const Map<String, Map<String, dynamic>> _levelMeta = {
    'HSK 1': {
      'color': Color(0xFFFFA726),
      'desc': 'Nắm vững 150 từ vựng cơ bản, dễ dàng bắt đầu học tiếng Trung!',
      'total': 150,
    },
    'HSK 2': {
      'color': Color(0xFF42A5F5),
      'desc':
          'Mở rộng 150 từ vựng giao tiếp hàng ngày, tự tin trò chuyện đơn giản!',
      'total': 150,
    },
    'HSK 3': {
      'color': Color(0xFF66BB6A),
      'desc': 'Chinh phục 300 từ vựng nâng cao để diễn đạt ý tưởng của mình!',
      'total': 300,
    },
    'HSK 4': {
      'color': Color(0xFFAB47BC),
      'desc':
          'Làm chủ 600 từ vựng chuyên sâu, đọc hiểu và viết bài tiếng Trung!',
      'total': 600,
    },
  };

  // === TOPIC DEFINITIONS ===
  static final Map<String, List<Map<String, dynamic>>> _topicMap = {
    // ─────────────────────── HSK 1 ───────────────────────
    "HSK 1": [
      {
        "id": "hsk1_country",
        "name": "Quốc gia",
        "imageFile": "country.png",
        "words": ["中国", "北京", "人", "去", "来", "认识", "好"],
      },
      {
        "id": "hsk1_number",
        "name": "Số đếm",
        "imageFile": "number.png",
        "words": ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "零", "个"],
      },
      {
        "id": "hsk1_shopping",
        "name": "Mua sắm",
        "imageFile": "shopping.png",
        "words": ["买", "东西", "多少", "钱", "块", "衣服", "苹果", "商店", "太"],
      },
      {
        "id": "hsk1_daily",
        "name": "Đồ dùng hàng ngày",
        "imageFile": "daily.png",
        "words": ["书", "桌子", "椅子", "电脑", "电视", "杯子", "看", "喜欢"],
      },
      {
        "id": "hsk1_pet",
        "name": "Thú cưng",
        "imageFile": "pet.png",
        "words": ["狗", "猫", "大", "小", "漂亮", "爱", "叫"],
      },
    ],

    // ─────────────────────── HSK 2 ───────────────────────
    "HSK 2": [
      {
        "id": "hsk2_family",
        "name": "Gia đình mở rộng",
        "imageFile": "hsk2_family.png",
        "words": [
          "丈夫",
          "妻子",
          "哥哥",
          "姐姐",
          "弟弟",
          "妹妹",
          "孩子",
          "男人",
          "女人",
          "爷爷",
          "奶奶",
          "儿子",
        ],
      },
      {
        "id": "hsk2_body",
        "name": "Cơ thể & Sức khỏe",
        "imageFile": "hsk2_body.png",
        "words": [
          "眼睛",
          "耳朵",
          "鼻子",
          "嘴",
          "头",
          "手",
          "脚",
          "身体",
          "病",
          "药",
          "医生",
          "医院",
        ],
      },
      {
        "id": "hsk2_emotion",
        "name": "Cảm xúc",
        "imageFile": "hsk2_emotion.png",
        "words": ["高兴", "生气", "快乐", "开心", "累", "忙", "希望", "觉得", "喜欢", "爱"],
      },
      {
        "id": "hsk2_school",
        "name": "Trường học",
        "imageFile": "hsk2_school.png",
        "words": [
          "考试",
          "问题",
          "回答",
          "帮助",
          "教",
          "懂",
          "问",
          "班",
          "课",
          "黑板",
          "铅笔",
          "历史",
          "数学",
        ],
      },
      {
        "id": "hsk2_food",
        "name": "Ăn uống & Mua sắm",
        "imageFile": "hsk2_food.png",
        "words": [
          "鸡蛋",
          "鱼",
          "牛奶",
          "面条",
          "蛋糕",
          "西瓜",
          "便宜",
          "贵",
          "卖",
          "超市",
          "服务员",
          "价格",
        ],
      },
      {
        "id": "hsk2_weather",
        "name": "Thời tiết",
        "imageFile": "hsk2_weather.png",
        "words": [
          "天气",
          "晴",
          "阴",
          "下雨",
          "雪",
          "风",
          "春",
          "夏",
          "秋",
          "冬",
          "冷",
          "热",
          "云",
          "花",
          "树",
        ],
      },
      {
        "id": "hsk2_transport",
        "name": "Giao thông & Du lịch",
        "imageFile": "hsk2_transport.png",
        "words": [
          "公共汽车",
          "地铁",
          "自行车",
          "飞机",
          "飞机场",
          "护照",
          "旅游",
          "离开",
          "到",
          "近",
          "远",
        ],
      },
      {
        "id": "hsk2_verb",
        "name": "Động từ thông dụng",
        "imageFile": "hsk2_verb.png",
        "words": [
          "跑",
          "走",
          "知道",
          "给",
          "告诉",
          "找",
          "让",
          "开始",
          "完成",
          "准备",
          "等",
          "打",
          "跳",
          "唱",
          "跳舞",
        ],
      },
      {
        "id": "hsk2_color",
        "name": "Màu sắc & Hình dáng",
        "imageFile": "hsk2_color.png",
        "words": [
          "颜色",
          "红",
          "白",
          "黑",
          "绿",
          "黄",
          "蓝",
          "新",
          "旧",
          "长",
          "短",
          "高",
          "矮",
          "胖",
          "瘦",
        ],
      },
      {
        "id": "hsk2_direction",
        "name": "Phương hướng & Vị trí",
        "imageFile": "hsk2_direction.png",
        "words": [
          "左",
          "右",
          "上",
          "下",
          "里",
          "外",
          "旁边",
          "中间",
          "前",
          "后",
          "东",
          "西",
          "南",
          "北",
        ],
      },
    ],

    // ─────────────────────── HSK 3 ───────────────────────
    "HSK 3": [
      {
        "id": "hsk3_work",
        "name": "Công việc & Nghề nghiệp",
        "imageFile": "hsk3_work.png",
        "words": [
          "办公室",
          "经理",
          "会议",
          "工资",
          "公司",
          "银行",
          "护士",
          "警察",
          "记者",
          "律师",
          "翻译",
          "工程师",
          "服务员",
          "厨师",
        ],
      },
      {
        "id": "hsk3_home",
        "name": "Nhà cửa & Đồ đạc",
        "imageFile": "hsk3_home.png",
        "words": [
          "客厅",
          "卧室",
          "厨房",
          "卫生间",
          "阳台",
          "冰箱",
          "空调",
          "洗衣机",
          "沙发",
          "镜子",
          "钥匙",
          "电梯",
          "灯",
          "床",
        ],
      },
      {
        "id": "hsk3_emotion",
        "name": "Cảm xúc & Tâm lý",
        "imageFile": "hsk3_emotion.png",
        "words": [
          "担心",
          "害怕",
          "难过",
          "着急",
          "放心",
          "感觉",
          "态度",
          "幸福",
          "遗憾",
          "安静",
          "紧张",
          "满意",
          "骄傲",
          "难为情",
        ],
      },
      {
        "id": "hsk3_tech",
        "name": "Khoa học & Công nghệ",
        "imageFile": "hsk3_tech.png",
        "words": [
          "电子邮件",
          "网站",
          "密码",
          "信息",
          "打印",
          "技术",
          "科学",
          "研究",
          "发明",
          "机器",
          "网络",
          "手机",
          "电脑",
          "智能",
        ],
      },
      {
        "id": "hsk3_culture",
        "name": "Văn hóa & Giải trí",
        "imageFile": "hsk3_culture.png",
        "words": [
          "音乐",
          "电影",
          "节目",
          "新闻",
          "故事",
          "比赛",
          "运动",
          "游戏",
          "爱好",
          "唱歌",
          "跳舞",
          "画",
          "画画",
          "摄影",
        ],
      },
      {
        "id": "hsk3_food",
        "name": "Ẩm thực nâng cao",
        "imageFile": "hsk3_food.png",
        "words": [
          "饺子",
          "烤鸭",
          "豆腐",
          "包子",
          "火锅",
          "米饭",
          "面条",
          "汤",
          "饮料",
          "咖啡",
          "啤酒",
          "糖",
          "盐",
          "辣",
        ],
      },
      {
        "id": "hsk3_travel",
        "name": "Du lịch & Khám phá",
        "imageFile": "hsk3_travel.png",
        "words": [
          "旅游",
          "地图",
          "景色",
          "参观",
          "介绍",
          "游览",
          "博物馆",
          "公园",
          "海",
          "山",
          "河",
          "国家",
          "外国",
          "风景",
        ],
      },
      {
        "id": "hsk3_sports",
        "name": "Thể thao",
        "imageFile": "hsk3_sports.png",
        "words": [
          "运动",
          "篮球",
          "足球",
          "游泳",
          "跑步",
          "锻炼",
          "参加",
          "赢",
          "输",
          "比赛",
          "队",
          "运动员",
          "教练",
        ],
      },
      {
        "id": "hsk3_shopping",
        "name": "Mua sắm",
        "imageFile": "hsk3_shopping.png",
        "words": [
          "商场",
          "超市",
          "品牌",
          "打折",
          "便宜",
          "贵",
          "价格",
          "收据",
          "退货",
          "换",
          "付钱",
          "信用卡",
          "现金",
        ],
      },
      {
        "id": "hsk3_grammar",
        "name": "Hư từ & Trạng từ",
        "imageFile": "hsk3_grammar.png",
        "words": [
          "因为",
          "所以",
          "虽然",
          "但是",
          "如果",
          "虽然",
          "而且",
          "一定",
          "可能",
          "应该",
          "必须",
          "已经",
          "还",
          "再",
          "又",
          "一起",
        ],
      },
    ],

    // ─────────────────────── HSK 4 ───────────────────────
    "HSK 4": [
      {
        "id": "hsk4_business",
        "name": "Kinh doanh & Kinh tế",
        "imageFile": "hsk4_business.png",
        "words": [
          "经济",
          "市场",
          "竞争",
          "顾客",
          "商品",
          "广告",
          "品牌",
          "投资",
          "利润",
          "合同",
          "价值",
          "资金",
          "营业",
          "贸易",
        ],
      },
      {
        "id": "hsk4_law",
        "name": "Pháp luật & Xã hội",
        "imageFile": "hsk4_law.png",
        "words": [
          "法律",
          "权利",
          "义务",
          "政府",
          "政策",
          "规定",
          "违反",
          "罚款",
          "保护",
          "制度",
          "民主",
          "公民",
          "案件",
          "律师",
        ],
      },
      {
        "id": "hsk4_health",
        "name": "Y tế & Sức khỏe",
        "imageFile": "hsk4_health.png",
        "words": [
          "健康",
          "疾病",
          "治疗",
          "手术",
          "检查",
          "药物",
          "症状",
          "预防",
          "保险",
          "急救",
          "医疗",
          "血压",
          "感冒",
          "发烧",
        ],
      },
      {
        "id": "hsk4_education",
        "name": "Giáo dục",
        "imageFile": "hsk4_education.png",
        "words": [
          "毕业",
          "专业",
          "学位",
          "论文",
          "奖学金",
          "教育",
          "知识",
          "能力",
          "经验",
          "培训",
          "申请",
          "大学",
          "研究生",
          "博士",
        ],
      },
      {
        "id": "hsk4_technology",
        "name": "Công nghệ hiện đại",
        "imageFile": "hsk4_technology.png",
        "words": [
          "人工智能",
          "互联网",
          "大数据",
          "软件",
          "应用",
          "平台",
          "系统",
          "数据",
          "算法",
          "创新",
          "开发",
          "程序员",
          "科技",
        ],
      },
      {
        "id": "hsk4_environment",
        "name": "Môi trường",
        "imageFile": "hsk4_environment.png",
        "words": [
          "环境",
          "污染",
          "保护",
          "资源",
          "能源",
          "气候",
          "生态",
          "回收",
          "节约",
          "自然",
          "垃圾",
          "废水",
          "噪音",
          "绿色",
        ],
      },
      {
        "id": "hsk4_media",
        "name": "Truyền thông & Mạng xã hội",
        "imageFile": "hsk4_media.png",
        "words": [
          "媒体",
          "报道",
          "采访",
          "发布",
          "信息",
          "评论",
          "分享",
          "直播",
          "网络",
          "平台",
          "用户",
          "内容",
          "视频",
          "头条",
        ],
      },
      {
        "id": "hsk4_society",
        "name": "Xã hội & Cuộc sống",
        "imageFile": "hsk4_society.png",
        "words": [
          "社会",
          "生活",
          "习惯",
          "文化",
          "传统",
          "风俗",
          "人口",
          "城市",
          "农村",
          "发展",
          "进步",
          "变化",
          "影响",
          "意义",
        ],
      },
      {
        "id": "hsk4_psychology",
        "name": "Tâm lý & Tư duy",
        "imageFile": "hsk4_psychology.png",
        "words": [
          "思想",
          "态度",
          "观点",
          "分析",
          "判断",
          "推理",
          "逻辑",
          "目标",
          "计划",
          "决定",
          "选择",
          "考虑",
          "理解",
          "接受",
        ],
      },
      {
        "id": "hsk4_art",
        "name": "Nghệ thuật & Văn hóa",
        "imageFile": "hsk4_art.png",
        "words": [
          "文化",
          "艺术",
          "音乐",
          "绘画",
          "电影",
          "文学",
          "诗歌",
          "舞蹈",
          "摄影",
          "建筑",
          "风格",
          "创作",
          "欣赏",
          "表达",
        ],
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _levels.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedLevel = _levels[_tabController.index]);
      }
    });
    _loadData();
    _loadProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final learned = await _progressService.getLearnedWords();
    if (mounted) setState(() => _learnedWords = learned);
  }

  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/hsk_complete.json',
      );
      final List<dynamic> data = json.decode(response);
      if (mounted) {
        setState(() {
          _allWords = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading vocab JSON: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic>? _findWordData(String simplified) {
    try {
      return _allWords.firstWhere((w) => w['simplified'] == simplified)
          as Map<String, dynamic>;
    } catch (_) {
      return {"simplified": simplified, "forms": []};
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    List<Map<String, dynamic>> topics = List<Map<String, dynamic>>.from(
      _topicMap[_selectedLevel] ?? const [],
    );
    final meta = _levelMeta[_selectedLevel]!;
    final Color levelColor = meta['color'] as Color;
    final int totalWords = meta['total'] as int;

    // Calculate how many learned words belong to this level
    final allLevelWords = topics
        .expand((t) => (t['words'] as List).cast<String>())
        .toSet();
    final learnedInLevel = _learnedWords.intersection(allLevelWords).length;

    if (_sortByProgressDesc) {
      topics.sort((a, b) {
        final aWords = List<String>.from(a['words'] as List);
        final bWords = List<String>.from(b['words'] as List);
        final aLearned = aWords.where(_learnedWords.contains).length;
        final bLearned = bWords.where(_learnedWords.contains).length;
        final aRatio = aWords.isEmpty ? 0.0 : aLearned / aWords.length;
        final bRatio = bWords.isEmpty ? 0.0 : bLearned / bWords.length;
        final cmp = bRatio.compareTo(aRatio);
        if (cmp != 0) return cmp;
        return (a['name'] as String).compareTo(b['name'] as String);
      });
    }

    return Column(
      children: [
        // ── Tab Bar ──
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: _levels.map((l) => Tab(text: l)).toList(),
            labelColor: levelColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: levelColor,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            isScrollable: false,
          ),
        ),

        // ── Level Header Banner ──
        _buildLevelBanner(
          levelColor,
          learnedInLevel,
          totalWords,
          meta['desc'] as String,
        ),

        // ── Topic List ──
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: topics.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final topic = topics[index];
            final List<String> wordList = List<String>.from(topic['words']);
            final learnedCount = wordList
                .where((w) => _learnedWords.contains(w))
                .length;
            final progress = wordList.isNotEmpty
                ? learnedCount / wordList.length
                : 0.0;
            final bool completed = progress >= 1.0;

            return _buildTopicCard(
              index: index + 1,
              topic: topic,
              wordList: wordList,
              learnedCount: learnedCount,
              progress: progress,
              completed: completed,
              levelColor: levelColor,
            );
          },
        ),
      ],
    );
  }

  Widget _buildLevelBanner(Color color, int learned, int total, String desc) {
    double progress = total > 0 ? (learned / total).clamp(0.0, 1.0) : 0.0;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _selectedLevel,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$learned/$total từ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () =>
                    setState(() => _sortByProgressDesc = !_sortByProgressDesc),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _sortByProgressDesc ? Icons.swap_vert : Icons.sort_by_alpha,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Moi chu de: Flashcard + nghe + quiz mini game.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard({
    required int index,
    required Map<String, dynamic> topic,
    required List<String> wordList,
    required int learnedCount,
    required double progress,
    required bool completed,
    required Color levelColor,
  }) {
    final String imageFile = topic['imageFile'] as String? ?? '';
    return GestureDetector(
      onTap: () => _navigateToDetail(wordList, topic['name']),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: completed
              ? Border.all(color: const Color(0xFF4CAF50), width: 2)
              : null,
        ),
        child: Row(
          children: [
            // ── Topic Image / Thumbnail ──
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: completed
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(
                      'assets/images/topics/$imageFile',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _TopicVisualFallback(
                            topicName: topic['name'] as String? ?? '',
                            levelColor: levelColor,
                            completed: completed,
                          ),
                    ),
                  ),
                ),
                // Number badge
                Positioned(
                  top: -6,
                  left: -6,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: completed ? const Color(0xFF4CAF50) : levelColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // ── Content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _TagPill(
                        label: 'Flashcard',
                        color: completed ? const Color(0xFF4CAF50) : levelColor,
                      ),
                      const SizedBox(width: 6),
                      _TagPill(label: 'Quiz', color: const Color(0xFF607D8B)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completed ? const Color(0xFF4CAF50) : levelColor,
                      ),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$learnedCount/${wordList.length} từ',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // ── Arrow indicator ──
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: completed ? const Color(0xFF4CAF50) : levelColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToDetail(
    List<String> wordList,
    String topicName,
  ) async {
    List<Map<String, dynamic>> unitWords = [];
    for (String w in wordList) {
      Map<String, dynamic>? data = _findWordData(w);
      if (data != null) unitWords.add(data);
    }
    if (unitWords.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VocabularyLearningFlow(
          words: unitWords,
          startIndex: 0,
          topicName: topicName,
        ),
      ),
    );
    _loadProgress();
  }
}

// ─────── Learning Flow ───────────────────────────────────────────────────────
class _TopicVisualFallback extends StatelessWidget {
  const _TopicVisualFallback({
    required this.topicName,
    required this.levelColor,
    required this.completed,
  });

  final String topicName;
  final Color levelColor;
  final bool completed;

  static const Map<String, IconData> _topicIconMap = {
    'quoc gia': Icons.flag_outlined,
    'so dem': Icons.pin_outlined,
    'mua sam': Icons.shopping_bag_outlined,
    'do dung hang ngay': Icons.home_work_outlined,
    'thu cung': Icons.pets_outlined,
    'gia dinh': Icons.family_restroom_outlined,
    'co the': Icons.health_and_safety_outlined,
    'cam xuc': Icons.emoji_emotions_outlined,
    'truong hoc': Icons.school_outlined,
    'an uong': Icons.local_dining_outlined,
    'thoi tiet': Icons.wb_sunny_outlined,
    'giao thong': Icons.directions_bus_outlined,
    'dong tu': Icons.run_circle_outlined,
    'mau sac': Icons.palette_outlined,
    'phuong huong': Icons.explore_outlined,
  };

  String _normalize(String text) {
    const map = {
      'á': 'a',
      'à': 'a',
      'ả': 'a',
      'Ã£': 'a',
      'ạ': 'a',
      'ă': 'a',
      'ắ': 'a',
      'ằ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'â': 'a',
      'ấ': 'a',
      'ầ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ậ': 'a',
      'é': 'e',
      'è': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ê': 'e',
      'ế': 'e',
      'ề': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ệ': 'e',
      'í': 'i',
      'ì': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ị': 'i',
      'ó': 'o',
      'ò': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ô': 'o',
      'ố': 'o',
      'ồ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ơ': 'o',
      'ớ': 'o',
      'ờ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ợ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ư': 'u',
      'ứ': 'u',
      'ừ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'ý': 'y',
      'ỳ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
      'đ': 'd',
    };
    final lower = text.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(map[char] ?? char);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final normalized = _normalize(topicName);
    IconData icon = Icons.image_outlined;
    for (final entry in _topicIconMap.entries) {
      if (normalized.contains(entry.key)) {
        icon = entry.value;
        break;
      }
    }

    final start = completed
        ? const Color(0xFFE8F5E9)
        : levelColor.withValues(alpha: 0.2);
    final end = completed
        ? const Color(0xFFDFF0E1)
        : levelColor.withValues(alpha: 0.35);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [start, end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          completed ? Icons.check_circle_outline : icon,
          color: completed ? const Color(0xFF4CAF50) : levelColor,
          size: 34,
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class VocabularyLearningFlow extends StatefulWidget {
  final List<dynamic> words;
  final int startIndex;
  final String topicName;

  const VocabularyLearningFlow({
    super.key,
    required this.words,
    required this.startIndex,
    required this.topicName,
  });

  @override
  State<VocabularyLearningFlow> createState() => _VocabularyLearningFlowState();
}

class _VocabularyLearningFlowState extends State<VocabularyLearningFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showPinyinGlobal = true;

  // Progress bar animation
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _pageController = PageController(initialPage: widget.startIndex);
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: (widget.startIndex + 1) / (widget.words.length + 1),
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
    _progressCtrl.forward();
  }

  void _onPageChanged(int i) {
    setState(() => _currentIndex = i);
    _progressAnim = Tween<double>(
      begin: _progressAnim.value,
      end: (i + 1) / (widget.words.length + 1),
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
    _progressCtrl.forward(from: 0);
  }

  void _goNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int totalPages = widget.words.length + 1; // +1 for quiz
    final bool isOnQuiz = _currentIndex >= widget.words.length;
    final int wordNum = isOnQuiz ? widget.words.length : _currentIndex + 1;
    const amberColor = Color(0xFFFFA726);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F0E8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top navigation bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  // Close button
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF1A1A2E),
                    ),
                    iconSize: 26,
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Progress bar
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedBuilder(
                        animation: _progressAnim,
                        builder: (context, child) => ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _progressAnim.value,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isOnQuiz ? const Color(0xFF4CAF50) : amberColor,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Step counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$wordNum/$totalPages',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  // Pinyin toggle (only for flashcard pages)
                  if (!isOnQuiz)
                    IconButton(
                      onPressed: () => setState(
                        () => _showPinyinGlobal = !_showPinyinGlobal,
                      ),
                      icon: Icon(
                        _showPinyinGlobal
                            ? Icons.translate_rounded
                            : Icons.translate_outlined,
                        size: 20,
                        color: _showPinyinGlobal ? amberColor : Colors.grey,
                      ),
                      tooltip: _showPinyinGlobal ? 'Ẩn Pinyin' : 'Hiện Pinyin',
                    )
                  else
                    const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // ── Page content ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalPages,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  if (index < widget.words.length) {
                    final word = widget.words[index];
                    return VocabularyDetailScreen(
                      word: word is Map<String, dynamic>
                          ? word
                          : {'simplified': word.toString(), 'forms': []},
                      showPinyin: _showPinyinGlobal,
                      onNext: _goNext,
                    );
                  } else {
                    return QuizScreen(
                      words: widget.words,
                      onFinish: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                Text('🎉', style: TextStyle(fontSize: 18)),
                                SizedBox(width: 8),
                                Text(
                                  'Chúc mừng! Hoàn thành chủ đề!',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF4CAF50),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

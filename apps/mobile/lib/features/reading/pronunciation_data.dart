// Dữ liệu câu luyện phát âm phân theo cấp độ HSK
// HSK 1-5, mỗi cấp có nhiều câu thông dụng

class HskSentence {
  final String chinese;
  final String pinyin;
  final String vietnamese;
  const HskSentence(this.chinese, this.pinyin, this.vietnamese);
}

class PronunciationData {
  static const Map<String, List<HskSentence>> sentences = {
    'HSK 1': _hsk1,
    'HSK 2': _hsk2,
    'HSK 3': _hsk3,
    'HSK 4': _hsk4,
    'HSK 5': _hsk5,
  };

  // ========== HSK 1: 100 câu thông dụng nhất ==========
  static const List<HskSentence> _hsk1 = [
    HskSentence("你好", "Nǐ hǎo", "Xin chào"),
    HskSentence("谢谢", "Xièxiè", "Cảm ơn"),
    HskSentence("对不起", "Duìbuqǐ", "Xin lỗi"),
    HskSentence("没关系", "Méiguānxi", "Không sao"),
    HskSentence("再见", "Zàijiàn", "Tạm biệt"),
    HskSentence("你好吗", "Nǐ hǎo ma", "Bạn có khỏe không?"),
    HskSentence("我很好", "Wǒ hěn hǎo", "Tôi rất khỏe"),
    HskSentence("你叫什么名字", "Nǐ jiào shénme míngzì", "Bạn tên là gì?"),
    HskSentence("我叫小明", "Wǒ jiào Xiǎomíng", "Tôi tên là Tiểu Minh"),
    HskSentence("你是哪国人", "Nǐ shì nǎ guó rén", "Bạn là người nước nào?"),
    HskSentence("我是越南人", "Wǒ shì Yuènán rén", "Tôi là người Việt Nam"),
    HskSentence("我是学生", "Wǒ shì xuésheng", "Tôi là học sinh"),
    HskSentence("他是老师", "Tā shì lǎoshī", "Anh ấy là giáo viên"),
    HskSentence("这是什么", "Zhè shì shénme", "Cái này là gì?"),
    HskSentence("这是书", "Zhè shì shū", "Đây là sách"),
    HskSentence("那是谁", "Nà shì shuí", "Đó là ai?"),
    HskSentence("那是我的朋友", "Nà shì wǒ de péngyou", "Đó là bạn của tôi"),
    HskSentence("我有一个哥哥", "Wǒ yǒu yí gè gēgē", "Tôi có một người anh trai"),
    HskSentence("他没有姐姐", "Tā méiyǒu jiějie", "Anh ấy không có chị gái"),
    HskSentence("你有几个朋友", "Nǐ yǒu jǐ gè péngyou", "Bạn có mấy người bạn?"),
    HskSentence("我很忙", "Wǒ hěn máng", "Tôi rất bận"),
    HskSentence("他不忙", "Tā bù máng", "Anh ấy không bận"),
    HskSentence("我喜欢中文", "Wǒ xǐhuān Zhōngwén", "Tôi thích tiếng Trung"),
    HskSentence("她很漂亮", "Tā hěn piàoliang", "Cô ấy rất xinh đẹp"),
    HskSentence("天气很好", "Tiānqì hěn hǎo", "Thời tiết rất đẹp"),
    HskSentence("今天很热", "Jīntiān hěn rè", "Hôm nay rất nóng"),
    HskSentence("昨天很冷", "Zuótiān hěn lěng", "Hôm qua rất lạnh"),
    HskSentence("明天下雨吗", "Míngtiān xià yǔ ma", "Ngày mai có mưa không?"),
    HskSentence("现在几点", "Xiànzài jǐ diǎn", "Bây giờ là mấy giờ?"),
    HskSentence("现在八点", "Xiànzài bā diǎn", "Bây giờ là 8 giờ"),
    HskSentence("你在哪里", "Nǐ zài nǎlǐ", "Bạn đang ở đâu?"),
    HskSentence("我在家", "Wǒ zài jiā", "Tôi đang ở nhà"),
    HskSentence("学校在哪里", "Xuéxiào zài nǎlǐ", "Trường học ở đâu?"),
    HskSentence("医院在右边", "Yīyuàn zài yòubiān", "Bệnh viện ở bên phải"),
    HskSentence("我去学校", "Wǒ qù xuéxiào", "Tôi đi đến trường"),
    HskSentence("他来我家", "Tā lái wǒ jiā", "Anh ấy đến nhà tôi"),
    HskSentence("你吃什么", "Nǐ chī shénme", "Bạn ăn gì?"),
    HskSentence("我吃米饭", "Wǒ chī mǐfàn", "Tôi ăn cơm"),
    HskSentence("你喝什么", "Nǐ hē shénme", "Bạn uống gì?"),
    HskSentence("我喝水", "Wǒ hē shuǐ", "Tôi uống nước"),
    HskSentence(
      "你会说中文吗",
      "Nǐ huì shuō Zhōngwén ma",
      "Bạn có biết nói tiếng Trung không?",
    ),
    HskSentence("我会说一点", "Wǒ huì shuō yìdiǎn", "Tôi biết nói một chút"),
    HskSentence(
      "请说慢一点",
      "Qǐng shuō màn yìdiǎn",
      "Vui lòng nói chậm hơn một chút",
    ),
    HskSentence(
      "请再说一遍",
      "Qǐng zài shuō yí biàn",
      "Vui lòng nói lại một lần nữa",
    ),
    HskSentence("我听不懂", "Wǒ tīng bù dǒng", "Tôi nghe không hiểu"),
    HskSentence("这个多少钱", "Zhège duōshao qián", "Cái này bao nhiêu tiền?"),
    HskSentence("太贵了", "Tài guì le", "Đắt quá"),
    HskSentence("便宜一点", "Piányí yìdiǎn", "Rẻ hơn một chút"),
    HskSentence("我要买这个", "Wǒ yào mǎi zhège", "Tôi muốn mua cái này"),
    HskSentence("我不要", "Wǒ bú yào", "Tôi không muốn"),
    HskSentence("厕所在哪里", "Cèsuǒ zài nǎlǐ", "Nhà vệ sinh ở đâu?"),
    HskSentence("我肚子疼", "Wǒ dùzi téng", "Tôi đau bụng"),
    HskSentence("我头疼", "Wǒ tóu téng", "Tôi đau đầu"),
    HskSentence("请帮帮我", "Qǐng bāng bāng wǒ", "Vui lòng giúp tôi"),
    HskSentence("没问题", "Méi wèntí", "Không có vấn đề gì"),
    HskSentence("好的", "Hǎo de", "Được rồi"),
    HskSentence("不好意思", "Bù hǎoyìsi", "Xin lỗi / Ngại quá"),
    HskSentence("我想睡觉", "Wǒ xiǎng shuìjiào", "Tôi muốn ngủ"),
    HskSentence("我饿了", "Wǒ è le", "Tôi đói rồi"),
    HskSentence("我渴了", "Wǒ kě le", "Tôi khát rồi"),
    HskSentence("我累了", "Wǒ lèi le", "Tôi mệt rồi"),
    HskSentence("加油", "Jiāyóu", "Cố lên"),
    HskSentence("你在做什么", "Nǐ zài zuò shénme", "Bạn đang làm gì?"),
    HskSentence("我在学习", "Wǒ zài xuéxí", "Tôi đang học"),
    HskSentence("我在看书", "Wǒ zài kàn shū", "Tôi đang đọc sách"),
    HskSentence("我在看电视", "Wǒ zài kàn diànshì", "Tôi đang xem tivi"),
    HskSentence("我在听音乐", "Wǒ zài tīng yīnyuè", "Tôi đang nghe nhạc"),
    HskSentence(
      "你家有几口人",
      "Nǐ jiā yǒu jǐ kǒu rén",
      "Gia đình bạn có mấy người?",
    ),
    HskSentence("我家有四口人", "Wǒ jiā yǒu sì kǒu rén", "Gia đình tôi có 4 người"),
    HskSentence("我爸爸是医生", "Wǒ bàba shì yīshēng", "Bố tôi là bác sĩ"),
    HskSentence("我妈妈很漂亮", "Wǒ māmā hěn piàoliang", "Mẹ tôi rất xinh"),
    HskSentence(
      "你喜欢什么运动",
      "Nǐ xǐhuān shénme yùndòng",
      "Bạn thích môn thể thao gì?",
    ),
    HskSentence("我喜欢打篮球", "Wǒ xǐhuān dǎ lánqiú", "Tôi thích chơi bóng rổ"),
    HskSentence("我喜欢踢足球", "Wǒ xǐhuān tī zúqiú", "Tôi thích đá bóng"),
    HskSentence("你的爱好是什么", "Nǐ de àihào shì shénme", "Sở thích của bạn là gì?"),
    HskSentence(
      "我的爱好是画画",
      "Wǒ de àihào shì huà huà",
      "Sở thích của tôi là vẽ tranh",
    ),
    HskSentence(
      "这本书多少钱",
      "Zhè běn shū duōshao qián",
      "Quyển sách này bao nhiêu tiền?",
    ),
    HskSentence("我不知道", "Wǒ bù zhīdào", "Tôi không biết"),
    HskSentence("我知道了", "Wǒ zhīdào le", "Tôi biết rồi"),
    HskSentence(
      "你去过中国吗",
      "Nǐ qùguò Zhōngguó ma",
      "Bạn đã từng đến Trung Quốc chưa?",
    ),
    HskSentence("我没去过", "Wǒ méi qùguò", "Tôi chưa đi"),
    HskSentence("中国很大", "Zhōngguó hěn dà", "Trung Quốc rất rộng lớn"),
    HskSentence("北京是首都", "Běijīng shì shǒudū", "Bắc Kinh là thủ đô"),
    HskSentence("我今年二十岁", "Wǒ jīnnián èrshí suì", "Năm nay tôi hai mươi tuổi"),
    HskSentence("你今年多大", "Nǐ jīnnián duō dà", "Năm nay bạn bao nhiêu tuổi?"),
    HskSentence(
      "我的生日是一月一号",
      "Wǒ de shēngrì shì yī yuè yī hào",
      "Sinh nhật tôi là ngày 1 tháng 1",
    ),
    HskSentence(
      "你的电话号码是多少",
      "Nǐ de diànhuà hàomǎ shì duōshao",
      "Số điện thoại của bạn là bao nhiêu?",
    ),
    HskSentence(
      "我的手机没有电了",
      "Wǒ de shǒujī méiyǒu diàn le",
      "Điện thoại tôi hết pin rồi",
    ),
    HskSentence("我要去超市", "Wǒ yào qù chāoshì", "Tôi muốn đi siêu thị"),
    HskSentence("我坐地铁去", "Wǒ zuò dìtiě qù", "Tôi đi bằng tàu điện ngầm"),
    HskSentence(
      "请问，地铁站在哪里",
      "Qǐngwèn, dìtiě zhàn zài nǎlǐ",
      "Xin hỏi, ga tàu điện ngầm ở đâu?",
    ),
    HskSentence(
      "我早上七点起床",
      "Wǒ zǎoshang qī diǎn qǐchuáng",
      "Buổi sáng tôi dậy lúc 7 giờ",
    ),
    HskSentence(
      "我晚上十一点睡觉",
      "Wǒ wǎnshang shíyī diǎn shuìjiào",
      "Tôi đi ngủ lúc 11 giờ tối",
    ),
    HskSentence("这道菜很好吃", "Zhè dào cài hěn hǎochī", "Món ăn này rất ngon"),
    HskSentence("太好吃了", "Tài hǎochī le", "Ngon quá"),
    HskSentence("我不会做饭", "Wǒ bú huì zuòfàn", "Tôi không biết nấu ăn"),
    HskSentence("祝你生日快乐", "Zhù nǐ shēngrì kuàilè", "Chúc bạn sinh nhật vui vẻ"),
    HskSentence("新年快乐", "Xīnnián kuàilè", "Chúc mừng năm mới"),
  ];

  // ========== HSK 2: 40 câu ==========
  static const List<HskSentence> _hsk2 = [
    HskSentence(
      "我每天都去学校",
      "Wǒ měitiān dōu qù xuéxiào",
      "Mỗi ngày tôi đều đi học",
    ),
    HskSentence("你昨天做什么了", "Nǐ zuótiān zuò shénme le", "Hôm qua bạn làm gì?"),
    HskSentence(
      "我昨天去图书馆了",
      "Wǒ zuótiān qù túshūguǎn le",
      "Hôm qua tôi đã đi thư viện",
    ),
    HskSentence("他比我高", "Tā bǐ wǒ gāo", "Anh ấy cao hơn tôi"),
    HskSentence(
      "这双鞋比那双贵",
      "Zhè shuāng xié bǐ nà shuāng guì",
      "Đôi giày này đắt hơn đôi kia",
    ),
    HskSentence(
      "你去过长城吗",
      "Nǐ qùguò Chángchéng ma",
      "Bạn đã từng đến Vạn Lý Trường Thành chưa?",
    ),
    HskSentence("我去过一次", "Wǒ qùguò yí cì", "Tôi đã đến một lần"),
    HskSentence("我在打电话", "Wǒ zài dǎ diànhuà", "Tôi đang gọi điện"),
    HskSentence("他正在吃饭", "Tā zhèngzài chīfàn", "Anh ấy đang ăn cơm"),
    HskSentence("我们一起去吧", "Wǒmen yìqǐ qù ba", "Chúng ta cùng đi nhé"),
    HskSentence("你能帮我吗", "Nǐ néng bāng wǒ ma", "Bạn có thể giúp tôi không?"),
    HskSentence("当然可以", "Dāngrán kěyǐ", "Tất nhiên được"),
    HskSentence("我有点累", "Wǒ yǒudiǎn lèi", "Tôi hơi mệt"),
    HskSentence(
      "你的中文说得很好",
      "Nǐ de Zhōngwén shuō de hěn hǎo",
      "Tiếng Trung của bạn nói rất tốt",
    ),
    HskSentence(
      "我学中文学了两年了",
      "Wǒ xué Zhōngwén xué le liǎng nián le",
      "Tôi học tiếng Trung được 2 năm rồi",
    ),
    HskSentence(
      "周末你一般做什么",
      "Zhōumò nǐ yìbān zuò shénme",
      "Cuối tuần bạn thường làm gì?",
    ),
    HskSentence(
      "我喜欢在家看电影",
      "Wǒ xǐhuān zài jiā kàn diànyǐng",
      "Tôi thích xem phim ở nhà",
    ),
    HskSentence(
      "你喜欢看什么类型的电影",
      "Nǐ xǐhuān kàn shénme lèixíng de diànyǐng",
      "Bạn thích xem loại phim gì?",
    ),
    HskSentence(
      "我喜欢看动作片",
      "Wǒ xǐhuān kàn dòngzuò piàn",
      "Tôi thích xem phim hành động",
    ),
    HskSentence(
      "这个词是什么意思",
      "Zhège cí shì shénme yìsi",
      "Từ này có nghĩa là gì?",
    ),
    HskSentence("我不太明白", "Wǒ bú tài míngbái", "Tôi không hiểu lắm"),
    HskSentence(
      "你能解释一下吗",
      "Nǐ néng jiěshì yíxià ma",
      "Bạn có thể giải thích không?",
    ),
    HskSentence(
      "我需要练习说中文",
      "Wǒ xūyào liànxí shuō Zhōngwén",
      "Tôi cần luyện nói tiếng Trung",
    ),
    HskSentence("你想去哪里玩", "Nǐ xiǎng qù nǎlǐ wán", "Bạn muốn đi đâu chơi?"),
    HskSentence("我想去海边", "Wǒ xiǎng qù hǎibiān", "Tôi muốn đi bãi biển"),
    HskSentence(
      "天气预报说明天下雨",
      "Tiānqì yùbào shuō míngtiān xià yǔ",
      "Dự báo thời tiết nói ngày mai sẽ mưa",
    ),
    HskSentence(
      "请问，附近有超市吗",
      "Qǐngwèn, fùjìn yǒu chāoshì ma",
      "Xin hỏi, gần đây có siêu thị không?",
    ),
    HskSentence(
      "向前走两百米就到了",
      "Xiàng qián zǒu liǎng bǎi mǐ jiù dào le",
      "Đi thẳng 200m là tới",
    ),
    HskSentence(
      "我帮你拿行李吧",
      "Wǒ bāng nǐ ná xínglǐ ba",
      "Để tôi giúp bạn xách hành lý nhé",
    ),
    HskSentence("你带伞了吗", "Nǐ dài sǎn le ma", "Bạn mang dù chưa?"),
    HskSentence("我忘带了", "Wǒ wàng dài le", "Tôi quên mang rồi"),
    HskSentence(
      "没关系，我有两把",
      "Méiguānxi, wǒ yǒu liǎng bǎ",
      "Không sao, tôi có hai cái",
    ),
    HskSentence(
      "这家餐厅的菜很好吃",
      "Zhè jiā cāntīng de cài hěn hǎochī",
      "Đồ ăn ở nhà hàng này rất ngon",
    ),
    HskSentence(
      "下次我们一起来",
      "Xià cì wǒmen yìqǐ lái",
      "Lần sau chúng ta cùng đến",
    ),
    HskSentence(
      "我对中国文化很感兴趣",
      "Wǒ duì Zhōngguó wénhuà hěn gǎn xìngqù",
      "Tôi rất hứng thú với văn hóa Trung Quốc",
    ),
    HskSentence(
      "中国的历史很悠久",
      "Zhōngguó de lìshǐ hěn yōujiǔ",
      "Lịch sử Trung Quốc rất lâu dài",
    ),
    HskSentence(
      "我喜欢吃中国菜",
      "Wǒ xǐhuān chī Zhōngguó cài",
      "Tôi thích ăn đồ ăn Trung Quốc",
    ),
    HskSentence(
      "你最喜欢哪道菜",
      "Nǐ zuì xǐhuān nǎ dào cài",
      "Bạn thích món nào nhất?",
    ),
    HskSentence(
      "我最喜欢吃饺子",
      "Wǒ zuì xǐhuān chī jiǎozi",
      "Tôi thích ăn sủi cảo nhất",
    ),
    HskSentence(
      "这里的冬天非常冷",
      "Zhèlǐ de dōngtiān fēicháng lěng",
      "Mùa đông ở đây rất lạnh",
    ),
  ];

  // ========== HSK 3: 35 câu ==========
  static const List<HskSentence> _hsk3 = [
    HskSentence(
      "我在北京学习汉语",
      "Wǒ zài Běijīng xuéxí Hànyǔ",
      "Tôi đang học tiếng Trung tại Bắc Kinh",
    ),
    HskSentence(
      "学习语言需要很多时间",
      "Xuéxí yǔyán xūyào hěnduō shíjiān",
      "Học ngôn ngữ cần rất nhiều thời gian",
    ),
    HskSentence(
      "把这本书还给图书馆",
      "Bǎ zhè běn shū huán gěi túshūguǎn",
      "Trả quyển sách này cho thư viện",
    ),
    HskSentence("书被他拿走了", "Shū bèi tā ná zǒu le", "Sách bị anh ấy lấy đi rồi"),
    HskSentence(
      "天气越来越冷了",
      "Tiānqì yuè lái yuè lěng le",
      "Thời tiết ngày càng lạnh hơn",
    ),
    HskSentence(
      "他不但会说英语，还会说法语",
      "Tā bùdàn huì shuō Yīngyǔ, hái huì shuō Fǎyǔ",
      "Anh ấy không những biết nói tiếng Anh mà còn biết tiếng Pháp",
    ),
    HskSentence(
      "虽然下雨了，但是我还是去了",
      "Suīrán xià yǔ le, dànshì wǒ háishi qù le",
      "Mặc dù trời mưa, nhưng tôi vẫn đi",
    ),
    HskSentence(
      "既然你决定了，就去做吧",
      "Jìrán nǐ juédìng le, jiù qù zuò ba",
      "Đã quyết định rồi thì hãy đi làm đi",
    ),
    HskSentence(
      "只有努力，才能成功",
      "Zhǐyǒu nǔlì, cáinéng chénggōng",
      "Chỉ có cố gắng mới có thể thành công",
    ),
    HskSentence(
      "如果明天天气好，我们就去爬山",
      "Rúguǒ míngtiān tiānqì hǎo, wǒmen jiù qù páshān",
      "Nếu ngày mai thời tiết đẹp, chúng ta sẽ đi leo núi",
    ),
    HskSentence(
      "我已经等了他一个小时了",
      "Wǒ yǐjīng děng le tā yí gè xiǎoshí le",
      "Tôi đã đợi anh ấy một tiếng đồng hồ rồi",
    ),
    HskSentence("他刚刚离开了", "Tā gānggāng lí kāi le", "Anh ấy vừa mới rời đi"),
    HskSentence(
      "这个问题比较复杂",
      "Zhège wèntí bǐjiào fùzá",
      "Vấn đề này tương đối phức tạp",
    ),
    HskSentence(
      "我对这件事情不太了解",
      "Wǒ duì zhè jiàn shìqíng bú tài liǎojiě",
      "Tôi không hiểu rõ lắm về vấn đề này",
    ),
    HskSentence(
      "请你帮我翻译一下",
      "Qǐng nǐ bāng wǒ fānyì yíxià",
      "Nhờ bạn dịch giúp tôi một chút",
    ),
    HskSentence("这个词怎么用", "Zhège cí zěnme yòng", "Từ này dùng như thế nào?"),
    HskSentence(
      "你能给我举个例子吗",
      "Nǐ néng gěi wǒ jǔ gè lìzi ma",
      "Bạn có thể cho tôi một ví dụ không?",
    ),
    HskSentence(
      "我对中国历史很感兴趣",
      "Wǒ duì Zhōngguó lìshǐ hěn gǎn xìngqù",
      "Tôi rất hứng thú với lịch sử Trung Quốc",
    ),
    HskSentence(
      "他说话的方式让我觉得很舒服",
      "Tā shuōhuà de fāngshì ràng wǒ juéde hěn shūfú",
      "Cách anh ấy nói chuyện làm tôi cảm thấy thoải mái",
    ),
    HskSentence(
      "你能告诉我去火车站怎么走吗",
      "Nǐ néng gàosù wǒ qù huǒchē zhàn zěnme zǒu ma",
      "Bạn có thể chỉ tôi đường đến ga xe lửa không?",
    ),
    HskSentence(
      "一直走，然后左转",
      "Yìzhí zǒu, rán hòu zuǒ zhuǎn",
      "Đi thẳng, sau đó rẽ trái",
    ),
    HskSentence("我需要办签证", "Wǒ xūyào bàn qiānzhèng", "Tôi cần làm visa"),
    HskSentence(
      "请问，机票什么时候最便宜",
      "Qǐngwèn, jīpiào shénme shíhou zuì piányí",
      "Xin hỏi, vé máy bay khi nào rẻ nhất?",
    ),
    HskSentence(
      "我打算下个月去北京旅游",
      "Wǒ dǎsuàn xià gè yuè qù Běijīng lǚyóu",
      "Tôi dự định tháng sau sẽ đi du lịch Bắc Kinh",
    ),
    HskSentence(
      "你能推荐一家好餐厅吗",
      "Nǐ néng tuījiàn yì jiā hǎo cāntīng ma",
      "Bạn có thể giới thiệu một nhà hàng ngon không?",
    ),
    HskSentence(
      "这家饭店的服务非常好",
      "Zhè jiā fàndiàn de fúwù fēicháng hǎo",
      "Phục vụ của khách sạn này rất tốt",
    ),
    HskSentence(
      "我在网上查了一下",
      "Wǒ zài wǎng shang chá le yíxià",
      "Tôi đã tra trên mạng một chút",
    ),
    HskSentence(
      "现在手机对我们的生活影响很大",
      "Xiànzài shǒujī duì wǒmen de shēnghuó yǐngxiǎng hěn dà",
      "Hiện nay điện thoại ảnh hưởng rất lớn đến cuộc sống của chúng ta",
    ),
    HskSentence(
      "你最近工作怎么样",
      "Nǐ zuìjìn gōngzuò zěnme yàng",
      "Công việc của bạn gần đây thế nào?",
    ),
    HskSentence(
      "还不错，就是有点忙",
      "Hái bùcuò, jiùshì yǒudiǎn máng",
      "Cũng khá, chỉ là hơi bận",
    ),
    HskSentence(
      "我们公司下个月开始招聘",
      "Wǒmen gōngsī xià gè yuè kāishǐ zhāopìn",
      "Công ty chúng tôi tháng sau sẽ bắt đầu tuyển dụng",
    ),
    HskSentence(
      "你的简历准备好了吗",
      "Nǐ de jiǎnlì zhǔnbèi hǎo le ma",
      "Bạn đã chuẩn bị CV chưa?",
    ),
    HskSentence(
      "我昨晚看了一部很好看的电影",
      "Wǒ zuówǎn kàn le yí bù hěn hǎokàn de diànyǐng",
      "Tối qua tôi xem một bộ phim rất hay",
    ),
    HskSentence(
      "你觉得这本书怎么样",
      "Nǐ juéde zhè běn shū zěnme yàng",
      "Bạn thấy quyển sách này thế nào?",
    ),
    HskSentence(
      "我觉得他说得很有道理",
      "Wǒ juéde tā shuō de hěn yǒu dàolǐ",
      "Tôi thấy những gì anh ấy nói rất có lý",
    ),
  ];

  // ========== HSK 4: 30 câu ==========
  static const List<HskSentence> _hsk4 = [
    HskSentence(
      "通过努力学习，我的中文越来越好",
      "Tōngguò nǔlì xuéxí, wǒ de Zhōngwén yuè lái yuè hǎo",
      "Thông qua việc học chăm chỉ, tiếng Trung của tôi ngày càng tốt hơn",
    ),
    HskSentence(
      "中国文化非常丰富多彩",
      "Zhōngguó wénhuà fēicháng fēngfù duōcǎi",
      "Văn hóa Trung Quốc vô cùng phong phú đa dạng",
    ),
    HskSentence(
      "随着经济的发展，人们的生活水平不断提高",
      "Suízhe jīngjì de fāzhǎn, rénmen de shēnghuó shuǐpíng bùduàn tígāo",
      "Cùng với sự phát triển kinh tế, mức sống của người dân ngày càng nâng cao",
    ),
    HskSentence(
      "他宁可自己受苦，也不愿意让别人帮忙",
      "Tā nìngkě zìjǐ shòu kǔ, yě bú yuànyì ràng biérén bāngmáng",
      "Anh ấy thà chịu khổ một mình còn hơn để người khác giúp",
    ),
    HskSentence(
      "这个问题值得我们认真思考",
      "Zhège wèntí zhídé wǒmen rènzhēn sīkǎo",
      "Vấn đề này đáng để chúng ta suy nghĩ nghiêm túc",
    ),
    HskSentence(
      "由于天气原因，航班被推迟了",
      "Yóuyú tiānqì yuányīn, hángbān bèi tuīchí le",
      "Do thời tiết, chuyến bay bị hoãn lại",
    ),
    HskSentence(
      "尽管困难重重，他还是坚持下来了",
      "Jǐnguǎn kùnnán chóngchóng, tā háishi jiānchí xiàlai le",
      "Mặc dù rất nhiều khó khăn, anh ấy vẫn kiên trì",
    ),
    HskSentence(
      "我认为保护环境是每个人的责任",
      "Wǒ rènwéi bǎohù huánjìng shì měi gè rén de zérèn",
      "Tôi cho rằng bảo vệ môi trường là trách nhiệm của mỗi người",
    ),
    HskSentence(
      "面对压力，保持积极的心态很重要",
      "Miànduì yālì, bǎochí jījí de xīntài hěn zhòngyào",
      "Khi đối mặt với áp lực, điều quan trọng là giữ thái độ tích cực",
    ),
    HskSentence(
      "这次会议的主题是可持续发展",
      "Zhè cì huìyì de zhǔtí shì kě chíxù fāzhǎn",
      "Chủ đề của cuộc họp lần này là phát triển bền vững",
    ),
    HskSentence(
      "在中国，春节是最重要的节日",
      "Zài Zhōngguó, Chūnjié shì zuì zhòngyào de jiérì",
      "Ở Trung Quốc, Tết Nguyên Đán là ngày lễ quan trọng nhất",
    ),
    HskSentence(
      "他对工作非常认真负责",
      "Tā duì gōngzuò fēicháng rènzhēn fùzé",
      "Anh ấy rất chăm chỉ và có trách nhiệm trong công việc",
    ),
    HskSentence(
      "这项研究对社会有重要意义",
      "Zhè xiàng yánjiū duì shèhuì yǒu zhòngyào yìyì",
      "Nghiên cứu này có ý nghĩa quan trọng đối với xã hội",
    ),
    HskSentence(
      "互联网改变了人们的沟通方式",
      "Hùliánwǎng gǎibiàn le rénmen de gōutōng fāngshì",
      "Internet đã thay đổi cách giao tiếp của con người",
    ),
    HskSentence(
      "他的演讲精彩极了，获得了热烈的掌声",
      "Tā de yǎnjiǎng jīngcǎi jí le, huòdé le rèliè de zhǎngshēng",
      "Bài phát biểu của anh ấy xuất sắc, nhận được tràng pháo tay nhiệt liệt",
    ),
    HskSentence(
      "学好一门外语需要持之以恒的努力",
      "Xué hǎo yì mén wàiyǔ xūyào chí zhī yǐ héng de nǔlì",
      "Học giỏi một ngoại ngữ cần nỗ lực bền bỉ",
    ),
    HskSentence(
      "人工智能正在改变各个行业",
      "Réngōng zhìnéng zhèngzài gǎibiàn gège hángyè",
      "Trí tuệ nhân tạo đang thay đổi nhiều ngành nghề",
    ),
    HskSentence(
      "我们应该珍惜眼前的机会",
      "Wǒmen yīnggāi zhēnxī yǎnqián de jīhuì",
      "Chúng ta nên trân trọng cơ hội trước mắt",
    ),
    HskSentence(
      "这部电影深刻地反映了社会现实",
      "Zhè bù diànyǐng shēnkè de fǎnyìng le shèhuì xiànshí",
      "Bộ phim này phản ánh sâu sắc thực tế xã hội",
    ),
    HskSentence(
      "只有团结合作，才能克服困难",
      "Zhǐyǒu tuánjié hézuò, cáinéng kèfú kùnnán",
      "Chỉ có đoàn kết hợp tác mới có thể vượt qua khó khăn",
    ),
    HskSentence(
      "他的观点颇具争议",
      "Tā de guāndiǎn pō jù zhēngyì",
      "Quan điểm của anh ấy khá gây tranh cãi",
    ),
    HskSentence(
      "这个方案既经济又实用",
      "Zhège fāng'àn jì jīngjì yòu shíyòng",
      "Phương án này vừa kinh tế vừa thực dụng",
    ),
    HskSentence(
      "消费者的需求越来越多样化",
      "Xiāofèizhě de xūqiú yuè lái yuè duōyànghuà",
      "Nhu cầu của người tiêu dùng ngày càng đa dạng",
    ),
    HskSentence(
      "他从来不轻言放弃",
      "Tā cónglái bù qīng yán fàngqì",
      "Anh ấy chưa bao giờ dễ dàng bỏ cuộc",
    ),
    HskSentence(
      "保持良好的生活习惯对健康非常重要",
      "Bǎochí liánghǎo de shēnghuó xíguàn duì jiànkāng fēicháng zhòngyào",
      "Duy trì thói quen sống tốt rất quan trọng cho sức khỏe",
    ),
    HskSentence(
      "这家公司在业界享有很高的声誉",
      "Zhè jiā gōngsī zài yèjiè xiǎngyǒu hěn gāo de shēngyù",
      "Công ty này có danh tiếng rất cao trong ngành",
    ),
    HskSentence(
      "全球化带来了机遇，也带来了挑战",
      "Quánqiúhuà dài lái le jīyù, yě dài lái le tiǎozhàn",
      "Toàn cầu hóa mang lại cơ hội nhưng cũng mang lại thách thức",
    ),
    HskSentence(
      "他的成功离不开家人的支持",
      "Tā de chénggōng lí bù kāi jiārén de zhīchí",
      "Thành công của anh ấy không thể thiếu sự ủng hộ của gia đình",
    ),
    HskSentence(
      "我们要从失败中吸取教训",
      "Wǒmen yào cóng shībài zhōng xīqǔ jiàoxùn",
      "Chúng ta phải rút kinh nghiệm từ thất bại",
    ),
    HskSentence(
      "这首歌的旋律非常优美动听",
      "Zhè shǒu gē de xuánlǜ fēicháng yōuměi dòngtīng",
      "Giai điệu bài hát này rất tuyệt vời và du dương",
    ),
  ];

  // ========== HSK 5: 25 câu ==========
  static const List<HskSentence> _hsk5 = [
    HskSentence(
      "在经济全球化的背景下，各国之间的合作愈发重要",
      "Zài jīngjì quánqiúhuà de bèijǐng xià, gè guó zhī jiān de hézuò yùfā zhòngyào",
      "Trong bối cảnh toàn cầu hóa kinh tế, sự hợp tác giữa các quốc gia ngày càng trở nên quan trọng hơn",
    ),
    HskSentence(
      "可持续发展是当今世界面临的重大课题",
      "Kě chíxù fāzhǎn shì dāngjīn shìjiè miànlín de zhòngdà kètí",
      "Phát triển bền vững là vấn đề lớn mà thế giới ngày nay đang đối mặt",
    ),
    HskSentence(
      "科技的进步深刻地改变了人类的生产生活方式",
      "Kējì de jìnbù shēnkè de gǎibiàn le rénlèi de shēngchǎn shēnghuó fāngshì",
      "Sự tiến bộ của khoa học kỹ thuật đã thay đổi sâu sắc phương thức sản xuất và cuộc sống của con người",
    ),
    HskSentence(
      "文化多样性是人类文明的宝贵财富",
      "Wénhuà duōyàngxìng shì rénlèi wénmíng de bǎoguì cáifù",
      "Sự đa dạng văn hóa là tài sản quý báu của nền văn minh nhân loại",
    ),
    HskSentence(
      "教育是提高一个国家综合国力的重要手段",
      "Jiàoyù shì tígāo yí gè guójiā zōnghé guólì de zhòngyào shǒuduàn",
      "Giáo dục là phương tiện quan trọng để nâng cao sức mạnh tổng hợp quốc gia",
    ),
    HskSentence(
      "气候变化已经成为全球性的紧迫问题",
      "Qìhòu biànhuà yǐjīng chéngwéi quánqiúxìng de jǐnpò wèntí",
      "Biến đổi khí hậu đã trở thành vấn đề cấp bách toàn cầu",
    ),
    HskSentence(
      "大数据和人工智能的结合将会创造无限可能",
      "Dà shùjù hé réngōng zhìnéng de jiéhé jiāng huì chuàngzào wúxiàn kěnéng",
      "Sự kết hợp giữa dữ liệu lớn và AI sẽ tạo ra vô số khả năng",
    ),
    HskSentence(
      "一带一路倡议促进了沿线国家的互联互通",
      "Yīdài yīlù chàngyì cùjìn le yán xiàn guójiā de hù lián hù tōng",
      "Sáng kiến Vành đai và Con đường thúc đẩy kết nối giữa các nước dọc tuyến đường",
    ),
    HskSentence(
      "良好的沟通技巧是职场成功的关键因素之一",
      "Liánghǎo de gōutōng jìqiǎo shì zhíchǎng chénggōng de guānjiàn yīnsù zhīyī",
      "Kỹ năng giao tiếp tốt là một trong những yếu tố then chốt để thành công trong công việc",
    ),
    HskSentence(
      "传统文化与现代文明的融合是时代发展的必然趋势",
      "Chuántǒng wénhuà yǔ xiàndài wénmíng de rónghé shì shídài fāzhǎn de bìrán qūshì",
      "Sự hòa quyện giữa văn hóa truyền thống và văn minh hiện đại là xu hướng tất yếu trong sự phát triển của thời đại",
    ),
    HskSentence(
      "提高粮食安全是许多发展中国家的首要任务",
      "Tígāo liángshí ānquán shì xǔduō fāzhǎn zhōng guójiā de shǒuyào rènwù",
      "Nâng cao an ninh lương thực là nhiệm vụ hàng đầu của nhiều nước đang phát triển",
    ),
    HskSentence(
      "社会公平正义是构建和谐社会的基础",
      "Shèhuì gōngpíng zhèngyì shì gòujiàn héxié shèhuì de jīchǔ",
      "Công bằng xã hội là nền tảng để xây dựng xã hội hài hòa",
    ),
    HskSentence(
      "创新是推动社会进步的重要动力",
      "Chuàngxīn shì tuīdòng shèhuì jìnbù de zhòngyào dònglì",
      "Đổi mới sáng tạo là động lực quan trọng thúc đẩy tiến bộ xã hội",
    ),
    HskSentence(
      "个人价值的实现离不开社会的土壤",
      "Gèrén jiàzhí de shíxiàn lí bù kāi shèhuì de tǔrǎng",
      "Sự thực hiện giá trị cá nhân không thể tách rời môi trường xã hội",
    ),
    HskSentence(
      "深化改革开放是中国现代化建设的必由之路",
      "Shēnhuà gǎigé kāifàng shì Zhōngguó xiàndàihuà jiànshè de bì yóu zhī lù",
      "Đẩy mạnh cải cách và mở cửa là con đường tất yếu trong công cuộc hiện đại hóa của Trung Quốc",
    ),
    HskSentence(
      "知识经济时代，人才是最宝贵的资源",
      "Zhīshì jīngjì shídài, réncái shì zuì bǎoguì de zīyuán",
      "Trong thời đại kinh tế tri thức, nhân tài là nguồn tài nguyên quý giá nhất",
    ),
    HskSentence(
      "环境保护与经济发展并非不可调和的矛盾",
      "Huánjìng bǎohù yǔ jīngjì fāzhǎn bìngfēi bùkě tiáohé de máodùn",
      "Bảo vệ môi trường và phát triển kinh tế không phải là mâu thuẫn không thể giải quyết",
    ),
    HskSentence(
      "数字化转型已成为企业竞争力的核心要素",
      "Shùzìhuà zhuǎnxíng yǐ chéngwéi qǐyè jìngzhēnglì de héxīn yāosù",
      "Chuyển đổi số đã trở thành yếu tố cốt lõi trong sức cạnh tranh của doanh nghiệp",
    ),
    HskSentence(
      "推进城镇化建设须注重城乡协调发展",
      "Tuījìn chéngzhènhuà jiànshè xū zhùzhòng chéngxiāng xiétiáo fāzhǎn",
      "Thúc đẩy quá trình đô thị hóa cần chú trọng phát triển hài hòa giữa đô thị và nông thôn",
    ),
    HskSentence(
      "提高公民的法律意识是建设法治社会的关键",
      "Tígāo gōngmín de fǎlǜ yìshí shì jiànshè fǎzhì shèhuì de guānjiàn",
      "Nâng cao ý thức pháp luật của công dân là chìa khóa để xây dựng xã hội pháp quyền",
    ),
    HskSentence(
      "中医药是中华文明的瑰宝，值得传承和发扬",
      "Zhōngyīyào shì Zhōnghuá wénmíng de guībǎo, zhídé chuánchéng hé fāyáng",
      "Y học cổ truyền Trung Hoa là tinh hoa của văn minh Trung Hoa, xứng đáng được kế thừa và phát huy",
    ),
    HskSentence(
      "推动构建人类命运共同体是时代的呼唤",
      "Tuīdòng gòujiàn rénlèi mìngyùn gòngtóngtǐ shì shídài de hūhuàn",
      "Thúc đẩy xây dựng cộng đồng cùng chung vận mệnh nhân loại là tiếng gọi của thời đại",
    ),
    HskSentence(
      "文学作品往往能折射出一个时代的社会风貌",
      "Wénxué zuòpǐn wǎngwǎng néng zhéshè chū yí gè shídài de shèhuì fēngmào",
      "Tác phẩm văn học thường có thể phản ánh diện mạo xã hội của một thời đại",
    ),
    HskSentence(
      "追求卓越，勇于突破，是成功人士的共同特质",
      "Zhuīqiú zhuóyuè, yǒngyú tūpò, shì chénggōng rénshì de gòngtóng tèzhì",
      "Theo đuổi sự xuất sắc và dũng cảm vượt qua giới hạn là đặc điểm chung của những người thành công",
    ),
    HskSentence(
      "中华民族伟大复兴的中国梦，是当代中国最强音",
      "Zhōnghuá mínzú wěidà fùxīng de Zhōngguó mèng, shì dāngdài Zhōngguó zuì qiáng yīn",
      "'Giấc mơ Trung Hoa' về sự phục hưng vĩ đại của dân tộc Trung Hoa là âm thanh mạnh mẽ nhất của Trung Quốc đương đại",
    ),
  ];
}

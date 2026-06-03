import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "apps" / "mobile" / "assets" / "data"


reading = [
    ("HSK 1", "你好！", "Nǐ hǎo!", "Xin chào!"),
    ("HSK 1", "谢谢你。", "Xièxie nǐ.", "Cảm ơn bạn."),
    ("HSK 1", "不客气。", "Bú kèqi.", "Không có gì."),
    ("HSK 1", "你叫什么名字？", "Nǐ jiào shénme míngzi?", "Bạn tên là gì?"),
    ("HSK 1", "我叫小明。", "Wǒ jiào Xiǎomíng.", "Tôi tên là Tiểu Minh."),
    ("HSK 1", "我是学生。", "Wǒ shì xuésheng.", "Tôi là học sinh."),
    ("HSK 1", "她是我的朋友。", "Tā shì wǒ de péngyou.", "Cô ấy là bạn của tôi."),
    ("HSK 1", "你是哪国人？", "Nǐ shì nǎ guó rén?", "Bạn là người nước nào?"),
    ("HSK 1", "我会说汉语。", "Wǒ huì shuō Hànyǔ.", "Tôi biết nói tiếng Trung."),
    ("HSK 1", "今天星期几？", "Jīntiān xīngqī jǐ?", "Hôm nay là thứ mấy?"),
    ("HSK 1", "现在几点？", "Xiànzài jǐ diǎn?", "Bây giờ là mấy giờ?"),
    ("HSK 1", "我想喝茶。", "Wǒ xiǎng hē chá.", "Tôi muốn uống trà."),
    ("HSK 1", "这个杯子多少钱？", "Zhège bēizi duōshao qián?", "Cái cốc này bao nhiêu tiền?"),
    ("HSK 1", "桌子上有一本书。", "Zhuōzi shang yǒu yì běn shū.", "Trên bàn có một quyển sách."),
    ("HSK 1", "我妈妈在医院工作。", "Wǒ māma zài yīyuàn gōngzuò.", "Mẹ tôi làm việc ở bệnh viện."),
    ("HSK 1", "我喜欢吃米饭。", "Wǒ xǐhuan chī mǐfàn.", "Tôi thích ăn cơm."),
    ("HSK 1", "小猫在椅子下面。", "Xiǎomāo zài yǐzi xiàmiàn.", "Con mèo nhỏ ở dưới ghế."),
    ("HSK 1", "明天我去学校。", "Míngtiān wǒ qù xuéxiào.", "Ngày mai tôi đi học."),
    ("HSK 1", "请你再说一遍。", "Qǐng nǐ zài shuō yí biàn.", "Bạn vui lòng nói lại một lần nữa."),
    ("HSK 1", "再见，明天见！", "Zàijiàn, míngtiān jiàn!", "Tạm biệt, mai gặp lại!"),
    ("HSK 2", "我正在学习汉语。", "Wǒ zhèngzài xuéxí Hànyǔ.", "Tôi đang học tiếng Trung."),
    ("HSK 2", "今天比昨天热。", "Jīntiān bǐ zuótiān rè.", "Hôm nay nóng hơn hôm qua."),
    ("HSK 2", "我坐飞机去北京。", "Wǒ zuò fēijī qù Běijīng.", "Tôi đi máy bay đến Bắc Kinh."),
    ("HSK 2", "这个苹果太贵了。", "Zhège píngguǒ tài guì le.", "Quả táo này đắt quá."),
    ("HSK 2", "你能便宜一点吗？", "Nǐ néng piányí yìdiǎn ma?", "Bạn có thể bớt một chút không?"),
    ("HSK 2", "我每天早上跑步。", "Wǒ měitiān zǎoshang pǎobù.", "Mỗi sáng tôi chạy bộ."),
    ("HSK 2", "他已经回家了。", "Tā yǐjīng huí jiā le.", "Anh ấy đã về nhà rồi."),
    ("HSK 2", "请把门打开。", "Qǐng bǎ mén dǎkāi.", "Xin hãy mở cửa ra."),
    ("HSK 2", "我觉得这个电影很好看。", "Wǒ juéde zhège diànyǐng hěn hǎokàn.", "Tôi thấy bộ phim này rất hay."),
    ("HSK 2", "外面下雨了，别忘了带伞。", "Wàimiàn xià yǔ le, bié wàng le dài sǎn.", "Ngoài trời mưa rồi, đừng quên mang ô."),
    ("HSK 2", "我想给妈妈买一件衣服。", "Wǒ xiǎng gěi māma mǎi yí jiàn yīfu.", "Tôi muốn mua cho mẹ một bộ quần áo."),
    ("HSK 2", "你为什么学习中文？", "Nǐ wèishénme xuéxí Zhōngwén?", "Tại sao bạn học tiếng Trung?"),
    ("HSK 2", "因为我想去中国旅游。", "Yīnwèi wǒ xiǎng qù Zhōngguó lǚyóu.", "Vì tôi muốn đi du lịch Trung Quốc."),
    ("HSK 2", "这家饭馆的菜很好吃。", "Zhè jiā fànguǎn de cài hěn hǎochī.", "Món ăn của nhà hàng này rất ngon."),
    ("HSK 2", "我到公司以后给你打电话。", "Wǒ dào gōngsī yǐhòu gěi nǐ dǎ diànhuà.", "Sau khi đến công ty tôi gọi điện cho bạn."),
    ("HSK 2", "他一边听音乐一边做作业。", "Tā yìbiān tīng yīnyuè yìbiān zuò zuòyè.", "Anh ấy vừa nghe nhạc vừa làm bài tập."),
    ("HSK 2", "你准备什么时候出发？", "Nǐ zhǔnbèi shénme shíhou chūfā?", "Bạn chuẩn bị khi nào xuất phát?"),
    ("HSK 2", "我从学校走到地铁站。", "Wǒ cóng xuéxiào zǒu dào dìtiě zhàn.", "Tôi đi bộ từ trường đến ga tàu điện ngầm."),
    ("HSK 2", "这件事让我很高兴。", "Zhè jiàn shì ràng wǒ hěn gāoxìng.", "Việc này làm tôi rất vui."),
    ("HSK 2", "考试以前我会复习。", "Kǎoshì yǐqián wǒ huì fùxí.", "Trước khi thi tôi sẽ ôn tập."),
    ("HSK 3", "我的汉语越来越好了。", "Wǒ de Hànyǔ yuèláiyuè hǎo le.", "Tiếng Trung của tôi ngày càng tốt hơn."),
    ("HSK 3", "请把你的想法告诉我。", "Qǐng bǎ nǐ de xiǎngfǎ gàosu wǒ.", "Hãy nói cho tôi biết suy nghĩ của bạn."),
    ("HSK 3", "如果明天下雨，我们就不去公园。", "Rúguǒ míngtiān xià yǔ, wǒmen jiù bú qù gōngyuán.", "Nếu ngày mai mưa, chúng tôi sẽ không đi công viên."),
    ("HSK 3", "我对中国文化很感兴趣。", "Wǒ duì Zhōngguó wénhuà hěn gǎn xìngqù.", "Tôi rất hứng thú với văn hóa Trung Quốc."),
    ("HSK 3", "这次会议非常重要。", "Zhè cì huìyì fēicháng zhòngyào.", "Cuộc họp lần này rất quan trọng."),
    ("HSK 3", "经理让我们下午三点开会。", "Jīnglǐ ràng wǒmen xiàwǔ sān diǎn kāihuì.", "Quản lý bảo chúng tôi họp lúc ba giờ chiều."),
    ("HSK 3", "我突然想起了一个问题。", "Wǒ tūrán xiǎngqǐ le yí ge wèntí.", "Tôi đột nhiên nhớ ra một vấn đề."),
    ("HSK 3", "这条路又长又安静。", "Zhè tiáo lù yòu cháng yòu ānjìng.", "Con đường này vừa dài vừa yên tĩnh."),
    ("HSK 3", "他把手机放在桌子上了。", "Tā bǎ shǒujī fàng zài zhuōzi shang le.", "Anh ấy đặt điện thoại lên bàn rồi."),
    ("HSK 3", "我们先吃饭，然后去看电影。", "Wǒmen xiān chīfàn, ránhòu qù kàn diànyǐng.", "Chúng ta ăn cơm trước, sau đó đi xem phim."),
    ("HSK 3", "这本书我已经看完了。", "Zhè běn shū wǒ yǐjīng kàn wán le.", "Quyển sách này tôi đã đọc xong rồi."),
    ("HSK 3", "他唱歌唱得很好。", "Tā chànggē chàng de hěn hǎo.", "Anh ấy hát rất hay."),
    ("HSK 3", "我希望以后能在中国工作。", "Wǒ xīwàng yǐhòu néng zài Zhōngguó gōngzuò.", "Tôi hy vọng sau này có thể làm việc ở Trung Quốc."),
    ("HSK 3", "这件衣服虽然便宜，但是质量不错。", "Zhè jiàn yīfu suīrán piányí, dànshì zhìliàng búcuò.", "Bộ quần áo này tuy rẻ nhưng chất lượng không tệ."),
    ("HSK 3", "你应该多听多说。", "Nǐ yīnggāi duō tīng duō shuō.", "Bạn nên nghe nhiều và nói nhiều."),
    ("HSK 3", "我正在准备下周的考试。", "Wǒ zhèngzài zhǔnbèi xià zhōu de kǎoshì.", "Tôi đang chuẩn bị cho kỳ thi tuần sau."),
    ("HSK 3", "请你帮我检查一下。", "Qǐng nǐ bāng wǒ jiǎnchá yíxià.", "Bạn vui lòng giúp tôi kiểm tra một chút."),
    ("HSK 3", "这座城市的交通很方便。", "Zhè zuò chéngshì de jiāotōng hěn fāngbiàn.", "Giao thông của thành phố này rất tiện lợi."),
    ("HSK 3", "我跟同事一起完成了任务。", "Wǒ gēn tóngshì yìqǐ wánchéng le rènwu.", "Tôi đã cùng đồng nghiệp hoàn thành nhiệm vụ."),
    ("HSK 3", "这张照片拍得很清楚。", "Zhè zhāng zhàopiàn pāi de hěn qīngchu.", "Bức ảnh này chụp rất rõ."),
    ("HSK 4", "虽然汉语很难，但是我很喜欢。", "Suīrán Hànyǔ hěn nán, dànshì wǒ hěn xǐhuan.", "Mặc dù tiếng Trung khó, nhưng tôi rất thích."),
    ("HSK 4", "他不但会说汉语，而且会写汉字。", "Tā búdàn huì shuō Hànyǔ, érqiě huì xiě Hànzì.", "Anh ấy không những biết nói tiếng Trung mà còn biết viết chữ Hán."),
    ("HSK 4", "只要你每天练习，发音就会越来越标准。", "Zhǐyào nǐ měitiān liànxí, fāyīn jiù huì yuèláiyuè biāozhǔn.", "Chỉ cần bạn luyện mỗi ngày, phát âm sẽ ngày càng chuẩn."),
    ("HSK 4", "无论遇到什么问题，我们都要冷静地解决。", "Wúlùn yùdào shénme wèntí, wǒmen dōu yào lěngjìng de jiějué.", "Dù gặp vấn đề gì, chúng ta đều phải bình tĩnh giải quyết."),
    ("HSK 4", "这篇文章介绍了中国经济的发展。", "Zhè piān wénzhāng jièshào le Zhōngguó jīngjì de fāzhǎn.", "Bài viết này giới thiệu sự phát triển kinh tế Trung Quốc."),
    ("HSK 4", "我认为学习语言最重要的是坚持。", "Wǒ rènwéi xuéxí yǔyán zuì zhòngyào de shì jiānchí.", "Tôi cho rằng điều quan trọng nhất khi học ngôn ngữ là kiên trì."),
    ("HSK 4", "这个方法既简单又有效。", "Zhège fāngfǎ jì jiǎndān yòu yǒuxiào.", "Phương pháp này vừa đơn giản vừa hiệu quả."),
    ("HSK 4", "由于天气原因，航班可能会推迟。", "Yóuyú tiānqì yuányīn, hángbān kěnéng huì tuīchí.", "Do nguyên nhân thời tiết, chuyến bay có thể bị hoãn."),
    ("HSK 4", "这次经历给我留下了很深的印象。", "Zhè cì jīnglì gěi wǒ liúxià le hěn shēn de yìnxiàng.", "Trải nghiệm lần này để lại cho tôi ấn tượng rất sâu sắc."),
    ("HSK 4", "我们应该尊重不同的文化和习惯。", "Wǒmen yīnggāi zūnzhòng bùtóng de wénhuà hé xíguàn.", "Chúng ta nên tôn trọng các văn hóa và thói quen khác nhau."),
    ("HSK 4", "这个计划需要大家共同努力。", "Zhège jìhuà xūyào dàjiā gòngtóng nǔlì.", "Kế hoạch này cần mọi người cùng nỗ lực."),
    ("HSK 4", "如果有机会，我想参加中文比赛。", "Rúguǒ yǒu jīhuì, wǒ xiǎng cānjiā Zhōngwén bǐsài.", "Nếu có cơ hội, tôi muốn tham gia cuộc thi tiếng Trung."),
    ("HSK 4", "这家公司的服务态度很好。", "Zhè jiā gōngsī de fúwù tàidu hěn hǎo.", "Thái độ phục vụ của công ty này rất tốt."),
    ("HSK 4", "他把自己的观点解释得很清楚。", "Tā bǎ zìjǐ de guāndiǎn jiěshì de hěn qīngchu.", "Anh ấy giải thích quan điểm của mình rất rõ ràng."),
    ("HSK 4", "网络改变了人们获得信息的方式。", "Wǎngluò gǎibiàn le rénmen huòdé xìnxī de fāngshì.", "Internet đã thay đổi cách con người nhận thông tin."),
    ("HSK 4", "学习的时候不要害怕犯错误。", "Xuéxí de shíhou búyào hàipà fàn cuòwù.", "Khi học đừng sợ mắc lỗi."),
    ("HSK 4", "这件事情比我想象的复杂。", "Zhè jiàn shìqing bǐ wǒ xiǎngxiàng de fùzá.", "Việc này phức tạp hơn tôi tưởng tượng."),
    ("HSK 4", "为了提高听力，我每天听中文新闻。", "Wèile tígāo tīnglì, wǒ měitiān tīng Zhōngwén xīnwén.", "Để nâng cao nghe hiểu, mỗi ngày tôi nghe tin tức tiếng Trung."),
    ("HSK 4", "他通过努力获得了成功。", "Tā tōngguò nǔlì huòdé le chénggōng.", "Anh ấy đạt được thành công nhờ nỗ lực."),
    ("HSK 4", "请根据实际情况做出选择。", "Qǐng gēnjù shíjì qíngkuàng zuòchū xuǎnzé.", "Hãy đưa ra lựa chọn dựa trên tình hình thực tế."),
]


video_lessons = [
    {
        "id": "lf_hsk1_hello",
        "title": "Hello Song",
        "titleCn": "你好歌",
        "level": "HSK 1",
        "youtubeId": "m_rDIzj6DRE",
        "source": "Little Fox Chinese",
        "subtitles": [
            {"cn": "你好，你好。", "py": "Nǐ hǎo, nǐ hǎo.", "vi": "Xin chào, xin chào."},
            {"cn": "大家一起说你好。", "py": "Dàjiā yìqǐ shuō nǐ hǎo.", "vi": "Mọi người cùng nói xin chào."},
            {"cn": "一二三四五。", "py": "Yī èr sān sì wǔ.", "vi": "Một, hai, ba, bốn, năm."},
            {"cn": "我们一起唱歌。", "py": "Wǒmen yìqǐ chànggē.", "vi": "Chúng ta cùng hát."},
        ],
    },
    {
        "id": "lf_hsk1_my_day",
        "title": "My Day",
        "titleCn": "我的一天",
        "level": "HSK 1",
        "youtubeId": "NjKooVPp8-s",
        "source": "Little Fox Chinese",
        "subtitles": [
            {"cn": "早上我起床。", "py": "Zǎoshang wǒ qǐchuáng.", "vi": "Buổi sáng tôi thức dậy."},
            {"cn": "我吃早饭。", "py": "Wǒ chī zǎofàn.", "vi": "Tôi ăn sáng."},
            {"cn": "我去学校。", "py": "Wǒ qù xuéxiào.", "vi": "Tôi đi học."},
            {"cn": "晚上我睡觉。", "py": "Wǎnshang wǒ shuìjiào.", "vi": "Buổi tối tôi đi ngủ."},
        ],
    },
    {
        "id": "lf_hsk1_name",
        "title": "What's Your Name?",
        "titleCn": "你叫什么名字？",
        "level": "HSK 1",
        "youtubeId": "6VR4bW2nX_4",
        "source": "Little Fox Chinese",
        "subtitles": [
            {"cn": "你叫什么名字？", "py": "Nǐ jiào shénme míngzi?", "vi": "Bạn tên là gì?"},
            {"cn": "我叫小美。", "py": "Wǒ jiào Xiǎoměi.", "vi": "Tôi tên là Tiểu Mỹ."},
            {"cn": "很高兴认识你。", "py": "Hěn gāoxìng rènshi nǐ.", "vi": "Rất vui được gặp bạn."},
            {"cn": "我们是朋友。", "py": "Wǒmen shì péngyou.", "vi": "Chúng ta là bạn."},
        ],
    },
    {
        "id": "lf_hsk2_job",
        "title": "What Does He Do?",
        "titleCn": "他做什么工作？",
        "level": "HSK 2",
        "youtubeId": "YmTB_nQxJQj",
        "source": "Little Fox Chinese",
        "subtitles": [
            {"cn": "他做什么工作？", "py": "Tā zuò shénme gōngzuò?", "vi": "Anh ấy làm nghề gì?"},
            {"cn": "他是老师。", "py": "Tā shì lǎoshī.", "vi": "Anh ấy là giáo viên."},
            {"cn": "她做什么工作？", "py": "Tā zuò shénme gōngzuò?", "vi": "Cô ấy làm nghề gì?"},
            {"cn": "她是医生。", "py": "Tā shì yīshēng.", "vi": "Cô ấy là bác sĩ."},
        ],
    },
    {
        "id": "lf_hsk2_doing",
        "title": "What Are You Doing?",
        "titleCn": "你在做什么？",
        "level": "HSK 2",
        "youtubeId": "Aqs0VrMEeXQ",
        "source": "Little Fox Chinese",
        "subtitles": [
            {"cn": "你在做什么？", "py": "Nǐ zài zuò shénme?", "vi": "Bạn đang làm gì?"},
            {"cn": "我在看书。", "py": "Wǒ zài kàn shū.", "vi": "Tôi đang đọc sách."},
            {"cn": "他在听音乐。", "py": "Tā zài tīng yīnyuè.", "vi": "Anh ấy đang nghe nhạc."},
            {"cn": "我们在学习中文。", "py": "Wǒmen zài xuéxí Zhōngwén.", "vi": "Chúng tôi đang học tiếng Trung."},
        ],
    },
    {
        "id": "lf_hsk2_market",
        "title": "Shopping at the Market",
        "titleCn": "在市场买东西",
        "level": "HSK 2",
        "youtubeId": "jMEW0KcwBdY",
        "source": "Little Fox Chinese",
        "subtitles": [
            {"cn": "这个苹果多少钱？", "py": "Zhège píngguǒ duōshao qián?", "vi": "Táo này bao nhiêu tiền?"},
            {"cn": "一斤五块钱。", "py": "Yì jīn wǔ kuài qián.", "vi": "Một cân năm đồng."},
            {"cn": "太贵了！", "py": "Tài guì le!", "vi": "Đắt quá!"},
            {"cn": "我买两斤。", "py": "Wǒ mǎi liǎng jīn.", "vi": "Tôi mua hai cân."},
        ],
    },
    {
        "id": "lf_hsk3_guitar",
        "title": "Who Am I? 4: This Is My Guitar",
        "titleCn": "这是谁的吉他？",
        "level": "HSK 3",
        "youtubeId": "MPuvcZCu5f9",
        "source": "Little Fox Chinese",
        "subtitles": [
            {"cn": "这是谁的吉他？", "py": "Zhè shì shéi de jítā?", "vi": "Đây là đàn guitar của ai?"},
            {"cn": "这是我的吉他。", "py": "Zhè shì wǒ de jítā.", "vi": "Đây là đàn guitar của tôi."},
            {"cn": "我喜欢弹吉他。", "py": "Wǒ xǐhuan tán jítā.", "vi": "Tôi thích chơi guitar."},
            {"cn": "音乐让我很开心。", "py": "Yīnyuè ràng wǒ hěn kāixīn.", "vi": "Âm nhạc làm tôi rất vui."},
        ],
    },
    {
        "id": "lf_hsk3_family",
        "title": "Family Life",
        "titleCn": "家庭生活",
        "level": "HSK 3",
        "youtubeId": "8K7BNGGjGiA",
        "source": "Little Fox Chinese",
        "subtitles": [
            {"cn": "我家有四口人。", "py": "Wǒ jiā yǒu sì kǒu rén.", "vi": "Nhà tôi có bốn người."},
            {"cn": "爸爸是工程师。", "py": "Bàba shì gōngchéngshī.", "vi": "Ba tôi là kỹ sư."},
            {"cn": "妈妈是护士。", "py": "Māma shì hùshi.", "vi": "Mẹ tôi là y tá."},
            {"cn": "我们家很幸福。", "py": "Wǒmen jiā hěn xìngfú.", "vi": "Gia đình chúng tôi rất hạnh phúc."},
        ],
    },
    {
        "id": "lf_hsk3_weather",
        "title": "Weather and Seasons",
        "titleCn": "天气和季节",
        "level": "HSK 3",
        "youtubeId": "hYM-F05V02A",
        "source": "Little Fox Chinese",
        "subtitles": [
            {"cn": "中国有四个季节。", "py": "Zhōngguó yǒu sì gè jìjié.", "vi": "Trung Quốc có bốn mùa."},
            {"cn": "春天气候温暖。", "py": "Chūntiān qìhòu wēnnuǎn.", "vi": "Mùa xuân khí hậu ấm áp."},
            {"cn": "夏天经常下雨。", "py": "Xiàtiān jīngcháng xià yǔ.", "vi": "Mùa hè thường mưa."},
            {"cn": "秋天的风景很漂亮。", "py": "Qiūtiān de fēngjǐng hěn piàoliang.", "vi": "Phong cảnh mùa thu rất đẹp."},
        ],
    },
    {
        "id": "lf_hsk4_kids_central_12",
        "title": "Fun at Kids Central 12",
        "titleCn": "趣味儿童中心 12",
        "level": "HSK 4",
        "youtubeId": "5S97IE7qtYs",
        "source": "Little Fox Chinese",
        "subtitles": [
            {"cn": "今天我们参加一个有趣的活动。", "py": "Jīntiān wǒmen cānjiā yí ge yǒuqù de huódòng.", "vi": "Hôm nay chúng tôi tham gia một hoạt động thú vị."},
            {"cn": "老师先介绍了活动规则。", "py": "Lǎoshī xiān jièshào le huódòng guīzé.", "vi": "Cô giáo giới thiệu luật hoạt động trước."},
            {"cn": "大家需要互相帮助。", "py": "Dàjiā xūyào hùxiāng bāngzhù.", "vi": "Mọi người cần giúp đỡ lẫn nhau."},
            {"cn": "最后我们完成了任务。", "py": "Zuìhòu wǒmen wánchéng le rènwu.", "vi": "Cuối cùng chúng tôi hoàn thành nhiệm vụ."},
        ],
    },
    {
        "id": "lf_hsk4_kids_central_25",
        "title": "Fun at Kids Central 25",
        "titleCn": "趣味儿童中心 25",
        "level": "HSK 4",
        "youtubeId": "F1waw1gUNt4",
        "source": "Little Fox Chinese",
        "subtitles": [
            {"cn": "这个实验看起来很简单。", "py": "Zhège shíyàn kàn qǐlái hěn jiǎndān.", "vi": "Thí nghiệm này trông rất đơn giản."},
            {"cn": "可是我们必须认真准备。", "py": "Kěshì wǒmen bìxū rènzhēn zhǔnbèi.", "vi": "Nhưng chúng tôi phải chuẩn bị nghiêm túc."},
            {"cn": "如果步骤错了，结果就不一样。", "py": "Rúguǒ bùzhòu cuò le, jiéguǒ jiù bù yíyàng.", "vi": "Nếu bước làm sai, kết quả sẽ khác."},
            {"cn": "这个过程非常有意思。", "py": "Zhège guòchéng fēicháng yǒuyìsi.", "vi": "Quá trình này rất thú vị."},
        ],
    },
    {
        "id": "lf_hsk4_kids_central_29",
        "title": "Fun at Kids Central 29",
        "titleCn": "趣味儿童中心 29",
        "level": "HSK 4",
        "youtubeId": "Os-NLk9FJ_0",
        "source": "Little Fox Chinese",
        "subtitles": [
            {"cn": "我们决定一起做一个项目。", "py": "Wǒmen juédìng yìqǐ zuò yí ge xiàngmù.", "vi": "Chúng tôi quyết định cùng làm một dự án."},
            {"cn": "每个人都有自己的任务。", "py": "Měi ge rén dōu yǒu zìjǐ de rènwu.", "vi": "Mỗi người đều có nhiệm vụ riêng."},
            {"cn": "合作可以让事情变得更容易。", "py": "Hézuò kěyǐ ràng shìqing biàn de gèng róngyì.", "vi": "Hợp tác có thể làm mọi việc dễ hơn."},
            {"cn": "我们对结果很满意。", "py": "Wǒmen duì jiéguǒ hěn mǎnyì.", "vi": "Chúng tôi rất hài lòng với kết quả."},
        ],
    },
]


news_seed = [
    {
        "id": "seed_hsk1_school",
        "level": "HSK 1",
        "source": "VNChinese Easy News",
        "title": "学校今天有中文活动",
        "titleVi": "Hôm nay trường có hoạt động tiếng Trung",
        "summaryVi": "Bài đọc chậm cho HSK 1",
        "sentences": [
            {"cn": "今天学校有中文活动。", "py": "Jīntiān xuéxiào yǒu Zhōngwén huódòng.", "vi": "Hôm nay trường có hoạt động tiếng Trung."},
            {"cn": "老师教学生唱中文歌。", "py": "Lǎoshī jiāo xuésheng chàng Zhōngwén gē.", "vi": "Giáo viên dạy học sinh hát bài tiếng Trung."},
            {"cn": "学生们很高兴。", "py": "Xuéshengmen hěn gāoxìng.", "vi": "Các học sinh rất vui."},
        ],
    },
    {
        "id": "seed_hsk2_market",
        "level": "HSK 2",
        "source": "VNChinese Easy News",
        "title": "周末市场很热闹",
        "titleVi": "Cuối tuần chợ rất nhộn nhịp",
        "summaryVi": "Bài đọc chậm cho HSK 2",
        "sentences": [
            {"cn": "周末市场里人很多。", "py": "Zhōumò shìchǎng lǐ rén hěn duō.", "vi": "Cuối tuần trong chợ có rất đông người."},
            {"cn": "很多人买水果和蔬菜。", "py": "Hěn duō rén mǎi shuǐguǒ hé shūcài.", "vi": "Nhiều người mua trái cây và rau."},
            {"cn": "有的东西比平时便宜。", "py": "Yǒu de dōngxi bǐ píngshí piányí.", "vi": "Có vài món rẻ hơn bình thường."},
        ],
    },
    {
        "id": "seed_hsk3_travel",
        "level": "HSK 3",
        "source": "VNChinese Easy News",
        "title": "城市开通新的地铁线路",
        "titleVi": "Thành phố mở tuyến tàu điện ngầm mới",
        "summaryVi": "Bài đọc chậm cho HSK 3",
        "sentences": [
            {"cn": "这座城市开通了一条新的地铁线路。", "py": "Zhè zuò chéngshì kāitōng le yì tiáo xīn de dìtiě xiànlù.", "vi": "Thành phố này đã mở một tuyến tàu điện ngầm mới."},
            {"cn": "人们去机场更方便了。", "py": "Rénmen qù jīchǎng gèng fāngbiàn le.", "vi": "Mọi người đi sân bay thuận tiện hơn."},
            {"cn": "很多乘客表示很满意。", "py": "Hěn duō chéngkè biǎoshì hěn mǎnyì.", "vi": "Nhiều hành khách cho biết họ rất hài lòng."},
        ],
    },
    {
        "id": "seed_hsk4_tech",
        "level": "HSK 4",
        "source": "VNChinese Easy News",
        "title": "网络学习改变学生的习惯",
        "titleVi": "Học trực tuyến thay đổi thói quen của học sinh",
        "summaryVi": "Bài đọc chậm cho HSK 4",
        "sentences": [
            {"cn": "网络学习正在改变学生获得知识的方式。", "py": "Wǎngluò xuéxí zhèngzài gǎibiàn xuésheng huòdé zhīshi de fāngshì.", "vi": "Học trực tuyến đang thay đổi cách học sinh tiếp nhận kiến thức."},
            {"cn": "学生可以根据自己的时间安排课程。", "py": "Xuésheng kěyǐ gēnjù zìjǐ de shíjiān ānpái kèchéng.", "vi": "Học sinh có thể sắp xếp khóa học theo thời gian của mình."},
            {"cn": "专家认为这种方法需要更强的自律。", "py": "Zhuānjiā rènwéi zhè zhǒng fāngfǎ xūyào gèng qiáng de zìlǜ.", "vi": "Chuyên gia cho rằng phương pháp này cần tính tự giác cao hơn."},
        ],
    },
]


def write_json(path: Path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")


def main():
    reading_rows = [
        {"id": f"h{level[-1]}_{i+1}", "level": level, "cn": cn, "py": py, "vi": vi}
        for i, (level, cn, py, vi) in enumerate(reading)
    ]
    for article in news_seed:
        article["content"] = "".join(line["cn"] for line in article["sentences"])
    write_json(DATA / "reading_hsk.json", reading_rows)
    write_json(DATA / "video_lessons.json", video_lessons)
    write_json(DATA / "reading_news_seed.json", news_seed)
    print(f"reading_hsk.json: {len(reading_rows)} sentences")
    print(f"video_lessons.json: {len(video_lessons)} lessons")
    print(f"reading_news_seed.json: {len(news_seed)} articles")


if __name__ == "__main__":
    main()

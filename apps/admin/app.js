const STORAGE_KEY = 'vnchinese_admin_state_v2';
const DEFAULT_API_BASE_URL = 'http://127.0.0.1:3001';

const seedState = {
  vocabulary: [
    { id: uid(), simplified: '你好', pinyin: 'nǐ hǎo', meaningVi: 'xin chào', hsk: 'HSK 1', type: 'cụm từ', status: 'published' },
    { id: uid(), simplified: '学习', pinyin: 'xuéxí', meaningVi: 'học tập', hsk: 'HSK 1', type: 'động từ', status: 'published' },
    { id: uid(), simplified: '门', pinyin: 'mén', meaningVi: 'cửa', hsk: 'HSK 1', type: 'danh từ', status: 'published' },
    { id: uid(), simplified: '广告', pinyin: 'guǎnggào', meaningVi: 'quảng cáo', hsk: 'HSK 4', type: 'danh từ', status: 'published' },
    { id: uid(), simplified: '观众', pinyin: 'guānzhòng', meaningVi: 'khán giả', hsk: 'HSK 4', type: 'danh từ', status: 'published' },
    { id: uid(), simplified: '社会', pinyin: 'shèhuì', meaningVi: 'xã hội', hsk: 'HSK 4', type: 'danh từ', status: 'review' },
  ],
  flashcards: [
    {
      id: 'greeting',
      name: 'Chào hỏi',
      level: 'HSK 1',
      status: 'published',
      imagePath: '../mobile/assets/images/flashcards/greeting/1681525453.jpg',
      words: [
        word('你好', 'nǐ hǎo', 'xin chào'),
        word('谢谢', 'xièxie', 'cảm ơn'),
        word('再见', 'zàijiàn', 'tạm biệt'),
        word('请', 'qǐng', 'mời, xin'),
      ],
    },
    {
      id: 'home',
      name: 'Nhà cửa',
      level: 'HSK 1',
      status: 'published',
      imagePath: '../mobile/assets/images/flashcards/home/9bdfe95fda.jpg',
      words: [
        word('房间', 'fángjiān', 'phòng'),
        word('门', 'mén', 'cửa'),
        word('窗户', 'chuānghu', 'cửa sổ'),
        word('桌子', 'zhuōzi', 'cái bàn'),
      ],
    },
    {
      id: 'food',
      name: 'Ăn uống',
      level: 'HSK 1',
      status: 'published',
      imagePath: '../mobile/assets/images/flashcards/food/edfec00f07.jpg',
      words: [
        word('米饭', 'mǐfàn', 'cơm trắng'),
        word('苹果', 'píngguǒ', 'táo'),
        word('茶', 'chá', 'trà'),
        word('水', 'shuǐ', 'nước'),
      ],
    },
    {
      id: 'school',
      name: 'Trường học',
      level: 'HSK 2',
      status: 'published',
      imagePath: '../mobile/assets/images/flashcards/school/413b738061.jpg',
      words: [
        word('学校', 'xuéxiào', 'trường học'),
        word('老师', 'lǎoshī', 'giáo viên'),
        word('学生', 'xuésheng', 'học sinh'),
        word('考试', 'kǎoshì', 'thi cử'),
      ],
    },
    {
      id: 'transport',
      name: 'Giao thông',
      level: 'HSK 2',
      status: 'published',
      imagePath: '../mobile/assets/images/flashcards/transport/fed19a817b.jpg',
      words: [
        word('飞机', 'fēijī', 'máy bay'),
        word('汽车', 'qìchē', 'ô tô'),
        word('地铁', 'dìtiě', 'tàu điện ngầm'),
        word('车站', 'chēzhàn', 'bến xe, ga'),
      ],
    },
    {
      id: 'media_society',
      name: 'Truyền thông và xã hội',
      level: 'HSK 4',
      status: 'published',
      imagePath: '../mobile/assets/images/flashcards/media_society/d2fb1e3e17.jpg',
      words: [
        word('新闻', 'xīnwén', 'tin tức', 'd2fb1e3e17.jpg'),
        word('广告', 'guǎnggào', 'quảng cáo', '70ceb33a9b.jpg'),
        word('观众', 'guānzhòng', 'khán giả', '1ff96246c4.jpg'),
        word('网络', 'wǎngluò', 'mạng internet', '95521bb744.jpg'),
        word('社会', 'shèhuì', 'xã hội', 'ce4ba240fb.jpg'),
        word('文化', 'wénhuà', 'văn hóa', 'f9f7bb6679.jpg'),
        word('服务', 'fúwù', 'dịch vụ', '47d68cd0f4.jpg'),
        word('电视', 'diànshì', 'tivi', '3a2f904027.jpg'),
        word('交通', 'jiāotōng', 'giao thông', 'c8ace4e283.jpg'),
        word('电影', 'diànyǐng', 'phim', '51e9743451.jpg'),
      ],
    },
    {
      id: 'health',
      name: 'Sức khỏe',
      level: 'HSK 2',
      status: 'draft',
      imagePath: '../mobile/assets/images/flashcards/health/7be627ccbd.jpg',
      words: [
        word('身体', 'shēntǐ', 'cơ thể'),
        word('医生', 'yīshēng', 'bác sĩ'),
        word('医院', 'yīyuàn', 'bệnh viện'),
      ],
    },
  ],
  lessons: [
    { id: uid(), type: 'Ngữ pháp', title: 'Câu hỏi với 吗', level: 'HSK 1', items: 6, status: 'published' },
    { id: uid(), type: 'Đọc hiểu', title: 'Một ngày ở trường', level: 'HSK 2', items: 12, status: 'published' },
    { id: uid(), type: 'Video', title: 'Hello Song', level: 'HSK 1', items: 4, status: 'review', youtubeId: 'm_rDIzj6DRE', transcriptStatus: 'untimed' },
    {
      id: 'lf_hsk1_i_see',
      type: 'Video',
      title: 'I See',
      titleCn: '我看到',
      level: 'HSK 1',
      items: 13,
      status: 'published',
      youtubeId: 'VxAImi0LsS8',
      source: 'Little Fox Chinese',
      transcriptStatus: 'timed',
      transcript: [
        { start: 0.94, end: 10.28, cn: '小猴子，我看到。', py: 'Xiǎo hóuzi, wǒ kàn dào.', vi: 'Chú khỉ nhỏ, tôi nhìn thấy.' },
        { start: 24.24, end: 27.76, cn: '我看到石头。', py: 'Wǒ kàn dào shítou.', vi: 'Tôi nhìn thấy hòn đá.' },
        { start: 32.78, end: 36.34, cn: '我看到蚂蚁。', py: 'Wǒ kàn dào mǎyǐ.', vi: 'Tôi nhìn thấy con kiến.' },
        { start: 40.78, end: 47.4, cn: '我看到花。', py: 'Wǒ kàn dào huā.', vi: 'Tôi nhìn thấy bông hoa.' },
        { start: 55.95, end: 58.97, cn: '我看到蝴蝶。', py: 'Wǒ kàn dào húdié.', vi: 'Tôi nhìn thấy con bướm.' },
        { start: 65.16, end: 68.18, cn: '我看到蜜蜂。', py: 'Wǒ kàn dào mìfēng.', vi: 'Tôi nhìn thấy con ong.' },
        { start: 73.91, end: 81.68, cn: '我看到树。', py: 'Wǒ kàn dào shù.', vi: 'Tôi nhìn thấy cái cây.' },
        { start: 89.69, end: 92.67, cn: '我看到猫。', py: 'Wǒ kàn dào māo.', vi: 'Tôi nhìn thấy con mèo.' },
        { start: 95.31, end: 95.75, cn: '快跑！', py: 'Kuài pǎo!', vi: 'Chạy mau!' },
        { start: 109, end: 116.68, cn: '石头，我看到石头。', py: 'Shítou, wǒ kàn dào shítou.', vi: 'Hòn đá, tôi nhìn thấy hòn đá.' },
        { start: 118.86, end: 126.12, cn: '蚂蚁，我看到蚂蚁。', py: 'Mǎyǐ, wǒ kàn dào mǎyǐ.', vi: 'Con kiến, tôi nhìn thấy con kiến.' },
        { start: 128.7, end: 132.58, cn: '花，我看到花。', py: 'Huā, wǒ kàn dào huā.', vi: 'Bông hoa, tôi nhìn thấy bông hoa.' },
        { start: 136.4, end: 144.28, cn: '树，我看到树。', py: 'Shù, wǒ kàn dào shù.', vi: 'Cái cây, tôi nhìn thấy cái cây.' },
      ],
    },
    { id: uid(), type: 'Video', title: 'Weekend Travel Plans', level: 'HSK 3', items: 388, status: 'published', youtubeId: 'TlW4x4ExAws', transcriptStatus: 'timed' },
  ],
  grammar: [
    {
      id: 'grammar_ma_question',
      level: 'HSK 1',
      title: 'Câu hỏi với 吗',
      pattern: 'S + V/O + 吗？',
      explanation: 'Đặt 吗 ở cuối câu trần thuật để tạo câu hỏi có/không.',
      examples: [{ cn: '你好吗？', py: 'Nǐ hǎo ma?', vi: 'Bạn khỏe không?' }],
      note: 'Không dùng 吗 cùng từ nghi vấn như 什么, 谁.',
      status: 'published',
    },
  ],
  readingSources: [
    { id: 'chinanews', name: '中国新闻网', level: 'HSK 4', status: 'active', url: 'https://www.chinanews.com.cn/rss/scroll-news.xml' },
    { id: 'bbc', name: 'BBC 中文', level: 'HSK 4', status: 'active', url: 'https://feeds.bbci.co.uk/zhongwen/simp/rss.xml' },
    { id: 'rfi', name: 'RFI 中文', level: 'HSK 4', status: 'active', url: 'https://www.rfi.fr/cn/rss' },
  ],
  articles: [
    {
      id: 'reading_hsk1_school_day',
      level: 'HSK 1',
      source: 'VNChinese Easy News',
      title: '学校今天有中文活动',
      titleVi: 'Hôm nay trường có hoạt động tiếng Trung',
      summaryVi: 'Bài học HSK 1 về lớp học, giáo viên và hoạt động nói tiếng Trung.',
      content: '今天学校有中文活动。早上八点，学生们来到教室。老师先教大家读新词。每个学生说一句中文。有的学生读得很慢。老师说，慢慢读没有关系。下课以后，大家一起唱中文歌。这个活动让学生更喜欢学习中文。',
      link: '',
      status: 'published',
      sentences: [
        { cn: '今天学校有中文活动。', py: 'Jīntiān xuéxiào yǒu Zhōngwén huódòng.', vi: 'Hôm nay trường có hoạt động tiếng Trung.' },
        { cn: '早上八点，学生们来到教室。', py: 'Zǎoshang bā diǎn, xuéshengmen lái dào jiàoshì.', vi: 'Tám giờ sáng, học sinh đến lớp học.' },
        { cn: '老师先教大家读新词。', py: 'Lǎoshī xiān jiāo dàjiā dú xīn cí.', vi: 'Giáo viên trước tiên dạy mọi người đọc từ mới.' },
        { cn: '每个学生说一句中文。', py: 'Měi ge xuésheng shuō yí jù Zhōngwén.', vi: 'Mỗi học sinh nói một câu tiếng Trung.' },
        { cn: '有的学生读得很慢。', py: 'Yǒu de xuésheng dú de hěn màn.', vi: 'Có học sinh đọc khá chậm.' },
        { cn: '老师说，慢慢读没有关系。', py: 'Lǎoshī shuō, màn man dú méiyǒu guānxi.', vi: 'Giáo viên nói đọc chậm cũng không sao.' },
        { cn: '下课以后，大家一起唱中文歌。', py: 'Xiàkè yǐhòu, dàjiā yìqǐ chàng Zhōngwén gē.', vi: 'Sau giờ học, mọi người cùng hát bài tiếng Trung.' },
        { cn: '这个活动让学生更喜欢学习中文。', py: 'Zhège huódòng ràng xuésheng gèng xǐhuan xuéxí Zhōngwén.', vi: 'Hoạt động này khiến học sinh thích học tiếng Trung hơn.' },
      ],
    },
    {
      id: 'reading_hsk2_weekend_market',
      level: 'HSK 2',
      source: 'VNChinese Life',
      title: '周末市场和公园都很热闹',
      titleVi: 'Cuối tuần chợ và công viên đều nhộn nhịp',
      summaryVi: 'Bài học HSK 2 về sinh hoạt cuối tuần, mua sắm, thời tiết và gia đình.',
      content: '这个周末天气很好。很多人早上去市场买东西。水果比平时便宜一点。一位妈妈买了苹果和蔬菜。她说晚上要给家人做饭。下午，孩子们在公园跑步。老人坐在树下喝茶聊天。大家觉得这样的周末很舒服。',
      link: '',
      status: 'published',
      sentences: [
        { cn: '这个周末天气很好。', py: 'Zhège zhōumò tiānqì hěn hǎo.', vi: 'Cuối tuần này thời tiết rất đẹp.' },
        { cn: '很多人早上去市场买东西。', py: 'Hěn duō rén zǎoshang qù shìchǎng mǎi dōngxi.', vi: 'Nhiều người buổi sáng đi chợ mua đồ.' },
        { cn: '水果比平时便宜一点。', py: 'Shuǐguǒ bǐ píngshí piányi yìdiǎn.', vi: 'Trái cây rẻ hơn bình thường một chút.' },
        { cn: '一位妈妈买了苹果和蔬菜。', py: 'Yí wèi māma mǎi le píngguǒ hé shūcài.', vi: 'Một người mẹ đã mua táo và rau.' },
        { cn: '她说晚上要给家人做饭。', py: 'Tā shuō wǎnshang yào gěi jiārén zuò fàn.', vi: 'Cô ấy nói tối sẽ nấu cơm cho gia đình.' },
        { cn: '下午，孩子们在公园跑步。', py: 'Xiàwǔ, háizimen zài gōngyuán pǎobù.', vi: 'Buổi chiều, trẻ em chạy bộ trong công viên.' },
        { cn: '老人坐在树下喝茶聊天。', py: 'Lǎorén zuò zài shù xià hē chá liáotiān.', vi: 'Người lớn tuổi ngồi dưới cây uống trà nói chuyện.' },
        { cn: '大家觉得这样的周末很舒服。', py: 'Dàjiā juéde zhèyàng de zhōumò hěn shūfu.', vi: 'Mọi người thấy cuối tuần như vậy rất dễ chịu.' },
      ],
    },
    {
      id: 'reading_hsk3_library_corner',
      level: 'HSK 3',
      source: 'VNChinese Culture',
      title: '城市图书馆开设中文角',
      titleVi: 'Thư viện thành phố mở góc tiếng Trung',
      summaryVi: 'Bài học HSK 3 về góc tiếng Trung, luyện nói và cộng đồng học tập.',
      content: '城市图书馆最近开设了一个中文角。这个活动每个周六下午举行。参加的人有学生，也有上班族。大家先听一段短新闻。然后老师带大家一句一句地读。志愿者会帮助学习者改正发音。很多人说，跟别人一起练习更有动力。图书馆希望以后增加更多语言活动。',
      link: '',
      status: 'published',
      sentences: [
        { cn: '城市图书馆最近开设了一个中文角。', py: 'Chéngshì túshūguǎn zuìjìn kāishè le yí ge Zhōngwén jiǎo.', vi: 'Thư viện thành phố gần đây đã mở một góc tiếng Trung.' },
        { cn: '这个活动每个周六下午举行。', py: 'Zhège huódòng měi ge zhōuliù xiàwǔ jǔxíng.', vi: 'Hoạt động này diễn ra vào chiều thứ Bảy hằng tuần.' },
        { cn: '参加的人有学生，也有上班族。', py: 'Cānjiā de rén yǒu xuésheng, yě yǒu shàngbānzú.', vi: 'Người tham gia có học sinh và cả người đi làm.' },
        { cn: '大家先听一段短新闻。', py: 'Dàjiā xiān tīng yí duàn duǎn xīnwén.', vi: 'Mọi người trước tiên nghe một đoạn tin ngắn.' },
        { cn: '然后老师带大家一句一句地读。', py: 'Ránhòu lǎoshī dài dàjiā yí jù yí jù de dú.', vi: 'Sau đó giáo viên dẫn mọi người đọc từng câu một.' },
        { cn: '志愿者会帮助学习者改正发音。', py: 'Zhìyuànzhě huì bāngzhù xuéxízhě gǎizhèng fāyīn.', vi: 'Tình nguyện viên sẽ giúp người học sửa phát âm.' },
        { cn: '很多人说，跟别人一起练习更有动力。', py: 'Hěn duō rén shuō, gēn biérén yìqǐ liànxí gèng yǒu dònglì.', vi: 'Nhiều người nói luyện cùng người khác có động lực hơn.' },
        { cn: '图书馆希望以后增加更多语言活动。', py: 'Túshūguǎn xīwàng yǐhòu zēngjiā gèng duō yǔyán huódòng.', vi: 'Thư viện hy vọng sau này tăng thêm nhiều hoạt động ngôn ngữ.' },
      ],
    },
    {
      id: 'reading_hsk4_online_learning',
      level: 'HSK 4',
      source: 'VNChinese Focus',
      title: '网络课程改变学生的学习方式',
      titleVi: 'Khóa học trực tuyến thay đổi cách học của học sinh',
      summaryVi: 'Bài học HSK 4 về giáo dục trực tuyến, tính tự giác và hiệu quả học tập.',
      content: '近年来，网络课程正在改变学生获得知识的方式。学生可以根据自己的时间安排学习计划。有些课程还提供视频、练习题和自动评分。老师认为，这种方式可以帮助学生反复复习。不过，网络学习也需要更强的自律。如果没有计划，学生容易被手机和游戏影响。专家建议每天固定一个时间学习。只要坚持使用正确的方法，学习效果会越来越好。',
      link: '',
      status: 'published',
      sentences: [
        { cn: '近年来，网络课程正在改变学生获得知识的方式。', py: 'Jìnnián lái, wǎngluò kèchéng zhèngzài gǎibiàn xuésheng huòdé zhīshi de fāngshì.', vi: 'Những năm gần đây, khóa học trực tuyến đang thay đổi cách học sinh tiếp nhận kiến thức.' },
        { cn: '学生可以根据自己的时间安排学习计划。', py: 'Xuésheng kěyǐ gēnjù zìjǐ de shíjiān ānpái xuéxí jìhuà.', vi: 'Học sinh có thể sắp xếp kế hoạch học theo thời gian của mình.' },
        { cn: '有些课程还提供视频、练习题和自动评分。', py: 'Yǒuxiē kèchéng hái tígōng shìpín, liànxítí hé zìdòng píngfēn.', vi: 'Một số khóa còn cung cấp video, bài tập và chấm điểm tự động.' },
        { cn: '老师认为，这种方式可以帮助学生反复复习。', py: 'Lǎoshī rènwéi, zhè zhǒng fāngshì kěyǐ bāngzhù xuésheng fǎnfù fùxí.', vi: 'Giáo viên cho rằng cách này có thể giúp học sinh ôn tập nhiều lần.' },
        { cn: '不过，网络学习也需要更强的自律。', py: 'Búguò, wǎngluò xuéxí yě xūyào gèng qiáng de zìlǜ.', vi: 'Tuy vậy, học trực tuyến cũng cần tính tự giác cao hơn.' },
        { cn: '如果没有计划，学生容易被手机和游戏影响。', py: 'Rúguǒ méiyǒu jìhuà, xuésheng róngyì bèi shǒujī hé yóuxì yǐngxiǎng.', vi: 'Nếu không có kế hoạch, học sinh dễ bị điện thoại và trò chơi ảnh hưởng.' },
        { cn: '专家建议每天固定一个时间学习。', py: 'Zhuānjiā jiànyì měitiān gùdìng yí ge shíjiān xuéxí.', vi: 'Chuyên gia khuyên mỗi ngày cố định một thời gian để học.' },
        { cn: '只要坚持使用正确的方法，学习效果会越来越好。', py: 'Zhǐyào jiānchí shǐyòng zhèngquè de fāngfǎ, xuéxí xiàoguǒ huì yuè lái yuè hǎo.', vi: 'Chỉ cần kiên trì dùng phương pháp đúng, hiệu quả học sẽ ngày càng tốt.' },
      ],
    },
  ],
  pronunciation: [
    { id: 'h1_1', level: 'HSK 1', topic: 'Chào hỏi và phép lịch sự', cn: '你好！', py: 'Nǐ hǎo!', vi: 'Xin chào!', status: 'published' },
    { id: 'h2_23', level: 'HSK 2', topic: 'Học tập và du lịch', cn: '我坐飞机去北京。', py: 'Wǒ zuò fēijī qù Běijīng.', vi: 'Tôi đi máy bay đến Bắc Kinh.', status: 'published' },
    { id: 'h3_45', level: 'HSK 3', topic: 'Họp và xử lý công việc', cn: '这次会议非常重要。', py: 'Zhè cì huìyì fēicháng zhòngyào.', vi: 'Cuộc họp lần này rất quan trọng.', status: 'published' },
    { id: 'h4_75', level: 'HSK 4', topic: 'Công nghệ và truyền thông', cn: '网络改变了人们获得信息的方式。', py: 'Wǎngluò gǎibiàn le rénmen huòdé xìnxī de fāngshì.', vi: 'Internet đã thay đổi cách con người nhận thông tin.', status: 'published' },
  ],
  games: [
    { id: uid(), title: 'Quiz nghĩa từ', type: 'multiple_choice', scope: 'Theo chủ đề flashcard', status: 'published' },
    { id: uid(), title: 'Nghe và chọn từ', type: 'listening', scope: 'HSK 1-4', status: 'draft' },
    { id: uid(), title: 'Xếp câu đúng', type: 'sentence_order', scope: 'Ngữ pháp', status: 'draft' },
  ],
  aiSettings: {
    tutorEnabled: true,
    grammarEnabled: true,
    tutorPrompt: 'Gia sư tiếng Trung cho người Việt, luôn kèm pinyin và nghĩa Việt.',
    defaultLevel: 'HSK 2',
  },
  users: [
    { id: uid(), name: 'Nguyễn Minh Anh', email: 'minhanh@example.com', role: 'student', streak: 12, saved: 48, status: 'active' },
    { id: uid(), name: 'Content Editor', email: 'editor@vnchinese.local', role: 'editor', streak: 0, saved: 0, status: 'active' },
    { id: uid(), name: 'Demo Blocked', email: 'blocked@example.com', role: 'student', streak: 2, saved: 9, status: 'blocked' },
  ],
  review: [
    { id: uid(), area: 'Flashcard', title: 'Sức khỏe', issue: 'Topic đang ở trạng thái draft', severity: 'pending' },
    { id: uid(), area: 'Từ vựng', title: '社会', issue: 'Cần reviewer duyệt nghĩa Việt và ví dụ', severity: 'pending' },
  ],
  auditLogs: [],
  dashboard: null,
  settings: {
    apiBaseUrl: 'http://127.0.0.1:3001',
    contentVersion: '2026.06.04-admin',
    reviewerPolicy: 'Nội dung mới phải qua reviewer trước khi publish',
    exportTarget: 'apps/mobile/assets',
    mobileAssetRoot: '../mobile/assets',
  },
};

function foundationReadingArticle({
  id,
  level,
  title,
  titleVi,
  summaryVi,
  keywords,
  sentences,
}) {
  return {
    id,
    level,
    source: 'VNChinese',
    sourceType: 'seed_hsk',
    sourceLabel: 'Bài đọc HSK tự biên soạn',
    title,
    titleVi,
    summaryVi,
    keywords,
    content: sentences.map((sentence) => sentence.cn).join(''),
    link: '',
    status: 'published',
    sentences,
  };
}

// Original demo content written for VNChinese. It is intentionally not copied
// from any HSK textbook and is shared with the mobile seed/API catalogue.
const foundationReadingArticles = [
  foundationReadingArticle({
    id: 'seed_hsk1_daily_life',
    level: 'HSK 1',
    title: '每天的生活',
    titleVi: 'Cuộc sống hằng ngày',
    summaryVi: 'Bài đọc HSK 1 về giờ giấc, bữa sáng và việc học mỗi ngày.',
    keywords: ['每天', '起床', '牛奶', '学校', '晚上'],
    sentences: [
      { cn: '我每天七点起床。', py: 'Wǒ měitiān qī diǎn qǐchuáng.', vi: 'Tôi thức dậy lúc 7 giờ mỗi ngày.' },
      { cn: '早上我喝一杯牛奶，吃一片面包。', py: 'Zǎoshang wǒ hē yì bēi niúnǎi, chī yí piàn miànbāo.', vi: 'Buổi sáng tôi uống một cốc sữa và ăn một lát bánh mì.' },
      { cn: '八点我去学校学习汉语。', py: 'Bā diǎn wǒ qù xuéxiào xuéxí Hànyǔ.', vi: 'Tám giờ tôi đến trường học tiếng Trung.' },
      { cn: '中午我和朋友一起吃饭。', py: 'Zhōngwǔ wǒ hé péngyou yìqǐ chīfàn.', vi: 'Buổi trưa tôi ăn cơm cùng bạn.' },
      { cn: '下午我回家做作业。', py: 'Xiàwǔ wǒ huí jiā zuò zuòyè.', vi: 'Buổi chiều tôi về nhà làm bài tập.' },
      { cn: '晚上十点我睡觉。', py: 'Wǎnshang shí diǎn wǒ shuìjiào.', vi: 'Mười giờ tối tôi đi ngủ.' },
    ],
  }),
  foundationReadingArticle({
    id: 'seed_hsk1_my_family',
    level: 'HSK 1',
    title: '我的家',
    titleVi: 'Gia đình của tôi',
    summaryVi: 'Bài đọc HSK 1 giới thiệu các thành viên trong gia đình.',
    keywords: ['家', '爸爸', '妈妈', '姐姐', '喜欢'],
    sentences: [
      { cn: '我家有四个人。', py: 'Wǒ jiā yǒu sì ge rén.', vi: 'Gia đình tôi có bốn người.' },
      { cn: '爸爸是医生，妈妈是老师。', py: 'Bàba shì yīshēng, māma shì lǎoshī.', vi: 'Bố là bác sĩ, mẹ là giáo viên.' },
      { cn: '我有一个姐姐。', py: 'Wǒ yǒu yí ge jiějie.', vi: 'Tôi có một chị gái.' },
      { cn: '姐姐也喜欢学习汉语。', py: 'Jiějie yě xǐhuan xuéxí Hànyǔ.', vi: 'Chị gái cũng thích học tiếng Trung.' },
      { cn: '晚上我们一起吃饭，也一起看电视。', py: 'Wǎnshang wǒmen yìqǐ chīfàn, yě yìqǐ kàn diànshì.', vi: 'Buổi tối chúng tôi cùng ăn cơm và xem tivi.' },
      { cn: '我的家很开心。', py: 'Wǒ de jiā hěn kāixīn.', vi: 'Gia đình tôi rất vui vẻ.' },
    ],
  }),
  foundationReadingArticle({
    id: 'seed_hsk2_go_to_school',
    level: 'HSK 2',
    title: '去学校',
    titleVi: 'Đi học',
    summaryVi: 'Bài đọc HSK 2 về phương tiện đi lại và một buổi học ở trường.',
    keywords: ['公交车', '上课', '作业', '老师', '同学'],
    sentences: [
      { cn: '我家离学校不远，所以我每天坐公共汽车去学校。', py: 'Wǒ jiā lí xuéxiào bù yuǎn, suǒyǐ wǒ měitiān zuò gōnggòng qìchē qù xuéxiào.', vi: 'Nhà tôi không xa trường nên mỗi ngày tôi đi xe buýt đến trường.' },
      { cn: '路上常常很忙，但是我不会迟到。', py: 'Lùshang chángcháng hěn máng, dànshì wǒ bú huì chídào.', vi: 'Trên đường thường đông nhưng tôi không bị muộn.' },
      { cn: '第一节课是汉语课。', py: 'Dì yī jié kè shì Hànyǔ kè.', vi: 'Tiết đầu tiên là tiết tiếng Trung.' },
      { cn: '老师让我们先复习昨天的生词。', py: 'Lǎoshī ràng wǒmen xiān fùxí zuótiān de shēngcí.', vi: 'Giáo viên bảo chúng tôi ôn từ mới của hôm qua trước.' },
      { cn: '然后两个人一起练习对话。', py: 'Ránhòu liǎng ge rén yìqǐ liànxí duìhuà.', vi: 'Sau đó hai người cùng luyện hội thoại.' },
      { cn: '下课以后，我觉得今天学得很好。', py: 'Xiàkè yǐhòu, wǒ juéde jīntiān xué de hěn hǎo.', vi: 'Sau giờ học, tôi thấy hôm nay mình học rất tốt.' },
    ],
  }),
  foundationReadingArticle({
    id: 'seed_hsk2_shopping',
    level: 'HSK 2',
    title: '买东西',
    titleVi: 'Mua đồ',
    summaryVi: 'Bài đọc HSK 2 về mua sắm, giá cả và lời cảm ơn.',
    keywords: ['超市', '苹果', '牛奶', '多少钱', '便宜'],
    sentences: [
      { cn: '周末我和妈妈去商店买东西。', py: 'Zhōumò wǒ hé māma qù shāngdiàn mǎi dōngxi.', vi: 'Cuối tuần tôi và mẹ đi cửa hàng mua đồ.' },
      { cn: '妈妈想买一些水果，我想买一本汉语书。', py: 'Māma xiǎng mǎi yìxiē shuǐguǒ, wǒ xiǎng mǎi yì běn Hànyǔ shū.', vi: 'Mẹ muốn mua trái cây, còn tôi muốn mua một quyển sách tiếng Trung.' },
      { cn: '苹果很新鲜，也不太贵。', py: 'Píngguǒ hěn xīnxiān, yě bú tài guì.', vi: 'Táo rất tươi và cũng không quá đắt.' },
      { cn: '书店的店员告诉我，这本书正在打折。', py: 'Shūdiàn de diànyuán gàosu wǒ, zhè běn shū zhèngzài dǎzhé.', vi: 'Nhân viên nhà sách nói với tôi rằng quyển sách này đang giảm giá.' },
      { cn: '最后我们买了水果、牛奶和一本书。', py: 'Zuìhòu wǒmen mǎi le shuǐguǒ, niúnǎi hé yì běn shū.', vi: 'Cuối cùng chúng tôi mua trái cây, sữa và một quyển sách.' },
      { cn: '回家的时候，我对妈妈说今天买得很合适。', py: 'Huí jiā de shíhou, wǒ duì māma shuō jīntiān mǎi de hěn héshì.', vi: 'Trên đường về nhà, tôi nói với mẹ rằng hôm nay mua đồ rất hợp lý.' },
    ],
  }),
];

let state = loadState();
let activeView = 'dashboard';
let globalQuery = '';
let vocabularyFilter = 'Tất cả';
let flashcardLevelFilter = 'Tất cả';
let lessonFilter = 'Tất cả';
let lessonLevelFilter = 'Tất cả';
let grammarFilter = 'Tất cả';
let articleFilter = 'Tất cả';
let userFilter = 'Tất cả';
let videoLevelFilter = 'Tất cả';
let videoVisibilityFilter = 'Tất cả';
let reviewFilter = 'Tất cả';
let gameLevelFilter = 'Tất cả';
let adminToken = sessionStorage.getItem('vnchinese_admin_token') || '';
let currentAdmin = JSON.parse(sessionStorage.getItem('vnchinese_admin_user') || 'null');

const VIDEO_UNAVAILABLE_IDS = new Set([
  'NjKooVPp8-s',
  'YmTB_nQxJQj',
  'Aqs0VrMEeXQ',
  'jMEW0KcwBdY',
  'MPuvcZCu5f9',
  '8K7BNGGjGiA',
  'hYM-F05V02A',
]);
const VIDEO_MIN_SUBTITLES = 8;
const VIDEO_MIN_SPAN_SECONDS = 20;

function normalizeApiBaseUrl(value) {
  const raw = String(value || '').trim().replace(/\/+$/, '');
  if (!raw) return DEFAULT_API_BASE_URL;
  return raw;
}

function unique(values) {
  return [...new Set(values.filter(Boolean))];
}

function apiBaseCandidates() {
  const host = window.location.hostname || '127.0.0.1';
  const protocol = window.location.protocol === 'https:' ? 'https:' : 'http:';
  return unique([
    normalizeApiBaseUrl(state.settings?.apiBaseUrl),
    '/api',
    `${protocol}//${host}:3001`,
    DEFAULT_API_BASE_URL,
    'http://localhost:3001',
  ]);
}

function rememberApiBaseUrl(baseUrl) {
  if (!baseUrl || baseUrl === state.settings.apiBaseUrl) return;
  state.settings.apiBaseUrl = baseUrl;
  saveState();
}

function apiConnectionError(lastError) {
  const detail = lastError?.message ? ` (${lastError.message})` : '';
  return `Không kết nối được API VNChinese${detail}. Hãy chạy scripts/start-vnchinese-dev.ps1 để bật backend.`;
}

async function fetchApi(path, options = {}) {
  let lastError = null;
  for (const baseUrl of apiBaseCandidates()) {
    try {
      const response = await fetch(`${baseUrl}${path}`, options);
      if (response.status === 404) {
        lastError = new Error(`${baseUrl}${path} HTTP 404`);
        continue;
      }
      rememberApiBaseUrl(baseUrl);
      return response;
    } catch (error) {
      lastError = error;
    }
  }
  throw new Error(apiConnectionError(lastError));
}

const appShell = document.querySelector('#appShell');
const adminLogin = document.querySelector('#adminLogin');
const adminLoginForm = document.querySelector('#adminLoginForm');
const adminLoginError = document.querySelector('#adminLoginError');
const viewRoot = document.querySelector('#viewRoot');
const viewTitle = document.querySelector('#viewTitle');
const toast = document.querySelector('#toast');
const searchInput = document.querySelector('#globalSearch');
const importJsonInput = document.querySelector('#importJsonInput');
const dialog = document.querySelector('#editorDialog');
const dialogTitle = document.querySelector('#dialogTitle');
const dialogEyebrow = document.querySelector('#dialogEyebrow');
const dialogFields = document.querySelector('#dialogFields');
const editorForm = document.querySelector('#editorForm');
const imageUploadInput = document.querySelector('#imageUploadInput');
const apiStatus = document.querySelector('#apiStatus');
const publishContentButton = document.querySelector('#publishContentBtn');
const adminIdentity = document.querySelector('#adminIdentity');

document.querySelectorAll('.nav-item').forEach((button) => {
  button.addEventListener('click', () => {
    activeView = button.dataset.view;
    document.querySelectorAll('.nav-item').forEach((item) => item.classList.remove('is-active'));
    button.classList.add('is-active');
    render();
  });
});

searchInput.addEventListener('input', (event) => {
  globalQuery = event.target.value.trim().toLowerCase();
  render();
});

document.querySelector('#qaButton').addEventListener('click', () => {
  const issues = runQualityChecks();
  state.review = mergeReviewIssues(state.review, issues);
  saveState();
  activeView = 'review';
  setActiveNav();
  render();
  showToast(`Đã kiểm tra chất lượng: ${issues.length} cảnh báo.`);
});

document.querySelector('#resetButton').addEventListener('click', () => {
  if (!confirm('Khôi phục dữ liệu mẫu admin?')) return;
  state = structuredClone(seedState);
  saveState();
  render();
  showToast('Đã khôi phục dữ liệu mẫu.');
});

document.querySelector('#exportBundleBtn').addEventListener('click', exportContentBundle);
publishContentButton.addEventListener('click', publishContentToApi);
document.querySelector('#adminLogoutBtn').addEventListener('click', () => {
  adminToken = '';
  currentAdmin = null;
  sessionStorage.removeItem('vnchinese_admin_token');
  sessionStorage.removeItem('vnchinese_admin_user');
  appShell.classList.add('is-hidden');
  adminLogin.classList.remove('is-hidden');
});
importJsonInput.addEventListener('change', importJsonFile);

adminLoginForm.addEventListener('submit', loginAdmin);
document.querySelector('#offlineAdminBtn').addEventListener('click', () => enterAdmin(false));

if (adminToken) {
  enterAdmin(true);
} else {
  adminLogin.classList.remove('is-hidden');
}

async function loginAdmin(event) {
  event.preventDefault();
  adminLoginError.textContent = '';
  try {
    const response = await fetchApi('/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: document.querySelector('#adminEmail').value.trim(),
        password: document.querySelector('#adminPassword').value,
      }),
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
    if (data.user?.role !== 'admin') throw new Error('Tài khoản không có quyền admin.');
    adminToken = data.token;
    currentAdmin = data.user;
    sessionStorage.setItem('vnchinese_admin_token', adminToken);
    sessionStorage.setItem('vnchinese_admin_user', JSON.stringify(data.user));
    adminLogin.classList.add('is-hidden');
    appShell.classList.remove('is-hidden');
    enterAdmin(true).catch((loadError) => {
      showToast(`Da dang nhap, nhung chua tai xong du lieu admin: ${loadError.message}`);
      render();
      refreshApiStatus();
    });
  } catch (error) {
    adminLoginError.textContent = formatLoginError(error.message);
  }
}

function formatLoginError(message) {
  if (/failed to fetch|network|khong ket noi|không kết nối|Khong ket noi/i.test(message)) {
    return 'Admin chưa kết nối được API. Hệ thống đã thử localhost và 127.0.0.1:3001; hãy chạy scripts/start-vnchinese-dev.ps1 nếu backend đang tắt.';
  }
  if (/database|postgres|docker|503/i.test(message)) {
    return 'Database chưa sẵn sàng. Hãy bật Docker/PostgreSQL, sau đó đăng nhập lại bằng admin123456.';
  }
  if (/401|Unauthorized|chua dung|chưa đúng/i.test(message)) {
    return 'Email hoặc mật khẩu chưa đúng. Mật khẩu admin mặc định là admin123456, viết liền.';
  }
  return message || 'Không thể đăng nhập admin.';
}

async function enterAdmin(syncUsers) {
  adminLogin.classList.add('is-hidden');
  appShell.classList.remove('is-hidden');
  if (syncUsers && adminToken) {
    await Promise.all([
      loadAdminDashboard(false),
      loadPublishedContent(false),
      loadBackendUsers(false),
      loadAuditLogs(false),
    ]);
  }
  render();
  refreshApiStatus();
}

function render() {
  const titles = {
    dashboard: 'Tổng quan',
    vocabulary: 'Quản lý từ vựng',
    flashcards: 'Quản lý flashcard',
    lessons: 'Quản lý bài học',
    videos: 'Video và transcript',
    reading: 'Nguồn báo và bài đọc',
    speaking: 'Tình huống luyện nói',
    games: 'Quiz và trò chơi',
    users: 'Quản lý người dùng',
    ai: 'Trung tâm AI',
    review: 'Kiểm duyệt nội dung',
    settings: 'Cấu hình hệ thống',
  };
  viewTitle.textContent = titles[activeView] || 'Admin';
  adminIdentity.textContent = currentAdmin
    ? `${currentAdmin.displayName || currentAdmin.email} · ${currentAdmin.role}`
    : adminToken
      ? 'Admin trực tuyến'
      : 'Offline admin';
  const renderer = {
    dashboard: renderDashboard,
    vocabulary: renderVocabulary,
    flashcards: renderFlashcards,
    lessons: renderLessons,
    videos: renderVideos,
    reading: renderReading,
    speaking: renderSpeaking,
    games: renderGames,
    users: renderUsers,
    ai: renderAiStudio,
    review: renderReview,
    settings: renderSettings,
  }[activeView];
  viewRoot.innerHTML = '';
  const rendered = renderer();
  if (!adminToken) rendered.prepend(offlineModeNotice());
  viewRoot.appendChild(rendered);
}

function offlineModeNotice() {
  return el('div', { class: 'admin-alert warning' }, [
    el('strong', {}, 'Đang ở chế độ offline admin'),
    el('span', {}, 'Các thay đổi chỉ lưu trên trình duyệt/localStorage và chưa xuất bản sang backend hay app user. Hãy đăng nhập API trước khi demo publish.'),
  ]);
}

function renderDashboard() {
  const root = el('div', { class: 'view-root' });
  const topicWords = state.flashcards.reduce((sum, topic) => sum + topic.words.length, 0);
  const videos = state.lessons.filter((lesson) => lesson.type === 'Video');
  const dashboard = state.dashboard || {};
  const userStats = dashboard.users || {};
  const learning = dashboard.learning || {};
  const content = dashboard.content || {};
  const publishedContentCount = Number(dashboard.latestVersion?.itemCount || 0)
    || (content.vocabulary
      ? content.vocabulary + content.grammar + content.articles + content.pronunciation + content.videos
      : state.vocabulary.length + topicWords);
  root.appendChild(metricGrid([
    ['Người dùng', userStats.total ?? state.users.length, `${userStats.newThisWeek || 0} mới tuần này`],
    ['Học viên hoạt động', learning.learnersWeek ?? 0, `${learning.activeToday || 0} hôm nay`],
    ['Phút học tuần', learning.studyMinutesWeek ?? 0, `${learning.learnedWordsWeek || 0} từ mới`],
    ['Nội dung publish', publishedContentCount, `${content.pendingReview || 0} mục chờ duyệt`],
    ['Kho từ điển', content.vocabulary ?? state.vocabulary.length, 'mục DB để tra cứu'],
    ['Từ vựng bài học', topicWords, `${state.flashcards.length} topic flashcard`],
    ['Video đã khớp', videos.filter((video) => video.transcriptStatus === 'timed').length, `${content.videos || videos.length} video`],
  ]));

  const split = el('div', { class: 'split-grid' });
  split.appendChild(panel('Nhịp học 7 ngày', adminActivityChart(dashboard.activity || [])));
  split.appendChild(panel('Phân bổ HSK', hskDistribution(dashboard.hskDistribution || [])));
  root.appendChild(split);
  root.appendChild(toolbar('Thao tác nhanh', [
    button('↻ Đồng bộ dashboard', 'ghost-button', () => loadAdminDashboard(true)),
    button('↻ Tải lại nội dung DB', 'ghost-button', () => loadPublishedContent(true)),
    button('↻ Đồng bộ users', 'ghost-button', () => loadBackendUsers(true)),
  ]));
  const health = el('div', { class: 'split-grid' });
  health.appendChild(panel('Tình trạng nội dung', qualitySummary()));
  health.appendChild(panel('Luồng publish', publishFlow()));
  root.appendChild(health);
  root.appendChild(panel('Kết nối với app VNChinese', appConnectionSummary()));
  root.appendChild(panel('Kiểm tra nhanh AI ngữ pháp', grammarApiQuickPanel()));
  root.appendChild(renderRecentActivity());
  return root;
}

function renderVocabulary() {
  const root = el('div', { class: 'view-root' });
  root.appendChild(toolbar('Danh sách từ vựng', [
    select(['Tất cả', 'HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'], vocabularyFilter, (value) => {
      vocabularyFilter = value;
      render();
    }),
    button('＋ Thêm từ', 'primary-button', () => openVocabularyEditor()),
  ]));

  const rows = state.vocabulary
    .filter((item) => vocabularyFilter === 'Tất cả' || item.hsk === vocabularyFilter)
    .filter((item) => matchesQuery([item.simplified, item.pinyin, item.meaningVi, item.hsk, item.type]));

  root.appendChild(tablePanel(['Từ', 'Pinyin', 'Nghĩa Việt', 'HSK', 'Loại', 'Trạng thái', ''], rows.map((item) => [
    strongText(item.simplified),
    item.pinyin,
    item.meaningVi,
    item.hsk,
    item.type,
    status(item.status),
    rowActions([
      ['Sửa', () => openVocabularyEditor(item)],
      ['Xóa', () => deleteItem('vocabulary', item.id)],
    ]),
  ])));
  return root;
}

function renderFlashcards() {
  const root = el('div', { class: 'view-root' });
  root.appendChild(panel('Cách nạp chủ đề và flashcard', el('div', { class: 'admin-guide' }, [
    el('div', {}, [el('strong', {}, '1. Tạo chủ đề'), el('p', {}, 'Bấm “Thêm topic”, nhập mã không dấu, tên chủ đề, HSK và ảnh đại diện.')]),
    el('div', {}, [el('strong', {}, '2. Nhập từng từ'), el('p', {}, 'Mỗi dòng: Hán tự | pinyin có dấu | nghĩa Việt | tên ảnh | câu Trung | pinyin câu | dịch câu.')]),
    el('div', {}, [el('strong', {}, '3. Đưa sang app'), el('p', {}, 'Chuyển trạng thái published, xuất index rồi đặt file và ảnh vào assets/images/flashcards/<mã-topic>/.')]),
  ])));
  root.appendChild(toolbar('Chủ đề flashcard', [
    select(['Tất cả', ...hskLevelOptions(state.flashcards)], flashcardLevelFilter, (value) => {
      flashcardLevelFilter = value;
      render();
    }),
    button('⇧ Import JSON', 'ghost-button', () => importJsonInput.click()),
    button('↻ Nạp từ app user', 'ghost-button', loadMobileFlashcardIndex),
    button('＋ Thêm topic', 'primary-button', () => openTopicEditor()),
    button('⇩ Xuất index', 'ghost-button', exportFlashcardIndex),
  ]));

  const grid = el('div', { class: 'topic-grid' });
  state.flashcards
    .filter((topic) => flashcardLevelFilter === 'Tất cả' || topic.level === flashcardLevelFilter)
    .filter((topic) => matchesQuery([topic.name, topic.level, topic.status, topic.words.map((w) => w.word).join(' ')]))
    .forEach((topic) => {
      const media = topicImage(topic);
      const meta = el('div', { class: 'topic-meta' }, [
        el('div', {}, [
          el('h3', {}, topic.name),
          el('p', {}, `${topic.level} · ${topic.words.length} từ`),
        ]),
        status(topic.status),
      ]);
      const words = el('ul', { class: 'word-list' }, topic.words.slice(0, 10).map((item) => el('li', {}, item.word)));
      const actions = el('div', { class: 'toolbar-group' }, [
        button('Sửa', 'ghost-button', () => openTopicEditor(topic)),
        button('Đăng ảnh', 'ghost-button', () => uploadTopicImage(topic.id)),
        button('Nhân bản', 'ghost-button', () => duplicateTopic(topic.id)),
        button('Xóa', 'ghost-button', () => deleteItem('flashcards', topic.id)),
      ]);
      grid.appendChild(el('article', { class: 'topic-tile' }, [
        media,
        meta,
        el('p', { class: 'topic-note' }, topicImageUrl(topic) ? `Ảnh: ${imageFileName(topicImageUrl(topic)) || topicImageUrl(topic)}` : 'Chưa có ảnh đại diện'),
        words,
        actions,
      ]));
    });
  if (!grid.children.length) grid.appendChild(emptyState('Không có topic phù hợp.'));
  root.appendChild(grid);
  return root;
}

function renderLessons() {
  const root = el('div', { class: 'view-root' });
  const components = lessonComponentInventory();
  root.appendChild(toolbar('Bài học tổng hợp', [
    select(['Tất cả', ...hskLevelOptions(components)], lessonLevelFilter, (value) => {
      lessonLevelFilter = value;
      render();
    }),
    select(['Tất cả', 'Ngữ pháp', 'Đọc hiểu', 'Video'], lessonFilter, (value) => {
      lessonFilter = value;
      render();
    }),
    button('⇩ Xuất lesson map', 'ghost-button', exportLessonMap),
    button('＋ Thêm bài', 'primary-button', () => openLessonEditor()),
  ]));
  root.appendChild(lessonWorkspace(components));
  root.appendChild(toolbar('Thư viện ngữ pháp', [
    select(['Tất cả', 'HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6'], grammarFilter, (value) => {
      grammarFilter = value;
      render();
    }),
    button('＋ Thêm ngữ pháp', 'primary-button', () => openGrammarEditor()),
  ]));
  const grammarRows = (state.grammar || [])
    .filter((item) => grammarFilter === 'Tất cả' || item.level === grammarFilter)
    .filter((item) => matchesQuery([item.level, item.title, item.pattern, item.explanation, item.status]));
  root.appendChild(tablePanel(['HSK', 'Mẫu câu', 'Cấu trúc', 'Ví dụ', 'Trạng thái', ''], grammarRows.map((item) => [
    item.level,
    strongText(item.title),
    item.pattern || '',
    Array.isArray(item.examples) ? item.examples.length : 0,
    status(item.status),
    rowActions([
      ['Sửa', () => openGrammarEditor(item)],
      ['Lưu trữ', () => deleteItem('grammar', item.id)],
    ]),
  ])));
  return root;
}

function lessonWorkspace(components) {
  const filtered = components
    .filter((item) => lessonLevelFilter === 'Tất cả' || item.level === lessonLevelFilter)
    .filter((item) => lessonFilter === 'Tất cả' || item.type === lessonFilter)
    .filter((item) => matchesQuery([item.level, item.subject, item.type, item.title, item.status]));
  const tree = lessonTree(filtered);
  const rows = filtered.map((item) => [
    el('div', { class: 'lesson-title-cell' }, [
      strongText(item.title),
      el('span', {}, `${item.subject} · ${item.source}`),
    ]),
    item.level,
    item.type,
    item.items,
    status(item.status),
    rowActions([
      ['Sửa', () => editLessonComponent(item)],
      ['Preview', () => previewLessonComponent(item)],
      ['Xóa', () => deleteLessonComponent(item)],
    ]),
  ]);
  return el('section', { class: 'lesson-workspace panel' }, [
    el('div', { class: 'lesson-workspace-head' }, [
      el('div', {}, [
        el('h2', {}, 'Lesson-centric workspace'),
        el('p', { class: 'topic-note' }, 'Quản lý theo container: HSK → Chủ đề → Loại nội dung. Mỗi dòng bên phải có thể sửa trực tiếp component gốc.'),
      ]),
      metricGrid([
        ['Container', countLessonContainers(filtered), 'HSK/chủ đề'],
        ['Component', filtered.length, 'đang quản lý'],
        ['Published', filtered.filter((item) => item.status === 'published').length, 'đã xuất bản'],
      ]),
    ]),
    el('div', { class: 'lesson-workspace-grid' }, [
      tree,
      tablePanel(['Bài học / Component', 'HSK', 'Loại', 'Số mục', 'Trạng thái', ''], rows),
    ]),
  ]);
}

function lessonTree(components) {
  const grouped = new Map();
  components.forEach((item) => {
    const level = item.level || 'HSK ?';
    const subject = item.subject || 'Chưa phân loại';
    const type = item.type || 'Component';
    if (!grouped.has(level)) grouped.set(level, new Map());
    const subjects = grouped.get(level);
    if (!subjects.has(subject)) subjects.set(subject, new Map());
    const types = subjects.get(subject);
    if (!types.has(type)) types.set(type, []);
    types.get(type).push(item);
  });

  const levels = [...grouped.keys()].sort((a, b) => a.localeCompare(b, 'vi'));
  if (!levels.length) return emptyState('Không có component phù hợp.');
  return el('aside', { class: 'lesson-tree' }, levels.map((level, levelIndex) => {
    const subjects = grouped.get(level);
    return el('details', { class: 'lesson-node', open: levelIndex < 2 ? 'open' : '' }, [
      el('summary', {}, [
        el('strong', {}, level),
        el('span', {}, `${countNestedItems(subjects)} nội dung`),
      ]),
      el('div', { class: 'lesson-branches' }, [...subjects.entries()].map(([subject, types]) => (
        el('details', { class: 'lesson-node subject-node', open: 'open' }, [
          el('summary', {}, [
            el('strong', {}, subject),
            el('span', {}, `${countNestedItems(types)} mục`),
          ]),
          el('div', { class: 'lesson-type-grid' }, [...types.entries()].map(([type, items]) => (
            el('section', { class: 'lesson-type-card' }, [
              el('div', { class: 'lesson-type-head' }, [
                el('strong', {}, type),
                status(`${items.length}`),
              ]),
              el('ul', { class: 'lesson-component-list' }, items.map((item) => (
                el('li', {}, [
                  el('span', { class: 'component-title' }, item.title),
                  el('span', { class: 'component-meta' }, `${item.status} · ${item.items || 0} mục`),
                  button('Sửa', 'text-action', () => editLessonComponent(item)),
                ])
              ))),
            ])
          ))),
        ])
      ))),
    ]);
  }));
}

function lessonComponentInventory() {
  const fromLessons = state.lessons.map((lesson) => ({
    id: lesson.id,
    title: lesson.title,
    level: lesson.level,
    subject: lesson.subject || subjectFromText(`${lesson.title} ${lesson.type}`),
    type: lesson.type,
    status: lesson.status,
    items: lesson.items || (Array.isArray(lesson.transcript) ? lesson.transcript.length : 0),
    source: 'lessons',
  }));
  const fromFlashcards = state.flashcards.map((topic) => ({
    id: topic.id,
    title: topic.name,
    level: topic.level,
    subject: topic.subject || subjectFromText(`${topic.name} ${topic.id}`),
    type: 'Flashcard',
    status: topic.status,
    items: topic.words?.length || 0,
    source: 'flashcards',
  }));
  const fromGrammar = (state.grammar || []).map((item) => ({
    id: item.id,
    title: item.title,
    level: item.level,
    subject: item.subject || subjectFromText(`${item.title} ${item.pattern}`),
    type: 'Ngữ pháp',
    status: item.status,
    items: Array.isArray(item.examples) ? item.examples.length : 0,
    source: 'grammar',
  }));
  return [...fromLessons, ...fromFlashcards, ...fromGrammar]
    .filter((item) => item.status !== 'archived')
    .sort((a, b) => `${a.level}${a.subject}${a.type}${a.title}`.localeCompare(`${b.level}${b.subject}${b.type}${b.title}`, 'vi'));
}

function subjectFromText(text) {
  const raw = String(text || '').toLowerCase();
  const rules = [
    ['Chào hỏi', ['chào', 'greeting', 'hello', '你好']],
    ['Gia đình', ['gia đình', 'family', '爸爸', '妈妈']],
    ['Đồ ăn', ['ăn', 'food', 'mua sắm', 'shopping', '米饭', '点菜']],
    ['Trường học', ['trường', 'school', 'học', '学习']],
    ['Giao thông', ['giao thông', 'transport', 'du lịch', 'travel', '车', '飞机']],
    ['Sức khỏe', ['sức khỏe', 'health', 'body', '身体']],
    ['Công việc', ['công việc', 'business', 'work', 'kinh doanh']],
    ['Truyền thông', ['truyền thông', 'media', 'news', '新闻']],
    ['Ngữ pháp nền tảng', ['吗', 'ngữ pháp', 'grammar']],
    ['Video shadowing', ['video', 'song', 'shadowing']],
  ];
  const found = rules.find(([, keys]) => keys.some((key) => raw.includes(String(key).toLowerCase())));
  return found ? found[0] : 'Tổng hợp';
}

function countNestedItems(map) {
  let count = 0;
  map.forEach((value) => {
    if (value instanceof Map) count += countNestedItems(value);
    else if (Array.isArray(value)) count += value.length;
  });
  return count;
}

function countLessonContainers(items) {
  return new Set(items.map((item) => `${item.level}|${item.subject}`)).size;
}

function editLessonComponent(item) {
  if (item.source === 'flashcards') {
    const topic = state.flashcards.find((entry) => entry.id === item.id);
    if (topic) openTopicEditor(topic);
    return;
  }
  if (item.source === 'grammar') {
    const grammar = (state.grammar || []).find((entry) => entry.id === item.id);
    if (grammar) openGrammarEditor(grammar);
    return;
  }
  if (item.source === 'lessons') {
    const lesson = state.lessons.find((entry) => entry.id === item.id);
    if (!lesson) return;
    if (lesson.type === 'Video') openVideoEditor(lesson);
    else openLessonEditor(lesson);
  }
}

function previewLessonComponent(item) {
  const payload = {
    level: item.level,
    subject: item.subject,
    type: item.type,
    title: item.title,
    status: item.status,
    items: item.items,
    source: item.source,
    id: item.id,
  };
  downloadJson(`${slug(item.title || item.id)}.lesson-preview.json`, payload);
}

function deleteLessonComponent(item) {
  if (!confirm(`Xóa "${item.title}" khỏi ${item.source}?`)) return;
  if (item.source === 'flashcards') deleteItem('flashcards', item.id);
  else if (item.source === 'grammar') deleteItem('grammar', item.id);
  else deleteItem('lessons', item.id);
}

function renderVideos() {
  const root = el('div', { class: 'view-root' });
  const videos = state.lessons.filter((lesson) => lesson.type === 'Video');
  const timed = videos.filter((video) => video.transcriptStatus === 'timed').length;
  const readyVideos = videos.filter((video) => videoUserVisibility(video).ready);
  const needsTranscript = videos.filter((video) => {
    const result = videoUserVisibility(video);
    return !result.ready && result.reasons.some((reason) => /phụ đề|timing|span|câu/i.test(reason));
  }).length;
  const deadOrMissing = videos.filter((video) => ['dead', 'missing'].includes(String(video.youtubeStatus || '').toLowerCase()) || !String(video.youtubeId || '').trim()).length;
  const filteredVideos = videos
    .filter((video) => videoLevelFilter === 'Tất cả' || video.level === videoLevelFilter)
    .filter((video) => {
      const visibility = videoUserVisibility(video);
      if (videoVisibilityFilter === 'Tất cả') return true;
      if (videoVisibilityFilter === 'Hiện trong app') return visibility.ready;
      if (videoVisibilityFilter === 'Chưa hiện trong app') return !visibility.ready;
      return video.status === videoVisibilityFilter || video.transcriptStatus === videoVisibilityFilter;
    })
    .filter((video) => matchesQuery([video.title, video.titleCn, video.level, video.youtubeId, video.status, video.transcriptStatus]));
  root.appendChild(metricGrid([
    ['Video', videos.length, 'YouTube lessons'],
    ['Đã khớp câu', timed, 'có start/end'],
    ['Hiện trong app', readyVideos.length, 'đủ điều kiện mobile'],
    ['Cần bổ sung', needsTranscript + deadOrMissing, 'timing, câu hoặc link'],
  ]));
  root.appendChild(toolbar('Thư viện video shadowing', [
    select(['Tất cả', ...hskLevelOptions(videos)], videoLevelFilter, (value) => {
      videoLevelFilter = value;
      render();
    }),
    select(['Tất cả', 'Hiện trong app', 'Chưa hiện trong app', 'published', 'draft', 'review', 'timed', 'untimed'], videoVisibilityFilter, (value) => {
      videoVisibilityFilter = value;
      render();
    }),
    button('↻ Đồng bộ & kiểm tra video', 'ghost-button', checkAllYoutubeVideos),
    button('⇩ Xuất video catalog', 'ghost-button', exportVideoCatalog),
    button('＋ Thêm video', 'primary-button', () => openVideoEditor()),
  ]));
  root.appendChild(tablePanel(
    ['Tiêu đề', 'YouTube ID', 'HSK', 'Phụ đề', 'User app', 'YouTube', 'Timing', 'Trạng thái', ''],
    filteredVideos.map((video) => {
      const visibility = videoUserVisibility(video);
      const transcript = videoTranscript(video);
      const span = transcriptSpanSeconds(transcript);
      return [
      el('div', { class: 'lesson-title-cell' }, [
        strongText(video.title),
        el('span', {}, video.titleCn || video.source || 'YouTube'),
      ]),
      video.youtubeId || 'Chưa có',
      video.level,
      el('div', { class: 'video-density-cell' }, [
        strongText(`${transcript.length || video.items || 0} câu`),
        el('span', {}, span ? `${Math.round(span)} giây transcript` : 'chưa có span'),
        transcript.length < VIDEO_MIN_SUBTITLES ? status('ít câu') : '',
      ]),
      videoVisibilityCell(visibility),
      youtubeStatusCell(video),
      status(video.transcriptStatus === 'timed' ? 'approved' : 'pending'),
      status(video.status),
      rowActions([
        ['Check', () => checkYoutubeVideo(video)],
        ['Transcript', () => openVideoEditor(video)],
        ['QA', () => openVideoQa(video)],
        ['Xóa', () => deleteItem('lessons', video.id)],
      ]),
    ];
    }),
  ));
  root.appendChild(panel(
    'Quy tắc hiển thị video ở app user',
    el('div', { class: 'admin-guide compact-guide' }, [
      el('div', {}, [el('strong', {}, 'Hiện trong app'), el('p', {}, `Video phải published, có YouTube ID, không dead link, transcript timed, tối thiểu ${VIDEO_MIN_SUBTITLES} câu và span tối thiểu ${VIDEO_MIN_SPAN_SECONDS} giây.`)]),
      el('div', {}, [el('strong', {}, 'Video dài nhưng ít câu'), el('p', {}, 'Admin sẽ đánh dấu "ít câu" để bạn bổ sung transcript. Nếu chỉ có 4-5 câu, người học không có đủ điểm dừng để shadowing.')]),
      el('div', {}, [el('strong', {}, 'Định dạng transcript'), el('p', {}, 'Mỗi dòng: start giây | end giây | câu Trung | pinyin có dấu | nghĩa Việt. Timing không được chồng nhau.')]),
    ]),
  ));
  return root;
}

function videoTranscript(video) {
  if (Array.isArray(video?.transcript)) return video.transcript;
  if (Array.isArray(video?.subtitles)) return video.subtitles;
  return [];
}

function transcriptSpanSeconds(transcript) {
  const rows = Array.isArray(transcript) ? transcript : [];
  if (!rows.length) return 0;
  const starts = rows.map((line) => Number(line.start)).filter(Number.isFinite);
  const ends = rows.map((line) => Number(line.end)).filter(Number.isFinite);
  if (!starts.length || !ends.length) return 0;
  return Math.max(...ends) - Math.min(...starts);
}

function videoUserVisibility(video) {
  const transcript = videoTranscript(video);
  const reasons = [];
  const statusValue = String(video?.status || '').toLowerCase();
  const youtubeStatus = String(video?.youtubeStatus || 'unchecked').toLowerCase();
  const span = transcriptSpanSeconds(transcript);
  if (statusValue !== 'published') reasons.push('Chưa published');
  if (!String(video?.youtubeId || '').trim()) reasons.push('Thiếu YouTube ID');
  if (VIDEO_UNAVAILABLE_IDS.has(String(video?.youtubeId || '').trim())) reasons.push('Video nằm trong danh sách unavailable của mobile');
  if (youtubeStatus === 'dead') reasons.push('YouTube dead link');
  if (youtubeStatus === 'missing') reasons.push('Thiếu hoặc sai YouTube ID');
  if (video?.transcriptStatus !== 'timed' || !isTimedTranscript(transcript)) reasons.push('Chưa đủ timing start/end');
  if (transcript.length < VIDEO_MIN_SUBTITLES) reasons.push(`Cần ít nhất ${VIDEO_MIN_SUBTITLES} câu phụ đề`);
  if (span < VIDEO_MIN_SPAN_SECONDS) reasons.push(`Transcript span dưới ${VIDEO_MIN_SPAN_SECONDS} giây`);
  return { ready: reasons.length === 0, reasons, span };
}

function videoVisibilityCell(result) {
  return el('div', { class: 'visibility-cell' }, [
    status(result.ready ? 'Hiện trong app' : 'Chưa hiện'),
    result.ready
      ? el('small', {}, 'Đủ tiêu chuẩn mobile')
      : el('small', {}, result.reasons.slice(0, 2).join(' · ')),
  ]);
}

function openVideoQa(video) {
  state.review = mergeReviewIssues(state.review, runQualityChecks().filter((issue) => issue.area === 'Video' && issue.title === video.title));
  saveState();
  activeView = 'review';
  setActiveNav();
  render();
}

function youtubeStatusCell(video) {
  const value = video.youtubeStatus || 'unchecked';
  const label = {
    ok: 'OK',
    dead: 'Dead link',
    missing: 'Thiếu ID',
    error: 'Chưa kiểm tra được',
    unchecked: 'Chưa check',
  }[value] || value;
  return el('div', { class: 'youtube-status-cell' }, [
    el('span', { class: `status ${value}` }, label),
    video.youtubeCheckedAt
      ? el('small', {}, new Date(video.youtubeCheckedAt).toLocaleString('vi-VN'))
      : el('small', {}, 'Bấm Check để kiểm tra'),
    video.youtubeMessage ? el('small', {}, video.youtubeMessage) : '',
  ]);
}

async function checkAllYoutubeVideos() {
  const videos = state.lessons.filter((lesson) => lesson.type === 'Video');
  if (!videos.length) {
    showToast('Chưa có video để kiểm tra.');
    return;
  }
  showToast(`Đang kiểm tra ${videos.length} video YouTube...`);
  for (const video of videos) {
    await updateYoutubeStatus(video);
  }
  saveState();
  render();
  const dead = videos.filter((video) => video.youtubeStatus === 'dead').length;
  const ok = videos.filter((video) => video.youtubeStatus === 'ok').length;
  showToast(`Đã kiểm tra video: ${ok} OK, ${dead} dead link.`);
}

async function checkYoutubeVideo(video) {
  await updateYoutubeStatus(video);
  saveState();
  render();
  showToast(`${video.title}: ${video.youtubeStatus || 'unchecked'}`);
}

async function updateYoutubeStatus(video) {
  const youtubeId = String(video.youtubeId || '').trim();
  if (!youtubeId) {
    video.youtubeStatus = 'missing';
    video.youtubeMessage = 'Video thiếu YouTube ID.';
    video.youtubeCheckedAt = new Date().toISOString();
    return video;
  }
  try {
    const url = `https://www.youtube.com/oembed?format=json&url=${encodeURIComponent(`https://www.youtube.com/watch?v=${youtubeId}`)}`;
    const response = await fetch(url, { method: 'GET' });
    video.youtubeCheckedAt = new Date().toISOString();
    if (response.ok) {
      const data = await response.json().catch(() => ({}));
      video.youtubeStatus = 'ok';
      video.youtubeMessage = data.title ? `Tìm thấy: ${data.title}` : 'Video còn khả dụng.';
      return video;
    }
    video.youtubeStatus = response.status === 404 ? 'dead' : 'error';
    video.youtubeMessage = response.status === 404
      ? 'YouTube không còn trả metadata cho ID này.'
      : `YouTube trả HTTP ${response.status}.`;
  } catch (error) {
    video.youtubeStatus = 'error';
    video.youtubeCheckedAt = new Date().toISOString();
    video.youtubeMessage = error.message || 'Không gọi được YouTube oEmbed.';
  }
  return video;
}

function renderReading() {
  const root = el('div', { class: 'view-root' });
  root.appendChild(toolbar('Nguồn tin trực tuyến', [
    button('↻ Kiểm tra RSS', 'ghost-button', testReadingApi),
    button('＋ Thêm nguồn', 'primary-button', () => openReadingSourceEditor()),
  ]));
  root.appendChild(tablePanel(
    ['Nguồn', 'URL RSS/API', 'Cấp đọc', 'Trạng thái', ''],
    state.readingSources.map((source) => [
      strongText(source.name),
      source.url,
      source.level,
      status(source.status),
      rowActions([
        ['Sửa', () => openReadingSourceEditor(source)],
        ['Bật/tắt', () => {
          source.status = source.status === 'active' ? 'archived' : 'active';
          saveState();
          render();
        }],
      ]),
    ]),
  ));
  root.appendChild(panel(
    'Luồng đọc báo trong app',
    el('div', { class: 'admin-guide' }, [
      el('div', {}, [el('strong', {}, 'Lấy tin'), el('p', {}, 'Backend đọc RSS mới, lọc bài trống và trả tối đa 24 bài.')]),
      el('div', {}, [el('strong', {}, 'Hỗ trợ học'), el('p', {}, 'App tách câu, phát TTS, tạo pinyin gợi ý và cho chạm từ để tra nghĩa.')]),
      el('div', {}, [el('strong', {}, 'Kiểm duyệt'), el('p', {}, 'Nguồn lạ hoặc lỗi mã hóa cần tắt tại đây trước khi publish.')]),
    ]),
  ));
  root.appendChild(toolbar('Bài đọc trong PostgreSQL', [
    select(['Tất cả', 'HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6'], articleFilter, (value) => {
      articleFilter = value;
      render();
    }),
    button('＋ Thêm bài đọc', 'primary-button', () => openArticleEditor()),
  ]));
  const articles = (state.articles || [])
    .filter((item) => articleFilter === 'Tất cả' || item.level === articleFilter)
    .filter((item) => matchesQuery([item.source, item.level, item.title, item.titleVi, item.summaryVi, item.status]));
  root.appendChild(tablePanel(
    ['Nguồn', 'HSK', 'Tiêu đề', 'Tóm tắt', 'Trạng thái', ''],
    articles.map((item) => [
      item.source || 'VNChinese',
      item.level,
      strongText(item.title),
      item.summaryVi || item.titleVi || '',
      status(item.status),
      rowActions([
        ['Sửa', () => openArticleEditor(item)],
        ['Lưu trữ', () => deleteItem('articles', item.id)],
      ]),
    ]),
  ));
  return root;
}

function renderSpeaking() {
  const root = el('div', { class: 'view-root' });
  const published = state.pronunciation.filter((item) => item.status === 'published').length;
  const topics = new Set(state.pronunciation.map((item) => item.topic).filter(Boolean));
  root.appendChild(metricGrid([
    ['Câu luyện nói', state.pronunciation.length, 'HSK 1-4'],
    ['Đã xuất bản', published, 'hiển thị trong app'],
    ['Tình huống', topics.size, 'bộ lọc người học'],
    ['Thiếu dữ liệu', state.pronunciation.filter((item) => !item.cn || !item.py || !item.vi).length, 'cần bổ sung'],
  ]));
  root.appendChild(toolbar('Tình huống và câu luyện phát âm', [
    button('↻ Nạp từ app user', 'ghost-button', loadMobilePronunciation),
    button('＋ Thêm câu', 'primary-button', () => openSpeakingEditor()),
  ]));
  const rows = state.pronunciation
    .filter((item) => matchesQuery([item.level, item.topic, item.cn, item.py, item.vi, item.status]));
  root.appendChild(tablePanel(
    ['HSK', 'Tình huống', 'Câu Trung', 'Pinyin', 'Nghĩa Việt', 'Trạng thái', ''],
    rows.map((item) => [
      item.level,
      strongText(item.topic),
      strongText(item.cn),
      item.py,
      item.vi,
      status(item.status),
      rowActions([
        ['Sửa', () => openSpeakingEditor(item)],
        ['Xóa', () => deleteItem('pronunciation', item.id)],
      ]),
    ]),
  ));
  return root;
}

function renderGames() {
  const root = el('div', { class: 'view-root' });
  const games = state.games || [];
  const filteredGames = games
    .filter((game) => gameLevelFilter === 'Tất cả' || gameLevel(game) === gameLevelFilter || String(game.scope || '').includes(gameLevelFilter))
    .filter((game) => matchesQuery([game.title, game.type, game.scope, gameLevel(game), game.status]));
  const published = games.filter((game) => game.status === 'published').length;
  const autoGenerated = games.filter((game) => gameGeneration(game) === 'auto').length;
  root.appendChild(metricGrid([
    ['Game template', games.length, 'cấu hình trò chơi'],
    ['Đang publish', published, 'user có thể chơi'],
    ['Tự sinh câu hỏi', autoGenerated, 'lấy từ dữ liệu app'],
    ['Nguồn dữ liệu', countGameSources(games), 'flashcard/từ vựng/ngữ pháp'],
  ]));
  root.appendChild(panel(
    'Cách quiz và trò chơi hoạt động',
    el('div', { class: 'admin-guide compact-guide' }, [
      el('div', {}, [el('strong', {}, 'Template'), el('p', {}, 'Admin quản lý loại game, HSK, nguồn dữ liệu và trạng thái. App user sẽ sinh câu hỏi từ dữ liệu đã published.')]),
      el('div', {}, [el('strong', {}, 'Tự động'), el('p', {}, 'Quiz nghĩa từ, nghe chọn từ, matching có thể lấy câu hỏi từ flashcard/vocabulary theo HSK. Không cần nhập từng câu nếu dữ liệu nguồn sạch.')]),
      el('div', {}, [el('strong', {}, 'Thủ công'), el('p', {}, 'Khi cần đề cố định, chuyển generation sang manual rồi gắn bộ câu riêng ở bước sau.')]),
    ]),
  ));
  root.appendChild(toolbar('Quiz và trò chơi ghi nhớ', [
    select(['Tất cả', ...hskLevelOptions(games.map((game) => ({ level: gameLevel(game) })))], gameLevelFilter, (value) => {
      gameLevelFilter = value;
      render();
    }),
    button('＋ Thêm trò chơi', 'primary-button', () => openGameEditor()),
  ]));
  root.appendChild(tablePanel(
    ['Tên', 'Loại', 'HSK', 'Nguồn dữ liệu', 'Cách tạo', 'Trạng thái', ''],
    filteredGames.map((game) => [
      el('div', { class: 'lesson-title-cell' }, [
        strongText(game.title),
        el('span', {}, game.description || 'Template game trong app user'),
      ]),
      game.type,
      gameLevel(game),
      gameSource(game),
      status(gameGeneration(game) === 'auto' ? 'auto' : 'manual'),
      status(game.status),
      rowActions([
        ['Sửa', () => openGameEditor(game)],
        ['Xóa', () => deleteItem('games', game.id)],
      ]),
    ]),
  ));
  return root;
}

function gameLevel(game) {
  return String(game?.level || game?.hsk || '').trim() || inferLevelFromText(game?.scope || game?.title || '') || 'HSK 1-4';
}

function gameSource(game) {
  return String(game?.source || game?.dataSource || game?.scope || 'Flashcard đã published').trim();
}

function gameGeneration(game) {
  return String(game?.generation || game?.mode || 'auto').toLowerCase() === 'manual' ? 'manual' : 'auto';
}

function countGameSources(games) {
  return new Set((games || []).map((game) => gameSource(game))).size;
}

async function loadMobilePronunciation() {
  const root = String(state.settings.mobileAssetRoot || '../mobile/assets').replace(/[\\/]+$/, '');
  try {
    const response = await fetch(`${root}/data/reading_hsk.json`);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
    if (!Array.isArray(data)) throw new Error('Dữ liệu câu luyện không hợp lệ.');
    state.pronunciation = data.map((item) => ({
      id: item.id || uid(),
      level: item.level || 'HSK 1',
      topic: item.topic || 'Giao tiếp hằng ngày',
      cn: item.cn || '',
      py: item.py || '',
      vi: item.vi || '',
      status: item.status || 'published',
    }));
    saveState();
    activeView = 'speaking';
    setActiveNav();
    render();
    showToast(`Đã nạp ${state.pronunciation.length} câu luyện nói từ app user.`);
  } catch (error) {
    showToast(`Chưa nạp được câu luyện nói: ${error.message}`);
  }
}

function renderAiStudio() {
  const root = el('div', { class: 'view-root' });
  root.appendChild(metricGrid([
    ['Ngữ pháp AI', state.aiSettings.grammarEnabled ? 'Bật' : 'Tắt', 'POST /grammar/check'],
    ['Gia sư AI', state.aiSettings.tutorEnabled ? 'Bật' : 'Tắt', 'POST /ai/chat'],
    ['Trình độ mặc định', state.aiSettings.defaultLevel, 'prompt context'],
    ['Nhà cung cấp', 'Gemini', 'backend giữ API key'],
  ]));
  const prompt = el('textarea', {}, state.aiSettings.tutorPrompt);
  prompt.addEventListener('change', () => {
    state.aiSettings.tutorPrompt = prompt.value.trim();
    saveState();
  });
  root.appendChild(panel('Prompt gia sư', el('div', { class: 'dialog-fields compact-fields' }, [
    el('div', { class: 'field' }, [el('label', {}, 'Quy tắc phản hồi'), prompt]),
  ])));
  root.appendChild(panel('Kiểm tra dịch vụ AI', el('div', { class: 'toolbar-group' }, [
    button('Test chấm ngữ pháp', 'primary-button', testGrammarApi),
    button('Test chatbot', 'ghost-button', testChatApi),
    button('Kiểm tra health', 'ghost-button', refreshApiStatus),
  ])));
  return root;
}

function renderUsers() {
  const root = el('div', { class: 'view-root' });
  const stats = state.dashboard?.users || {};
  root.appendChild(metricGrid([
    ['Tổng user', stats.total ?? state.users.length, `${stats.newThisWeek || 0} mới tuần này`],
    ['Đang hoạt động', stats.active ?? state.users.filter((user) => user.status === 'active').length, `${stats.loggedInThisWeek || 0} đăng nhập 7 ngày`],
    ['Bị khóa', stats.blocked ?? state.users.filter((user) => user.status === 'blocked').length, 'kiểm soát truy cập'],
    ['Admin', stats.admins ?? state.users.filter((user) => user.role === 'admin').length, 'quyền quản trị'],
  ]));
  root.appendChild(toolbar('Người dùng', [
    select(['Tất cả', 'active', 'blocked', 'admin', 'editor', 'reviewer', 'user'], userFilter, (value) => {
      userFilter = value;
      render();
    }),
    button('↻ Đồng bộ API', 'ghost-button', loadBackendUsers),
    button('＋ Thêm user', 'primary-button', () => openUserEditor()),
  ]));
  const rows = state.users
    .filter((user) => userFilter === 'Tất cả' || user.status === userFilter || user.role === userFilter)
    .filter((user) => matchesQuery([user.displayName || user.name, user.email, user.role, user.status, user.targetLevel]));
  root.appendChild(tablePanel(['Tên', 'Email', 'Vai trò', 'Mục tiêu', 'Tiến độ', 'Đăng nhập cuối', 'Trạng thái', ''], rows.map((user) => [
    strongText(user.displayName || user.name),
    user.email,
    user.role,
    user.targetLevel || 'HSK 1',
    `${user.progress?.learnedWords || 0} từ · ${user.progress?.studyMinutes || 0} phút · ${user.progress?.averageScore || 0}%`,
    user.lastLoginAt ? new Date(user.lastLoginAt).toLocaleString('vi-VN') : 'Chưa đăng nhập',
    status(user.status),
    rowActions([
      ['Chi tiết', () => openUserDetail(user.id)],
      ['Sửa', () => openUserEditor(user)],
      [user.status === 'blocked' ? 'Mở' : 'Khóa', () => toggleUserStatus(user.id)],
    ]),
  ])));
  return root;
}

async function apiFetch(path, options = {}) {
  if (!adminToken) throw new Error('Chưa đăng nhập admin.');
  const response = await fetchApi(path, {
    ...options,
    headers: {
      ...(options.body ? { 'Content-Type': 'application/json' } : {}),
      ...(options.headers || {}),
      Authorization: `Bearer ${adminToken}`,
    },
  });
  const data = await response.json().catch(() => ({}));
  if (response.status === 401 || response.status === 403) {
    adminToken = '';
    currentAdmin = null;
    sessionStorage.removeItem('vnchinese_admin_token');
    sessionStorage.removeItem('vnchinese_admin_user');
    appShell.classList.add('is-hidden');
    adminLogin.classList.remove('is-hidden');
    throw new Error(data.message || 'Phiên admin đã hết hạn.');
  }
  if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
  return data;
}

async function loadAdminDashboard(shouldRender = true) {
  if (!adminToken) return;
  try {
    state.dashboard = await apiFetch('/admin/dashboard');
    saveState();
    if (shouldRender) render();
  } catch (error) {
    showToast(`Chưa tải được dashboard: ${error.message}`);
  }
}

async function loadBackendUsers(shouldRender = true) {
  if (!adminToken) {
    showToast('Hãy đăng nhập admin để đồng bộ người dùng.');
    return;
  }
  try {
    const data = await apiFetch('/admin/users');
    state.users = Array.isArray(data) ? data : [];
    saveState();
    if (shouldRender) render();
    showToast(`Đã đồng bộ ${state.users.length} người dùng.`);
  } catch (error) {
    showToast(`Chưa đồng bộ được người dùng: ${error.message}`);
  }
}

async function loadAuditLogs(shouldRender = true) {
  if (!adminToken) return;
  try {
    const data = await apiFetch('/admin/audit-logs?limit=30');
    state.auditLogs = Array.isArray(data) ? data : [];
    saveState();
    if (shouldRender) render();
  } catch (error) {
    showToast(`Chưa tải được nhật ký admin: ${error.message}`);
  }
}

async function loadPublishedContent(shouldRender = true) {
  if (!adminToken) return;
  try {
    const data = await apiFetch('/admin/content');

    if (Array.isArray(data.vocabulary)) {
      state.vocabulary = data.vocabulary;
    }
    if (Array.isArray(data.flashcards) && data.flashcards.length) {
      state.flashcards = data.flashcards.map(topicFromFlashcardIndex);
    }
    if (Array.isArray(data.lessons) && data.lessons.length) {
      state.lessons = data.lessons;
    }
    if (Array.isArray(data.videos) && data.videos.length) {
      const nonVideoLessons = state.lessons.filter((lesson) => lesson.type !== 'Video');
      state.lessons = [
        ...nonVideoLessons,
        ...data.videos.map((video) => ({
          ...video,
          type: 'Video',
          status: video.status || 'published',
          items: Array.isArray(video.subtitles) ? video.subtitles.length : 0,
          transcript: Array.isArray(video.subtitles) ? video.subtitles : [],
        })),
      ];
    }
    if (Array.isArray(data.readingSources) && data.readingSources.length) {
      state.readingSources = data.readingSources;
    }
    if (Array.isArray(data.grammar)) {
      state.grammar = data.grammar;
    }
    if (Array.isArray(data.articles)) {
      state.articles = data.articles;
    }
    if (Array.isArray(data.pronunciation) && data.pronunciation.length) {
      state.pronunciation = data.pronunciation;
    }
    if (Array.isArray(data.games) && data.games.length) {
      state.games = data.games;
    }
    if (data.aiSettings && typeof data.aiSettings === 'object') {
      state.aiSettings = { ...state.aiSettings, ...data.aiSettings };
    }
    if (data.version && data.version !== 'unpublished') {
      state.settings.contentVersion = data.version;
    }
    saveState();
    if (shouldRender) render();
  } catch (error) {
    showToast(`Chưa tải được nội dung đã xuất bản: ${error.message}`);
  }
}

async function publishContentToApi() {
  if (!adminToken) {
    showToast('Hãy đăng nhập admin trực tuyến để xuất bản nội dung.');
    return;
  }
  const issues = runQualityChecks();
  const blockingIssues = issues.filter((issue) => issue.severity === 'fail');
  if (blockingIssues.length) {
    state.review = mergeReviewIssues(state.review, issues);
    saveState();
    activeView = 'review';
    setActiveNav();
    render();
    showToast(`Còn ${blockingIssues.length} lỗi QA cần sửa trước khi xuất bản.`);
    return;
  }

  const videos = state.lessons
    .filter((lesson) => lesson.type === 'Video')
    .map((video) => ({
      id: video.id,
      title: video.title,
      titleCn: video.titleCn || '',
      level: video.level,
      youtubeId: video.youtubeId,
      source: video.source || 'YouTube',
      status: video.status,
      transcriptStatus: video.transcriptStatus || 'untimed',
      subtitles: Array.isArray(video.transcript) ? video.transcript : [],
    }));
  const payload = {
    version: state.settings.contentVersion,
    vocabulary: state.vocabulary,
    flashcards: state.flashcards.map(topicToFlashcardIndex),
    pronunciation: state.pronunciation,
    videos,
    lessonMap: buildLessonMapPayload(),
    lessons: state.lessons.filter((lesson) => lesson.type !== 'Video'),
    grammar: state.grammar || [],
    articles: state.articles || [],
    readingSources: state.readingSources,
    games: state.games,
    aiSettings: state.aiSettings,
  };

  publishContentButton.disabled = true;
  publishContentButton.textContent = 'Đang xuất bản...';
  try {
    const response = await fetchApi('/admin/content', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${adminToken}`,
      },
      body: JSON.stringify(payload),
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
    showToast(
      `Đã đồng bộ ${data.counts?.flashcards || 0} topic, ${data.counts?.grammar || 0} ngữ pháp, ${data.counts?.articles || 0} bài đọc, ${data.counts?.videos || 0} video.`,
    );
    await Promise.all([loadAdminDashboard(false), loadPublishedContent(false), loadAuditLogs(false)]);
    render();
    refreshApiStatus();
  } catch (error) {
    showToast(`Xuất bản thất bại: ${error.message}`);
  } finally {
    publishContentButton.disabled = false;
    publishContentButton.textContent = 'Xuất bản';
  }
}

function renderReview() {
  const root = el('div', { class: 'view-root' });
  const currentIssues = mergeReviewIssues(state.review, runQualityChecks())
    .filter((item) => !isReviewDismissed(item));
  const filteredIssues = currentIssues
    .filter((item) => reviewFilter === 'Tất cả' || item.severity === reviewFilter || item.area === reviewFilter)
    .filter((item) => matchesQuery([item.area, item.title, item.issue, item.severity]));
  root.appendChild(metricGrid([
    ['Fail', currentIssues.filter((item) => item.severity === 'fail').length, 'chặn publish'],
    ['Pending', currentIssues.filter((item) => item.severity === 'pending').length, 'cần reviewer xem'],
    ['Khu vực lỗi', new Set(currentIssues.map((item) => item.area)).size, 'module bị ảnh hưởng'],
    ['Đang hiển thị', filteredIssues.length, 'theo bộ lọc'],
  ]));
  root.appendChild(panel(
    'Kiểm duyệt dùng để làm gì?',
    el('div', { class: 'admin-guide compact-guide' }, [
      el('div', {}, [el('strong', {}, 'Chặn lỗi trước publish'), el('p', {}, 'Các lỗi fail như thiếu pinyin, thiếu YouTube ID, ảnh lỗi hoặc timing chồng nhau sẽ không cho xuất bản.')]),
      el('div', {}, [el('strong', {}, 'Nhắc việc reviewer'), el('p', {}, 'Các mục pending không nhất thiết chặn publish, nhưng cần người quản trị xem lại chất lượng nội dung.')]),
      el('div', {}, [el('strong', {}, 'Điều hướng sửa'), el('p', {}, 'Bấm "Mở nơi sửa" để chuyển sang đúng module thay vì dò thủ công trong từng menu.')]),
    ]),
  ));
  root.appendChild(toolbar('Hàng chờ kiểm duyệt', [
    select(['Tất cả', 'fail', 'pending', 'Flashcard', 'Từ flashcard', 'Video', 'Từ vựng', 'Ngữ pháp', 'Bài đọc', 'Luyện nói'], reviewFilter, (value) => {
      reviewFilter = value;
      render();
    }),
    button('✓ Duyệt tất cả', 'primary-button', approveAllReview),
    button('↺ Chạy QA', 'ghost-button', () => {
      state.review = mergeReviewIssues(state.review, runQualityChecks());
      saveState();
      render();
    }),
  ]));

  const list = el('div', { class: 'qa-list' });
  filteredIssues
    .forEach((item) => {
      list.appendChild(el('div', { class: 'qa-item' }, [
        el('span', { class: `qa-dot ${item.severity === 'fail' ? 'fail' : 'warn'}` }, item.severity === 'fail' ? '!' : '?'),
        el('div', {}, [
          el('strong', {}, `${item.area}: ${item.title}`),
          el('p', {}, item.issue),
        ]),
        rowActions([
          ['Mở nơi sửa', () => openReviewTarget(item)],
          ['Duyệt', () => approveReview(item.id, item)],
          ['Ẩn', () => dismissReview(item.id, item)],
        ]),
      ]));
    });
  if (!list.children.length) list.appendChild(emptyState('Không còn nội dung chờ duyệt.'));
  root.appendChild(list);
  return root;
}

function renderSettings() {
  const root = el('div', { class: 'view-root' });
  const rows = [
    ['API base URL', 'apiBaseUrl'],
    ['Content version', 'contentVersion'],
    ['Reviewer policy', 'reviewerPolicy'],
    ['Export target', 'exportTarget'],
    ['Mobile asset root', 'mobileAssetRoot'],
  ];
  rows.forEach(([label, key]) => {
    const input = el('input', { value: state.settings[key] || '' });
    input.addEventListener('change', () => {
      state.settings[key] = input.value.trim();
      saveState();
      showToast('Đã lưu cấu hình.');
    });
    root.appendChild(el('div', { class: 'setting-row' }, [
      el('div', {}, [el('h3', {}, label), el('p', {}, settingHint(key))]),
      input,
    ]));
  });
  root.appendChild(panel('Quản lý dữ liệu', el('div', { class: 'toolbar-group' }, [
    button('Kiểm tra API', 'ghost-button', testApiConnection),
    button('Test AI ngữ pháp', 'ghost-button', testGrammarApi),
    button('⇩ Xuất content bundle', 'primary-button', exportContentBundle),
    button('⇩ Xuất flashcard index', 'ghost-button', exportFlashcardIndex),
    button('↺ Khôi phục mẫu', 'ghost-button', () => document.querySelector('#resetButton').click()),
  ])));
  return root;
}

async function testApiConnection() {
  try {
    const response = await fetchApi('/health', { method: 'GET' });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    showToast('API VNChinese đang kết nối được.');
  } catch (error) {
    showToast(`Chưa kết nối được API: ${error.message}`);
  }
}

async function testGrammarApi() {
  try {
    const response = await fetchApi('/grammar/check', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text: '我不学校去学习' }),
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
    showToast(`AI grammar OK: ${data.provider || 'AI'} ${data.model || ''} · ${data.score}/100`);
  } catch (error) {
    showToast(`AI ngữ pháp chưa sẵn sàng: ${error.message}`);
  }
}

async function refreshApiStatus() {
  try {
    const response = await fetchApi('/health');
    const data = await response.json();
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const aiReady = data.ai?.configured && data.ai?.keyFormat === 'valid-pattern';
    apiStatus.textContent = aiReady ? 'API & AI sẵn sàng' : 'API chạy · AI cần key';
    apiStatus.className = `api-status ${aiReady ? 'is-online' : 'is-warning'}`;
  } catch (_) {
    apiStatus.textContent = 'API ngoại tuyến';
    apiStatus.className = 'api-status is-offline';
  }
}

async function testReadingApi() {
  try {
    const response = await fetchApi('/reading/news');
    const data = await response.json();
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    showToast(`Đọc báo trực tuyến hoạt động: ${Array.isArray(data) ? data.length : 0} bài mới.`);
  } catch (error) {
    showToast(`Nguồn báo chưa sẵn sàng: ${error.message}`);
  }
}

async function testChatApi() {
  try {
    const response = await fetchApi('/ai/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: 'Tạo một câu chào hỏi HSK 1.', level: 'HSK 1' }),
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
    showToast(`Chatbot hoạt động: ${String(data.reply || '').slice(0, 80)}`);
  } catch (error) {
    showToast(`Chatbot chưa sẵn sàng: ${error.message}`);
  }
}

let youtubeApiPromise;

function ensureYoutubeIframeApi() {
  if (window.YT?.Player) return Promise.resolve(window.YT);
  if (youtubeApiPromise) return youtubeApiPromise;
  youtubeApiPromise = new Promise((resolve) => {
    const previousReady = window.onYouTubeIframeAPIReady;
    window.onYouTubeIframeAPIReady = () => {
      if (typeof previousReady === 'function') previousReady();
      resolve(window.YT);
    };
    if (!document.querySelector('script[src="https://www.youtube.com/iframe_api"]')) {
      document.head.appendChild(el('script', { src: 'https://www.youtube.com/iframe_api' }));
    }
  });
  return youtubeApiPromise;
}

function createVideoTranscriptGrid(initialRows, values) {
  let rows = Array.isArray(initialRows)
    ? structuredClone(initialRows)
    : parseTranscript(initialRows);
  if (!rows.length) rows = [{ start: 0, end: 0, cn: '', py: '', vi: '' }];

  const playerId = `yt-admin-${uid()}`;
  let player = null;
  const youtubeId = String(values.youtubeId || '').trim();
  const playerBox = el('div', { class: 'video-timing-player' }, [
    youtubeId
      ? el('div', { id: playerId })
      : el('div', { class: 'image-placeholder' }, 'Nhập YouTube ID rồi mở lại editor để dùng nút lấy thời gian.'),
  ]);
  if (youtubeId) {
    ensureYoutubeIframeApi().then((YT) => {
      player = new YT.Player(playerId, {
        videoId: youtubeId,
        playerVars: { rel: 0, modestbranding: 1 },
      });
    });
  }

  const tbody = el('tbody');
  const table = el('table', { class: 'data-grid-table' }, [
    el('thead', {}, [
      el('tr', {}, ['Start', 'End', 'Câu Trung', 'Pinyin', 'Nghĩa Việt', ''].map((head) => el('th', {}, head))),
    ]),
    tbody,
  ]);
  const grid = el('div', { class: 'dynamic-editor' }, [
    el('div', { class: 'video-timing-layout' }, [
      playerBox,
      el('div', { class: 'timing-help' }, [
        el('strong', {}, 'Video Timing'),
        el('p', {}, 'Phát video, đặt con trỏ vào dòng cần sửa rồi bấm Start/End để lấy currentTime từ YouTube Player.'),
      ]),
    ]),
    el('div', { class: 'data-grid-wrap' }, table),
    el('div', { class: 'grid-actions' }, [
      button('＋ Thêm câu', 'ghost-button', () => {
        rows = readRows();
        const lastEnd = rows.at(-1)?.end || 0;
        rows.push({ start: lastEnd, end: lastEnd + 3, cn: '', py: '', vi: '' });
        renderRows();
      }),
    ]),
  ]);

  function currentTime() {
    const value = Number(player?.getCurrentTime?.() || 0);
    return Number.isFinite(value) ? Number(value.toFixed(2)) : 0;
  }

  function input(value, attrs = {}) {
    const node = el('input', { value: value ?? '', ...attrs });
    if (attrs['data-field'] === 'py') attachPinyinAutoTone(node);
    return node;
  }

  function readRows() {
    return [...tbody.querySelectorAll('tr')].map((tr) => ({
      start: Number(tr.querySelector('[data-field="start"]').value || 0),
      end: Number(tr.querySelector('[data-field="end"]').value || 0),
      cn: tr.querySelector('[data-field="cn"]').value.trim(),
      py: tr.querySelector('[data-field="py"]').value.trim(),
      vi: tr.querySelector('[data-field="vi"]').value.trim(),
    }));
  }

  function renderRows() {
    tbody.innerHTML = '';
    rows.forEach((line, index) => {
      const startInput = input(line.start, { type: 'number', step: '0.01', min: '0', 'data-field': 'start' });
      const endInput = input(line.end, { type: 'number', step: '0.01', min: '0', 'data-field': 'end' });
      tbody.appendChild(el('tr', {}, [
        el('td', {}, [
          startInput,
          button('Start', 'ghost-button mini-button', () => {
            startInput.value = currentTime();
          }),
        ]),
        el('td', {}, [
          endInput,
          button('End', 'ghost-button mini-button', () => {
            endInput.value = currentTime();
          }),
        ]),
        el('td', {}, input(line.cn, { 'data-field': 'cn' })),
        el('td', {}, input(line.py, { 'data-field': 'py' })),
        el('td', {}, input(line.vi, { 'data-field': 'vi' })),
        el('td', {}, button('Xóa', 'ghost-button mini-button danger-text', () => {
          rows = readRows();
          rows.splice(index, 1);
          if (!rows.length) rows.push({ start: 0, end: 0, cn: '', py: '', vi: '' });
          renderRows();
        })),
      ]));
    });
  }

  renderRows();
  return {
    node: grid,
    getValue: () => readRows().filter((line) => line.cn),
  };
}

function createFlashcardWordsGrid(initialRows, values = {}) {
  let rows = Array.isArray(initialRows) ? structuredClone(initialRows) : parseWords(initialRows);
  if (!rows.length) rows = [word('', '', '', '')];
  const topicId = slug(values.id || values.name || '');
  const list = el('div', { class: 'flashcard-word-list' });
  const grid = el('div', { class: 'dynamic-editor' }, [
    el('p', { class: 'topic-note' }, 'Flashcard trong app chỉ hiển thị ảnh, Hán tự, pinyin, nghĩa, nghe và ghi âm. Ảnh upload được lưu thành file trên backend; DB lưu đường dẫn ảnh sau khi bấm Lưu thay đổi và Xuất bản.'),
    list,
    el('div', { class: 'grid-actions' }, [
      button('＋ Thêm từ', 'ghost-button', () => {
        rows = readRows();
        rows.push(word('', '', '', ''));
        renderRows();
      }),
    ]),
  ]);

  function input(value, attrs = {}) {
    const node = el('input', { value: value ?? '', ...attrs });
    if (attrs['data-field'] === 'pinyin') attachPinyinAutoTone(node);
    return node;
  }

  function createWordImageControl(item) {
    const imageInput = input(wordImageInputValue(item), {
      'data-field': 'image',
      placeholder: 'URL ảnh hoặc tên file',
    });
    const preview = el('div', { class: 'word-image-preview' });
    const uploadButton = button('Upload', 'ghost-button mini-button', () => fileInput.click());
    const fileInput = el('input', {
      type: 'file',
      accept: 'image/png,image/jpeg,image/webp',
      class: 'hidden-file',
    });

    function renderPreview() {
      const src = wordImagePreviewSrc(imageInput.value, topicId);
      preview.innerHTML = '';
      if (!src) {
        preview.appendChild(el('span', {}, 'Chưa có ảnh'));
        return;
      }
      const img = el('img', { src, alt: 'Word image preview', loading: 'lazy' });
      img.addEventListener('error', () => {
        preview.innerHTML = '';
        preview.appendChild(el('span', {}, 'Không xem được'));
      });
      preview.appendChild(img);
    }

    fileInput.addEventListener('change', async () => {
      const file = fileInput.files?.[0];
      fileInput.value = '';
      if (!file) return;
      uploadButton.disabled = true;
      uploadButton.textContent = 'Đang tải...';
      try {
        const data = await uploadAdminImage(file);
        imageInput.value = data.url;
        renderPreview();
      } catch (error) {
        showToast(`Upload ảnh thất bại: ${error.message}`);
      } finally {
        uploadButton.disabled = false;
        uploadButton.textContent = 'Upload';
      }
    });

    imageInput.addEventListener('change', renderPreview);
    imageInput.addEventListener('blur', renderPreview);
    renderPreview();

    return el('div', { class: 'word-image-control' }, [
      preview,
      el('div', { class: 'word-image-fields' }, [
        imageInput,
        el('div', { class: 'toolbar-group' }, [uploadButton]),
      ]),
      fileInput,
    ]);
  }

  function readRows() {
    return [...list.querySelectorAll('.flashcard-word-row')].map((row) => {
      const image = row.querySelector('[data-field="image"]').value.trim();
      const nextWord = word(
        row.querySelector('[data-field="word"]').value.trim(),
        row.querySelector('[data-field="pinyin"]').value.trim(),
        row.querySelector('[data-field="meaning"]').value.trim(),
        image,
      );
      if (isResolvedImagePath(image)) {
        nextWord.imagePath = image;
        nextWord.imageUrl = image;
      }
      return nextWord;
    });
  }

  function renderRows() {
    list.innerHTML = '';
    rows.forEach((item, index) => {
      const removeButton = button('Xóa', 'ghost-button mini-button danger-text', () => {
        rows = readRows();
        rows.splice(index, 1);
        if (!rows.length) rows.push(word('', '', '', ''));
        renderRows();
      });
      list.appendChild(el('section', { class: 'flashcard-word-row' }, [
        el('div', { class: 'word-index' }, String(index + 1)),
        el('div', { class: 'word-fields' }, [
          el('label', {}, [el('span', {}, 'Hán tự'), input(item.word, { 'data-field': 'word' })]),
          el('label', {}, [el('span', {}, 'Pinyin'), input(item.pinyin, { 'data-field': 'pinyin', placeholder: 'tian1 qi4' })]),
          el('label', {}, [el('span', {}, 'Nghĩa Việt'), input(item.meaning, { 'data-field': 'meaning' })]),
        ]),
        createWordImageControl(item),
        el('div', { class: 'word-row-actions' }, [removeButton]),
      ]));
    });
  }

  renderRows();
  return {
    node: grid,
    getValue: () => readRows().filter((item) => item.word),
  };
}

async function uploadAdminImage(file) {
  if (!adminToken) {
    throw new Error('Hay dang nhap admin online truoc khi upload anh.');
  }
  const formData = new FormData();
  formData.append('file', file);
  const response = await fetchApi('/admin/media/flashcard', {
    method: 'POST',
    headers: { Authorization: `Bearer ${adminToken}` },
    body: formData,
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
  if (!data.url) throw new Error('API upload khong tra ve URL anh.');
  return data;
}

function convertToPinyinWithTones(text) {
  return String(text || '').replace(/([a-züÜv:]+)([0-5])/gi, (_, raw, tone) => {
    return convertPinyinSyllable(raw, Number(tone));
  });
}

function convertPinyinSyllable(raw, tone) {
  const normalized = String(raw || '')
    .replace(/u:/gi, (value) => (value[0] === 'U' ? 'Ü' : 'ü'))
    .replace(/v/g, 'ü')
    .replace(/V/g, 'Ü');
  if (!tone || tone === 5) return normalized;

  const marks = {
    a: ['ā', 'á', 'ǎ', 'à'],
    e: ['ē', 'é', 'ě', 'è'],
    i: ['ī', 'í', 'ǐ', 'ì'],
    o: ['ō', 'ó', 'ǒ', 'ò'],
    u: ['ū', 'ú', 'ǔ', 'ù'],
    ü: ['ǖ', 'ǘ', 'ǚ', 'ǜ'],
    A: ['Ā', 'Á', 'Ǎ', 'À'],
    E: ['Ē', 'É', 'Ě', 'È'],
    I: ['Ī', 'Í', 'Ǐ', 'Ì'],
    O: ['Ō', 'Ó', 'Ǒ', 'Ò'],
    U: ['Ū', 'Ú', 'Ǔ', 'Ù'],
    Ü: ['Ǖ', 'Ǘ', 'Ǚ', 'Ǜ'],
  };
  const toneIndex = tone - 1;
  const lower = normalized.toLowerCase();
  let markIndex = lower.indexOf('a');
  if (markIndex < 0) markIndex = lower.indexOf('e');
  if (markIndex < 0) markIndex = lower.indexOf('ou') >= 0 ? lower.indexOf('ou') + 1 : -1;
  if (markIndex < 0) {
    for (let index = normalized.length - 1; index >= 0; index -= 1) {
      if ('aeiouüAEIOUÜ'.includes(normalized[index])) {
        markIndex = index;
        break;
      }
    }
  }
  if (markIndex < 0) return normalized;
  const char = normalized[markIndex];
  return `${normalized.slice(0, markIndex)}${marks[char]?.[toneIndex] || char}${normalized.slice(markIndex + 1)}`;
}

function normalizePinyinControl(control) {
  const nextValue = convertToPinyinWithTones(control.value);
  if (nextValue !== control.value) control.value = nextValue;
}

function attachPinyinAutoTone(control) {
  if (!control || control.dataset.pinyinAutoTone === 'true') return;
  control.dataset.pinyinAutoTone = 'true';
  control.addEventListener('keyup', (event) => {
    if (event.key === ' ' || event.key === 'Enter') normalizePinyinControl(control);
  });
  control.addEventListener('blur', () => normalizePinyinControl(control));
}

function shouldAutoTonePinyin(key, label, control) {
  if (!control || !('value' in control)) return false;
  return /(^|[^a-z])(pinyin|py)([^a-z]|$)/i.test(`${key} ${label}`);
}

function createImageUploader(initialUrl = '') {
  let imageUrl = String(initialUrl || '').trim();
  const preview = el('div', { class: 'image-uploader-preview' });
  const statusText = el(
    'p',
    { class: 'topic-note' },
    imageUrl || 'Chưa có ảnh. Hãy chọn file jpg, png hoặc webp. DB sẽ lưu URL/path sau khi bạn lưu thay đổi và xuất bản.',
  );
  const fileInput = el('input', {
    type: 'file',
    accept: 'image/png,image/jpeg,image/webp',
    class: 'hidden-file',
  });
  const chooseButton = button('Chọn ảnh và upload', 'ghost-button', () => {
    fileInput.click();
  });

  function renderPreview() {
    preview.innerHTML = '';
    const previewSrc = adminImagePreviewSrc(imageUrl);
    if (!previewSrc) {
      preview.appendChild(el('div', { class: 'image-placeholder' }, 'Chưa có ảnh'));
      return;
    }
    const img = el('img', {
      src: previewSrc,
      alt: 'Flashcard preview',
      loading: 'lazy',
    });
    img.addEventListener('error', () => {
      preview.innerHTML = '';
      preview.appendChild(el('div', { class: 'image-placeholder' }, 'Không xem được ảnh này'));
    });
    preview.appendChild(img);
  }

  fileInput.addEventListener('change', async () => {
    const file = fileInput.files?.[0];
    fileInput.value = '';
    if (!file) return;
    chooseButton.disabled = true;
    statusText.textContent = 'Đang upload ảnh lên backend...';
    try {
      const data = await uploadAdminImage(file);
      imageUrl = data.url;
      statusText.textContent = imageUrl;
      renderPreview();
    } catch (error) {
      statusText.textContent = `Upload thất bại: ${error.message}`;
    } finally {
      chooseButton.disabled = false;
    }
  });

  renderPreview();
  return {
    node: el('div', { class: 'image-uploader' }, [
      preview,
      el('div', { class: 'toolbar-group' }, [chooseButton]),
      fileInput,
      statusText,
    ]),
    getValue: () => imageUrl,
  };
}

function validateTranscriptRows(rows, statusValue) {
  const statusName = String(statusValue || 'draft').toLowerCase();
  if (statusName === 'draft') return;
  const issues = [];
  if (!rows.length) issues.push('Transcript cần ít nhất 1 câu.');
  rows.forEach((line, index) => {
    if (!line.cn) issues.push(`Dòng ${index + 1} thiếu câu tiếng Trung.`);
    if (!Number.isFinite(line.start) || !Number.isFinite(line.end)) {
      issues.push(`Dòng ${index + 1} có mốc thời gian không hợp lệ.`);
    }
    if (line.end <= line.start) {
      issues.push(`Dòng ${index + 1} cần end lớn hơn start.`);
    }
    const previous = rows[index - 1];
    if (previous && line.start < previous.end) {
      issues.push(`Dòng ${index + 1} bị chồng timing với dòng ${index}.`);
    }
  });
  if (issues.length) throw new Error(issues.slice(0, 3).join(' '));
}

function validateFlashcardWords(rows) {
  const seen = new Set();
  const issues = [];
  rows.forEach((item, index) => {
    if (!item.word) issues.push(`Dòng ${index + 1} thiếu Hán tự.`);
    if (!item.pinyin) issues.push(`Dòng ${index + 1} thiếu pinyin.`);
    if (!item.meaning) issues.push(`Dòng ${index + 1} thiếu nghĩa Việt.`);
    if (seen.has(item.word)) issues.push(`Từ ${item.word} đang bị trùng trong topic.`);
    seen.add(item.word);
  });
  if (issues.length) throw new Error(issues.slice(0, 3).join(' '));
}

function isTimedTranscript(rows) {
  try {
    validateTranscriptRows(rows, 'published');
    return true;
  } catch (_) {
    return false;
  }
}

function openVideoEditor(video) {
  const values = video || {
    title: '',
    level: 'HSK 1',
    youtubeId: '',
    source: 'YouTube',
    status: 'draft',
    transcript: [],
  };
  values.transcript = video?.transcript || [];
  openEditor({
    title: video ? 'Sửa video và transcript' : 'Thêm video shadowing',
    area: 'Video',
    values,
    fields: [
      ['title', 'Tiêu đề'],
      ['youtubeId', 'YouTube video ID'],
      ['source', 'Nguồn'],
      ['level', 'HSK', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4']],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
      ['transcript', 'Transcript theo từng câu', 'custom', createVideoTranscriptGrid],
    ],
    onSave(raw) {
      const transcript = raw.transcript;
      validateTranscriptRows(transcript, raw.status);
      upsert('lessons', {
        ...video,
        id: video?.id || uid(),
        type: 'Video',
        title: raw.title,
        youtubeId: raw.youtubeId.trim(),
        source: raw.source,
        level: raw.level,
        status: raw.status,
        transcript,
        items: transcript.length,
        transcriptStatus: isTimedTranscript(transcript) ? 'timed' : 'untimed',
      });
    },
  });
}

function openReadingSourceEditor(source) {
  openEditor({
    title: source ? 'Sửa nguồn báo' : 'Thêm nguồn báo',
    area: 'Reading',
    values: source || { name: '', url: '', level: 'HSK 4', status: 'active' },
    fields: [
      ['name', 'Tên nguồn'],
      ['url', 'URL RSS/API'],
      ['level', 'Cấp đọc', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4']],
      ['status', 'Trạng thái', 'select', ['active', 'archived']],
    ],
    onSave(values) {
      upsert('readingSources', { ...values, id: source?.id || slug(values.name) });
    },
  });
}

function openArticleEditor(article) {
  const values = {
    id: article?.id || '',
    source: article?.source || 'VNChinese',
    level: article?.level || 'HSK 3',
    title: article?.title || '',
    titleVi: article?.titleVi || '',
    summaryVi: article?.summaryVi || '',
    content: article?.content || '',
    link: article?.link || '',
    status: article?.status || 'draft',
  };
  openEditor({
    title: article ? 'Sửa bài đọc' : 'Thêm bài đọc',
    area: 'Reading',
    values,
    fields: [
      ['source', 'Nguồn'],
      ['level', 'HSK', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6']],
      ['title', 'Tiêu đề tiếng Trung'],
      ['titleVi', 'Tiêu đề tiếng Việt'],
      ['summaryVi', 'Tóm tắt tiếng Việt', 'textarea'],
      ['content', 'Nội dung tiếng Trung', 'textarea'],
      ['link', 'Link nguồn'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
    ],
    onSave(values) {
      upsert('articles', {
        ...article,
        ...values,
        id: article?.id || slug(values.title || `article-${Date.now()}`),
        sentences: article?.sentences || [],
      });
    },
  });
}

function openSpeakingEditor(item) {
  openEditor({
    title: item ? 'Sửa câu luyện nói' : 'Thêm câu luyện nói',
    area: 'Speaking',
    values: item || {
      level: 'HSK 1',
      topic: 'Giao tiếp hằng ngày',
      cn: '',
      py: '',
      vi: '',
      status: 'draft',
    },
    fields: [
      ['level', 'Cấp độ', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4']],
      ['topic', 'Tình huống'],
      ['cn', 'Câu tiếng Trung'],
      ['py', 'Pinyin có dấu'],
      ['vi', 'Nghĩa tiếng Việt'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
    ],
    onSave(values) {
      upsert('pronunciation', { ...item, ...values, id: item?.id || uid() });
    },
  });
}

function openGameEditor(game) {
  openEditor({
    title: game ? 'Sửa trò chơi' : 'Thêm trò chơi',
    area: 'Game',
    values: game || {
      title: '',
      type: 'multiple_choice',
      level: 'HSK 1',
      source: 'Flashcard đã published',
      scope: 'Theo chủ đề flashcard',
      generation: 'auto',
      questionCount: 10,
      status: 'draft',
    },
    fields: [
      ['title', 'Tên trò chơi'],
      ['type', 'Kiểu', 'select', ['multiple_choice', 'listening', 'sentence_order', 'matching']],
      ['level', 'HSK', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6', 'HSK 1-4']],
      ['source', 'Nguồn dữ liệu', 'select', ['Flashcard đã published', 'Từ vựng đã published', 'Ngữ pháp đã published', 'Bộ câu thủ công']],
      ['scope', 'Phạm vi dữ liệu'],
      ['generation', 'Cách tạo câu hỏi', 'select', ['auto', 'manual']],
      ['questionCount', 'Số câu mỗi lượt', 'number'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
    ],
    onSave(values) {
      upsert('games', {
        ...game,
        ...values,
        questionCount: Number(values.questionCount || game?.questionCount || 10),
        id: game?.id || uid(),
      });
    },
  });
}

function parseTranscript(text) {
  return String(text || '')
    .split(/\n+/)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [start = '0', end = '0', cn = '', py = '', vi = ''] = line.split('|').map((part) => part.trim());
      return { start: Number(start), end: Number(end), cn, py, vi };
    })
    .filter((line) => line.cn);
}

function parseExamples(text) {
  return String(text || '')
    .split(/\n+/)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [cn = '', py = '', vi = ''] = line.split('|').map((part) => part.trim());
      return { cn, py, vi };
    })
    .filter((example) => example.cn);
}

function openVocabularyEditor(item) {
  openEditor({
    title: item ? 'Sửa từ vựng' : 'Thêm từ vựng',
    area: 'Vocabulary',
    values: item || { simplified: '', pinyin: '', meaningVi: '', hsk: 'HSK 1', type: 'danh từ', status: 'draft' },
    fields: [
      ['simplified', 'Hán tự'],
      ['pinyin', 'Pinyin'],
      ['meaningVi', 'Nghĩa Việt'],
      ['hsk', 'HSK', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6']],
      ['type', 'Loại từ'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
    ],
    onSave(values) {
      upsert('vocabulary', { ...values, id: item?.id || uid() });
    },
  });
}

function openGrammarEditor(item) {
  const values = {
    id: item?.id || '',
    level: item?.level || 'HSK 1',
    title: item?.title || '',
    pattern: item?.pattern || '',
    explanation: item?.explanation || '',
    examplesText: (item?.examples || []).map((example) => [
      example.cn || '',
      example.py || '',
      example.vi || '',
    ].join('|')).join('\n'),
    note: item?.note || '',
    status: item?.status || 'draft',
  };
  openEditor({
    title: item ? 'Sửa mẫu ngữ pháp' : 'Thêm mẫu ngữ pháp',
    area: 'Grammar',
    values,
    fields: [
      ['level', 'HSK', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6']],
      ['title', 'Tên mẫu câu'],
      ['pattern', 'Cấu trúc'],
      ['explanation', 'Giải thích', 'textarea'],
      ['examplesText', 'Ví dụ: Trung | pinyin | Việt', 'textarea'],
      ['note', 'Ghi chú'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
    ],
    onSave(values) {
      upsert('grammar', {
        ...item,
        ...values,
        id: item?.id || slug(values.title || `grammar-${Date.now()}`),
        examples: parseExamples(values.examplesText),
      });
    },
  });
}

function openTopicEditor(topic) {
  const values = topic ? { ...topic } : {
    id: slug(`topic-${Date.now()}`),
    name: '',
    level: 'HSK 1',
    status: 'draft',
    imagePath: '',
    words: [],
  };
  values.imageUrl = topicImageUrl(values);
  values.words = topic?.words || [];
  openEditor({
    title: topic ? 'Sửa topic flashcard' : 'Thêm topic flashcard',
    area: 'Flashcard',
    values,
    fields: [
      ['id', 'Mã topic'],
      ['name', 'Tên topic'],
      ['level', 'Level'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
      ['imageUrl', 'Ảnh đại diện', 'custom', createImageUploader],
      ['words', 'Từ trong topic', 'custom', createFlashcardWordsGrid],
    ],
    onSave(raw) {
      validateFlashcardWords(raw.words);
      const imageUrl = String(raw.imageUrl || '').trim();
      const next = {
        id: slug(raw.id || raw.name),
        name: raw.name,
        level: raw.level,
        status: raw.status,
        imagePath: imageUrl,
        imageUrl,
        uploadedImageName: imageFileName(imageUrl),
        words: raw.words,
      };
      const duplicate = state.flashcards.find((candidate) =>
        candidate.id !== topic?.id &&
        flashcardTopicKey(candidate) === flashcardTopicKey(next),
      );
      if (duplicate) {
        throw new Error(
          `Đã có topic "${duplicate.name}" cùng cấp ${duplicate.level}. Hãy sửa topic hiện có thay vì tạo bản trùng.`,
        );
      }
      upsert('flashcards', next);
    },
  });
}

function flashcardTopicKey(topic) {
  const raw = String(topic?.name || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, ' ')
    .trim();
  const canonicalName = /(^| )gia dinh( |$)|(^| )family( |$)/.test(raw)
    ? 'family'
    : raw;
  return `${String(topic?.level || 'HSK 1').toUpperCase()}|${canonicalName}`;
}

function openLessonEditor(lesson) {
  openEditor({
    title: lesson ? 'Sửa bài học' : 'Thêm bài học',
    area: 'Lessons',
    values: lesson || { type: 'Ngữ pháp', title: '', subject: 'Tổng hợp', level: 'HSK 1', items: 1, status: 'draft' },
    fields: [
      ['type', 'Loại', 'select', ['Ngữ pháp', 'Đọc hiểu', 'Video']],
      ['title', 'Tiêu đề'],
      ['subject', 'Chủ đề'],
      ['level', 'Level'],
      ['items', 'Số mục'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
    ],
    onSave(values) {
      upsert('lessons', { ...values, id: lesson?.id || uid(), items: Number(values.items || 0) });
    },
  });
}

function openUserEditor(user) {
  openEditor({
    title: user ? 'Sửa người dùng' : 'Thêm người dùng',
    area: 'Users',
    values: user || { displayName: '', email: '', password: '', role: 'user', targetLevel: 'HSK 1', status: 'active' },
    fields: [
      ['displayName', 'Tên hiển thị'],
      ['email', 'Email'],
      ['password', user ? 'Mật khẩu mới (để trống nếu giữ nguyên)' : 'Mật khẩu'],
      ['role', 'Vai trò', 'select', ['user', 'editor', 'reviewer', 'admin']],
      ['targetLevel', 'Mục tiêu', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6']],
      ['status', 'Trạng thái', 'select', ['active', 'blocked']],
    ],
    async onSave(values) {
      await saveAdminUser(user, values);
    },
  });
}

async function saveAdminUser(user, values) {
  if (!adminToken) {
    upsert('users', { ...user, ...values, id: user?.id || uid() });
    return;
  }
  const payload = { ...values };
  if (!payload.password) delete payload.password;
  const response = await fetchApi(
    user ? `/admin/users/${user.id}` : '/admin/users',
    {
      method: user ? 'PATCH' : 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${adminToken}`,
      },
      body: JSON.stringify(payload),
    },
  );
  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
  await loadBackendUsers();
}

async function openUserDetail(id) {
  if (!adminToken) {
    showToast('Chi tiết tiến độ cần đăng nhập admin trực tuyến.');
    return;
  }
  try {
    const detail = await apiFetch(`/admin/users/${id}`);
    document.querySelector('#saveDialogBtn').style.display = 'none';
    dialogEyebrow.textContent = 'User analytics';
    dialogTitle.textContent = detail.profile.displayName || detail.profile.email;
    dialogFields.innerHTML = '';
    const profile = detail.profile;
    const overview = metricGrid([
      ['Từ đã học', profile.progress?.learnedWords || 0, `${profile.progress?.masteredWords || 0} từ đã vững`],
      ['Phút học', profile.progress?.studyMinutes || 0, `${profile.progress?.activeDays || 0} ngày hoạt động`],
      ['Bài luyện', profile.progress?.attempts || 0, `${profile.progress?.averageScore || 0}% trung bình`],
      ['Cần ôn', profile.progress?.dueReview || 0, 'theo lịch SRS'],
    ]);
    const activity = tablePanel(
      ['Ngày', 'Phút', 'Từ mới', 'Quiz', 'Đọc', 'AI'],
      (detail.activity || []).slice(-14).map((day) => [
        new Date(`${day.date}T00:00:00`).toLocaleDateString('vi-VN'),
        day.studyMinutes,
        day.learnedWords,
        day.quizzes,
        day.reading,
        day.aiInteractions,
      ]),
    );
    const attempts = tablePanel(
      ['Loại', 'Điểm', 'Đúng/Tổng', 'Thời gian'],
      (detail.recentAttempts || []).slice(0, 8).map((attempt) => [
        attempt.type,
        `${attempt.score}%`,
        `${attempt.correctCount}/${attempt.totalCount}`,
        new Date(attempt.completedAt).toLocaleString('vi-VN'),
      ]),
    );
    dialogFields.appendChild(overview);
    dialogFields.appendChild(el('div', { class: 'profile-summary' }, [
      el('strong', {}, profile.email),
      el('span', {}, `${profile.role} · ${profile.status} · ${profile.targetLevel}`),
    ]));
    dialogFields.appendChild(panel('Hoạt động 14 ngày', activity));
    dialogFields.appendChild(panel('Bài luyện gần đây', attempts));
    dialog.showModal();
  } catch (error) {
    showToast(`Chưa tải được chi tiết user: ${error.message}`);
  }
}

function openEditor(config) {
  document.querySelector('#saveDialogBtn').style.display = '';
  dialogEyebrow.textContent = config.area;
  dialogTitle.textContent = config.title;
  dialogFields.innerHTML = '';
  const controls = {};
  config.fields.forEach(([key, label, type = 'input', options = []]) => {
    const field = el(type === 'custom' ? 'div' : 'label', { class: 'field' }, [
      el('span', {}, label),
    ]);
    let control;
    if (type === 'select') {
      control = select(options, config.values[key] ?? options[0], null);
    } else if (type === 'textarea') {
      control = el('textarea', {}, config.values[key] ?? '');
    } else if (type === 'custom' && typeof options === 'function') {
      control = options(config.values[key], config.values);
      field.appendChild(control.node || control);
      dialogFields.appendChild(field);
      controls[key] = control;
      return;
    } else {
      const inputType = type === 'number' ? 'number' : key === 'password' ? 'password' : 'text';
      control = el('input', { value: config.values[key] ?? '', type: inputType });
    }
    if (shouldAutoTonePinyin(key, label, control)) attachPinyinAutoTone(control);
    field.appendChild(control);
    dialogFields.appendChild(field);
    controls[key] = control;
  });
  editorForm.onsubmit = async (event) => {
    event.preventDefault();
    const values = {};
    Object.entries(controls).forEach(([key, control]) => {
      values[key] = typeof control.getValue === 'function'
        ? control.getValue()
        : control.value;
    });
    try {
      await config.onSave(values);
      dialog.close();
      saveState();
      render();
      showToast('Đã lưu thay đổi.');
    } catch (error) {
      showToast(`Chưa lưu được: ${error.message}`);
    }
  };
  dialog.showModal();
}

function upsert(collection, item) {
  const list = state[collection];
  const index = list.findIndex((entry) => entry.id === item.id);
  if (index >= 0) list[index] = item;
  else list.unshift(item);
}

function deleteItem(collection, id) {
  if (!confirm('Lưu trữ mục này? Mục archived sẽ không hiển thị trong app user sau khi publish.')) return;
  const item = state[collection]?.find((entry) => entry.id === id);
  if (item && 'status' in item) {
    item.status = collection === 'readingSources' ? 'archived' : 'archived';
  } else {
    state[collection] = state[collection].filter((entry) => entry.id !== id);
  }
  saveState();
  render();
  showToast('Đã chuyển mục sang trạng thái lưu trữ.');
}

function duplicateTopic(id) {
  const topic = state.flashcards.find((item) => item.id === id);
  if (!topic) return;
  const copy = structuredClone(topic);
  copy.id = `${topic.id}-copy-${Date.now().toString(36)}`;
  copy.name = `${topic.name} bản sao`;
  copy.status = 'draft';
  state.flashcards.unshift(copy);
  saveState();
  render();
  showToast('Đã nhân bản topic.');
}

function topicImage(topic) {
  const wrapper = el('div', { class: 'topic-media' });
  const imageUrl = topicImageUrl(topic);
  const previewSrc = adminImagePreviewSrc(imageUrl);
  if (!previewSrc) {
    wrapper.appendChild(el('div', { class: 'image-placeholder' }, 'Chưa có ảnh. Bấm Đăng ảnh để upload lên backend.'));
    return wrapper;
  }

  const img = el('img', { src: previewSrc, alt: topic.name, loading: 'lazy' });
  img.addEventListener('error', () => {
    wrapper.innerHTML = '';
    wrapper.appendChild(el('div', { class: 'image-placeholder' }, `Không xem được ảnh: ${imageFileName(imageUrl) || 'đường dẫn chưa hợp lệ'}`));
  });
  wrapper.appendChild(img);
  return wrapper;
}

function uploadTopicImage(topicId) {
  const topic = state.flashcards.find((item) => item.id === topicId);
  if (!topic || !imageUploadInput) return;

  imageUploadInput.value = '';
  imageUploadInput.onchange = async (event) => {
    const file = event.target.files?.[0];
    event.target.value = '';
    if (!file) return;
    try {
      showToast('Đang upload ảnh lên backend...');
      const data = await uploadAdminImage(file);
      topic.imagePath = data.url;
      topic.imageUrl = data.url;
      topic.uploadedImageName = data.filename || imageFileName(data.url);
      saveState();
      render();
      showToast('Đã upload ảnh và lưu URL tĩnh cho topic.');
    } catch (error) {
      showToast(`Upload ảnh thất bại: ${error.message}`);
    }
  };
  imageUploadInput.click();
}

async function toggleUserStatus(id) {
  const user = state.users.find((item) => item.id === id);
  if (!user) return;
  const nextStatus = user.status === 'blocked' ? 'active' : 'blocked';
  if (!adminToken) {
    user.status = nextStatus;
    saveState();
    render();
    return;
  }
  try {
    const response = await fetchApi(`/admin/users/${id}/status`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${adminToken}`,
      },
      body: JSON.stringify({ status: nextStatus }),
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
    await loadBackendUsers();
  } catch (error) {
    showToast(`Chưa đổi được trạng thái: ${error.message}`);
  }
}

function approveReview(id, item = null) {
  if (item) dismissReviewKey(item);
  state.review = state.review.filter((entry) => entry.id !== id);
  saveState();
  render();
  showToast('Đã duyệt mục kiểm duyệt.');
}

function dismissReview(id, item = null) {
  if (item) dismissReviewKey(item);
  state.review = state.review.filter((entry) => entry.id !== id);
  saveState();
  render();
}

function approveAllReview() {
  state.reviewDismissed = unique([
    ...(state.reviewDismissed || []),
    ...mergeReviewIssues(state.review, runQualityChecks()).map(reviewIssueKey),
  ]);
  state.review = [];
  saveState();
  render();
  showToast('Đã duyệt toàn bộ hàng chờ.');
}

function reviewIssueKey(item) {
  return `${item?.area || ''}|${item?.title || ''}|${item?.issue || ''}`;
}

function isReviewDismissed(item) {
  return (state.reviewDismissed || []).includes(reviewIssueKey(item));
}

function dismissReviewKey(item) {
  state.reviewDismissed = unique([...(state.reviewDismissed || []), reviewIssueKey(item)]);
}

function openReviewTarget(item) {
  const area = String(item?.area || '').toLowerCase();
  if (area.includes('video')) activeView = 'videos';
  else if (area.includes('flashcard')) activeView = 'flashcards';
  else if (area.includes('từ vựng') || area.includes('vocabulary')) activeView = 'vocabulary';
  else if (area.includes('ngữ pháp') || area.includes('grammar')) activeView = 'lessons';
  else if (area.includes('bài đọc') || area.includes('đọc')) activeView = 'reading';
  else if (area.includes('luyện nói') || area.includes('nói')) activeView = 'speaking';
  else activeView = 'dashboard';
  setActiveNav();
  render();
}

function runQualityChecks() {
  const issues = [];
  const knownTopics = new Map();
  state.flashcards.forEach((topic) => {
    const key = flashcardTopicKey(topic);
    const duplicate = knownTopics.get(key);
    if (duplicate) {
      issues.push(reviewIssue(
        'Flashcard',
        topic.name,
        `Trùng topic với "${duplicate.name}" ở ${topic.level}`,
        'fail',
      ));
    } else {
      knownTopics.set(key, topic);
    }
    if (!topicImageUrl(topic)) issues.push(reviewIssue('Flashcard', topic.name, 'Thiếu ảnh đại diện topic', 'fail'));
    if (topic.status !== 'published') issues.push(reviewIssue('Flashcard', topic.name, `Topic đang ở trạng thái ${topic.status}`, 'pending'));
    const seenWords = new Set();
    const seenImages = new Map();
    topic.words.forEach((item) => {
      if (!item.pinyin || !item.meaning) issues.push(reviewIssue('Từ flashcard', item.word, 'Thiếu pinyin hoặc nghĩa Việt', 'fail'));
      if (looksBroken([item.word, item.pinyin, item.meaning].join(' '))) issues.push(reviewIssue('Từ flashcard', item.word, 'Có dấu hiệu mojibake', 'fail'));
      if (!wordImageInputValue(item)) issues.push(reviewIssue('Từ flashcard', item.word || topic.name, 'Thiếu ảnh minh họa cho từ', 'pending'));
      if (seenWords.has(item.word)) issues.push(reviewIssue('Flashcard', topic.name, `Từ ${item.word} bị trùng trong topic`, 'fail'));
      seenWords.add(item.word);
      const image = wordImageInputValue(item);
      if (image) {
        const previousWord = seenImages.get(image);
        if (previousWord && previousWord !== item.word) {
          issues.push(reviewIssue('Flashcard', topic.name, `Ảnh ${image} đang dùng cho cả ${previousWord} và ${item.word}`, 'pending'));
        } else {
          seenImages.set(image, item.word);
        }
      }
    });
  });
  state.vocabulary.forEach((item) => {
    if (!item.pinyin || !item.meaningVi) issues.push(reviewIssue('Từ vựng', item.simplified, 'Thiếu pinyin hoặc nghĩa Việt', 'fail'));
    if (item.status !== 'published') issues.push(reviewIssue('Từ vựng', item.simplified, `Trạng thái ${item.status}`, 'pending'));
  });
  state.pronunciation.forEach((item) => {
    if (!item.topic || !item.cn || !item.py || !item.vi) {
      issues.push(reviewIssue('Luyện nói', item.cn || item.id, 'Thiếu tình huống, câu Trung, pinyin hoặc nghĩa Việt', 'fail'));
    }
    if (item.status !== 'published') {
      issues.push(reviewIssue('Luyện nói', item.cn || item.id, `Trạng thái ${item.status}`, 'pending'));
    }
  });
  (state.grammar || []).forEach((item) => {
    if (!item.title || !item.pattern || !item.explanation) {
      issues.push(reviewIssue('Ngữ pháp', item.title || item.id, 'Thiếu tên mẫu, cấu trúc hoặc giải thích', 'fail'));
    }
    if (item.status !== 'published') {
      issues.push(reviewIssue('Ngữ pháp', item.title || item.id, `Trạng thái ${item.status}`, 'pending'));
    }
  });
  (state.articles || []).forEach((item) => {
    if (!item.title || !item.content || !item.summaryVi) {
      issues.push(reviewIssue('Bài đọc', item.title || item.id, 'Thiếu tiêu đề, nội dung hoặc tóm tắt tiếng Việt', 'fail'));
    }
    if (looksBroken([item.title, item.titleVi, item.summaryVi].join(' '))) {
      issues.push(reviewIssue('Bài đọc', item.title || item.id, 'Có dấu hiệu lỗi mã hóa', 'fail'));
    }
    if (item.status !== 'published') {
      issues.push(reviewIssue('Bài đọc', item.title || item.id, `Trạng thái ${item.status}`, 'pending'));
    }
  });
  state.lessons.filter((lesson) => lesson.type === 'Video').forEach((video) => {
    if (!video.youtubeId) issues.push(reviewIssue('Video', video.title, 'Thiếu YouTube ID', 'fail'));
    if (VIDEO_UNAVAILABLE_IDS.has(String(video.youtubeId || '').trim())) {
      issues.push(reviewIssue('Video', video.title, 'YouTube ID này đang bị mobile chặn vì unavailable, user sẽ không thấy video', 'fail'));
    }
    if (video.youtubeStatus === 'dead') issues.push(reviewIssue('Video', video.title, 'YouTube dead link, cần thay video hoặc tắt publish', 'fail'));
    if (video.youtubeStatus === 'error') issues.push(reviewIssue('Video', video.title, 'Chưa kiểm tra được trạng thái YouTube', 'pending'));
    const transcript = Array.isArray(video.transcript) ? video.transcript : [];
    try {
      validateTranscriptRows(transcript, video.status);
    } catch (error) {
      issues.push(reviewIssue('Video', video.title, error.message, 'fail'));
    }
    transcript.forEach((line, index) => {
      if (!line.py || !line.vi) {
        issues.push(reviewIssue('Video', video.title, `Dòng ${index + 1} thiếu pinyin hoặc nghĩa Việt`, 'fail'));
      }
    });
    const span = transcript.length
      ? Math.max(...transcript.map((line) => Number(line.end) || 0)) -
        Math.min(...transcript.map((line) => Number(line.start) || 0))
      : 0;
    if (['review', 'published'].includes(String(video.status || '').toLowerCase()) && transcript.length < 8) {
      issues.push(reviewIssue('Video', video.title, 'Transcript quá ít câu; app sẽ khó tự dừng cho người học', 'pending'));
    }
    if (span >= 120 && transcript.length < Math.ceil(span / 20)) {
      issues.push(reviewIssue('Video', video.title, 'Video dài nhưng mật độ phụ đề quá thưa, cần bổ sung câu', 'pending'));
    }
    if (video.transcriptStatus !== 'timed') {
      issues.push(reviewIssue('Video', video.title, 'Chưa có start/end đầy đủ nên app không thể tự dừng theo câu', 'pending'));
    }
  });
  state.flashcards.forEach((topic) => {
    if (/[A-Za-z]\b/.test(topic.name) && !/[À-ỹ]/.test(topic.name)) {
      issues.push(reviewIssue('Flashcard', topic.name, 'Tên chủ đề có thể đang thiếu dấu tiếng Việt', 'pending'));
    }
  });
  return issues;
}

function qualitySummary() {
  const issues = runQualityChecks();
  const list = el('div', { class: 'qa-list' });
  const cleanCount = Math.max(0, state.vocabulary.length + state.flashcards.length - issues.length);
  [
    ['✓', `${cleanCount} mục sạch`, 'Không thiếu nghĩa/pinyin trong dữ liệu đang publish.', 'ok'],
    ['?', `${issues.filter((item) => item.severity === 'pending').length} mục chờ duyệt`, 'Nội dung draft/review cần reviewer xác nhận.', 'warn'],
    ['!', `${issues.filter((item) => item.severity === 'fail').length} lỗi cần sửa`, 'Thiếu trường bắt buộc hoặc có dấu hiệu lỗi mã hóa.', 'fail'],
  ].forEach(([mark, title, desc, type]) => {
    list.appendChild(el('div', { class: 'qa-item' }, [
      el('span', { class: `qa-dot ${type === 'warn' ? 'warn' : type === 'fail' ? 'fail' : ''}` }, mark),
      el('div', {}, [el('strong', {}, title), el('p', {}, desc)]),
      el('span', { class: 'status' }, type),
    ]));
  });
  return list;
}

function publishFlow() {
  const steps = [
    ['Draft', 'Editor nhập từ, ảnh, ví dụ và topic.'],
    ['Review', 'Reviewer chạy QA, sửa lỗi nghĩa/pinyin/ảnh trùng.'],
    ['Publish', 'Admin xuất bundle JSON và cập nhật app/backend.'],
    ['Monitor', 'Theo dõi từ lỗi, topic học nhiều, phản hồi người dùng.'],
  ];
  return el('div', { class: 'qa-list' }, steps.map(([title, desc], index) => el('div', { class: 'qa-item' }, [
    el('span', { class: 'qa-dot' }, String(index + 1)),
    el('div', {}, [el('strong', {}, title), el('p', {}, desc)]),
    el('span', { class: 'status approved' }, 'ready'),
  ])));
}

function adminActivityChart(days) {
  const values = Array.isArray(days) && days.length ? days : Array.from({ length: 7 }, (_, index) => ({
    date: new Date(Date.now() - (6 - index) * 86400000).toISOString().slice(0, 10),
    studyMinutes: 0,
    learnedWords: 0,
    activeUsers: 0,
  }));
  const peak = Math.max(1, ...values.map((item) => Number(item.studyMinutes || 0)));
  return el('div', { class: 'admin-chart' }, values.map((item) => {
    const minutes = Number(item.studyMinutes || 0);
    const date = new Date(`${item.date}T00:00:00`);
    return el('div', { class: 'chart-day' }, [
      el('strong', {}, minutes ? `${minutes}p` : '0'),
      el('span', { class: 'chart-bar', style: `height:${Math.max(6, (minutes / peak) * 96)}px` }),
      el('small', {}, date.toLocaleDateString('vi-VN', { weekday: 'short' })),
      el('em', {}, `${item.activeUsers || 0} user`),
    ]);
  }));
}

function hskDistribution(rows) {
  const values = Array.isArray(rows) && rows.length ? rows : ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'].map((level) => ({ level, users: 0 }));
  const peak = Math.max(1, ...values.map((item) => Number(item.users || 0)));
  return el('div', { class: 'hsk-bars' }, values.map((item) => el('div', { class: 'hsk-row' }, [
    el('span', {}, item.level),
    el('div', { class: 'hsk-track' }, [
      el('span', { style: `width:${Math.max(4, (Number(item.users || 0) / peak) * 100)}%` }),
    ]),
    el('strong', {}, item.users || 0),
  ])));
}

function appConnectionSummary() {
  const publishedTopics = state.flashcards.filter((topic) => topic.status === 'published').length;
  const imageReady = state.flashcards.filter((topic) => Boolean(topicImageUrl(topic))).length;
  const version = state.dashboard?.latestVersion;
  const modules = [
    ['Từ vựng', 'vocabulary', state.vocabulary.filter((item) => item.status === 'published').length, state.vocabulary.length, '/content/vocabulary'],
    ['Flashcard', 'flashcards', publishedTopics, state.flashcards.length, '/content/flashcards'],
    ['Ngữ pháp', 'lessons', (state.grammar || []).filter((item) => item.status === 'published').length, (state.grammar || []).length, '/content/grammar'],
    ['Video', 'videos', state.lessons.filter((item) => item.type === 'Video' && videoUserVisibility(item).ready).length, state.lessons.filter((item) => item.type === 'Video').length, '/content/videos'],
    ['Đọc hiểu', 'reading', (state.articles || []).filter((item) => item.status === 'published').length, (state.articles || []).length, '/reading/news'],
    ['Luyện nói', 'speaking', state.pronunciation.filter((item) => item.status === 'published').length, state.pronunciation.length, 'mobile reading_hsk.json / admin publish'],
  ];
  return el('div', { class: 'connection-grid' }, [
    el('div', { class: 'connection-card' }, [
      el('strong', {}, 'Nguồn flashcard mobile'),
      el('code', {}, 'apps/mobile/assets/images/flashcards/index.json'),
    ]),
    el('div', { class: 'connection-card' }, [
      el('strong', {}, `${publishedTopics}/${state.flashcards.length} topic publish`),
      el('p', {}, `${imageReady} topic có ảnh đại diện admin preview.`),
    ]),
    el('div', { class: 'connection-card' }, [
      el('strong', {}, 'Backend API'),
      el('code', {}, state.settings.apiBaseUrl || 'Chưa cấu hình'),
    ]),
    el('div', { class: 'connection-card' }, [
      el('strong', {}, 'Phiên bản dữ liệu'),
      el('p', {}, version ? `${version.code} · ${version.itemCount} mục` : state.settings.contentVersion),
    ]),
    el('div', { class: 'connection-card' }, [
      el('strong', {}, 'AI ngữ pháp'),
      el('p', {}, 'POST /grammar/check · Gemini backend · không chấm mặc định ở frontend.'),
    ]),
    ...modules.map(([label, view, published, total, endpoint]) => syncModuleCard(label, view, published, total, endpoint)),
  ]);
}

function syncModuleCard(label, view, published, total, endpoint) {
  const ratio = total ? published / total : 0;
  return el('div', { class: 'connection-card sync-card' }, [
    el('div', { class: 'sync-card-head' }, [
      el('strong', {}, label),
      status(total && published === total ? 'approved' : published ? 'review' : 'draft'),
    ]),
    el('p', {}, `${published}/${total} mục published`),
    el('div', { class: 'sync-track' }, [el('span', { style: `width:${Math.round(ratio * 100)}%` })]),
    el('code', {}, endpoint),
    button('Mở quản lý', 'ghost-button mini-button', () => {
      activeView = view;
      setActiveNav();
      render();
    }),
  ]);
}

function grammarApiQuickPanel() {
  return el('div', { class: 'toolbar-group' }, [
    button('Test câu sai mẫu', 'primary-button', testGrammarApi),
    el('p', { class: 'topic-note' }, 'Admin dùng cùng endpoint với app user để kiểm tra trạng thái AI và chất lượng prompt.'),
  ]);
}

function renderRecentActivity() {
  const rows = (state.auditLogs || []).slice(0, 8).map((item) => [
    item.entityType || 'system',
    `${item.adminName || 'System'} · ${item.action || 'UPDATE'} · ${item.entityId || ''}`,
    new Date(item.createdAt).toLocaleString('vi-VN'),
  ]);
  return panel(
    'Hoạt động gần đây',
    tablePanel(
      ['Khu vực', 'Thao tác', 'Thời gian'],
      rows.length
        ? rows
        : [['Hệ thống', 'Chưa có thao tác quản trị được ghi nhận', '—']],
    ),
  );
}

async function loadMobileFlashcardIndex() {
  const root = String(state.settings.mobileAssetRoot || '../mobile/assets').replace(/[\\/]+$/, '');
  try {
    const response = await fetch(`${root}/images/flashcards/index.json`);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
    if (!Array.isArray(data.topics)) throw new Error('Không thấy topics trong index.json');
    state.flashcards = data.topics.map(topicFromFlashcardIndex);
    saveState();
    activeView = 'flashcards';
    setActiveNav();
    render();
    showToast(`Đã nạp ${state.flashcards.length} topic từ app user.`);
  } catch (error) {
    showToast(`Chưa nạp được index mobile: ${error.message}`);
  }
}

function importJsonFile(event) {
  const file = event.target.files?.[0];
  event.target.value = '';
  if (!file) return;
  const reader = new FileReader();
  reader.onload = () => {
    try {
      const data = JSON.parse(String(reader.result || '{}'));
      if (Array.isArray(data.topics)) {
        state.flashcards = data.topics.map(topicFromFlashcardIndex);
        saveState();
        activeView = 'flashcards';
        setActiveNav();
        render();
        showToast(`Đã import ${state.flashcards.length} topic flashcard.`);
      } else if (data.flashcards || data.vocabulary) {
        state = { ...state, ...data, settings: { ...state.settings, ...(data.settings || {}) } };
        saveState();
        render();
        showToast('Đã import content bundle.');
      } else {
        showToast('File JSON chưa đúng định dạng admin.');
      }
    } catch (error) {
      showToast(`Không đọc được JSON: ${error.message}`);
    }
  };
  reader.readAsText(file, 'utf-8');
}

function exportContentBundle() {
  downloadJson(`vnchinese-content-${dateStamp()}.json`, {
    version: state.settings.contentVersion,
    exportedAt: new Date().toISOString(),
    vocabulary: state.vocabulary,
    flashcards: state.flashcards,
    pronunciation: state.pronunciation,
    lessons: state.lessons,
    lessonMap: buildLessonMapPayload(),
    grammar: state.grammar || [],
    readingSources: state.readingSources,
    articles: state.articles || [],
    games: state.games,
    aiSettings: state.aiSettings,
    users: state.users,
    review: state.review,
    settings: state.settings,
  });
}

function exportFlashcardIndex() {
  downloadJson('flashcard-index.admin-export.json', {
    version: state.settings.contentVersion,
    topics: state.flashcards.map(topicToFlashcardIndex),
  });
}

function exportLessonMap() {
  downloadJson('lesson-map.admin-export.json', buildLessonMapPayload());
}

function buildLessonMapPayload() {
  const components = lessonComponentInventory();
  return {
    version: state.settings.contentVersion,
    model: 'lesson-centric-v1',
    schema: {
      lesson: 'Container cấp HSK/chủ đề, tham chiếu componentIds thay vì nhúng toàn bộ nội dung.',
      componentTypes: ['Flashcard', 'Ngữ pháp', 'Đọc hiểu', 'Video', 'Quiz'],
      lifecycle: ['draft', 'review', 'published', 'archived'],
    },
    lessons: components.map((item) => ({
      lessonId: `${slug(item.level)}-${slug(item.subject)}-${slug(item.type)}-${slug(item.id)}`,
      level: item.level,
      subject: item.subject,
      type: item.type,
      title: item.title,
      status: item.status,
      componentRefs: [{ source: item.source, id: item.id }],
    })),
  };
}

function exportVideoCatalog() {
  downloadJson('video_lessons.admin-export.json', state.lessons
    .filter((lesson) => lesson.type === 'Video' && lesson.status !== 'archived')
    .map((video) => ({
      id: video.id,
      title: video.title,
      titleCn: video.titleCn || '',
      level: video.level,
      youtubeId: video.youtubeId,
      source: video.source || 'YouTube',
      transcriptStatus: video.transcriptStatus || 'untimed',
      youtubeStatus: video.youtubeStatus || 'unchecked',
      youtubeCheckedAt: video.youtubeCheckedAt || '',
      subtitles: video.transcript || [],
    })));
}

function topicFromFlashcardIndex(topic) {
  const id = String(topic.id || slug(topic.name || 'topic'));
  const words = Array.isArray(topic.words)
    ? topic.words.map((item) => {
        const nextWord = word(
          item.word,
          item.pinyin,
          item.meaning,
          item.imagePath || item.imageUrl || item.image || '',
          item.query || '',
          item.examples || [],
        );
        nextWord.imagePath = item.imagePath || item.imageUrl || '';
        nextWord.imageUrl = item.imageUrl || item.imagePath || '';
        return nextWord;
      })
    : [];
  const firstImage = wordImageInputValue(words.find((item) => wordImageInputValue(item)));
  const topicImage = String(topic.imageUrl || topic.imagePath || '').trim();
  return {
    id,
    name: String(topic.name || id),
    level: topic.level || levelForTopic(id),
    status: topic.status || 'published',
    imagePath: imagePathForContent(topicImage || firstImage, id),
    imageUrl: imagePathForContent(topicImage, id),
    words,
  };
}

function levelForTopic(id) {
  const hsk1 = ['animals', 'body', 'colors', 'family', 'food', 'greeting', 'home', 'weather'];
  const hsk2 = ['clothes', 'daily_life', 'health', 'nature', 'places', 'school', 'shopping', 'transport'];
  const hsk3 = ['city_life', 'entertainment', 'sports'];
  if (hsk1.includes(id)) return 'HSK 1';
  if (hsk2.includes(id)) return 'HSK 2';
  if (hsk3.includes(id)) return 'HSK 3';
  if (id === 'media_society') return 'HSK 4';
  return 'HSK 2';
}

function topicToFlashcardIndex(topic) {
  const imageUrl = imagePathForContent(topicImageUrl(topic), topic.id);
  return {
    id: topic.id,
    name: topic.name,
    level: topic.level,
    status: topic.status,
    imagePath: imageUrl,
    imageUrl,
    words: topic.words.map((item) => ({
      word: item.word,
      pinyin: item.pinyin,
      meaning: item.meaning,
      image: wordImageFileForExport(item) || topicImageName(topic),
      imagePath: wordImagePathForPublish(item, topic.id),
      imageUrl: wordImagePathForPublish(item, topic.id),
      query: item.query || `${item.meaning} ${item.word}`.trim(),
      examples: item.examples || [],
    })),
  };
}

function mergeReviewIssues(current, issues) {
  const existing = new Set(current.map((item) => `${item.area}|${item.title}|${item.issue}`));
  const next = [...current];
  issues.forEach((item) => {
    const key = `${item.area}|${item.title}|${item.issue}`;
    if (!existing.has(key)) next.push(item);
  });
  return next;
}

function metricGrid(items) {
  return el('div', { class: 'metric-grid' }, items.map(([label, value, hint]) => el('div', { class: 'metric' }, [
    el('span', {}, label),
    el('strong', {}, formatMetricValue(value)),
    el('small', {}, hint),
  ])));
}

function formatMetricValue(value) {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return new Intl.NumberFormat('vi-VN').format(value);
  }
  return String(value);
}

function toolbar(title, controls) {
  return el('div', { class: 'toolbar' }, [
    el('div', {}, [el('h2', {}, title)]),
    el('div', { class: 'toolbar-group' }, controls),
  ]);
}

function panel(title, content) {
  return el('section', { class: 'panel' }, [el('h2', {}, title), content]);
}

function tablePanel(headers, rows) {
  if (!rows.length) return el('div', { class: 'table-panel' }, [emptyState('Không có dữ liệu phù hợp.')]);
  return el('div', { class: 'table-panel' }, [
    el('table', {}, [
      el('thead', {}, [el('tr', {}, headers.map((head) => el('th', {}, head)))]),
      el('tbody', {}, rows.map((row) => el('tr', {}, row.map((cell, index) => {
        const node = el('td', { 'data-label': headers[index] || '' });
        append(node, cell);
        return node;
      })))),
    ]),
  ]);
}

function rowActions(actions) {
  return el('span', { class: 'row-actions' }, actions.map(([label, handler]) => button(label, 'ghost-button', handler)));
}

function button(label, className, onClick) {
  const node = el('button', { class: className, type: 'button' }, label);
  node.addEventListener('click', onClick);
  return node;
}

function select(options, selected, onChange) {
  const node = el('select', { class: 'filter-select' }, options.map((option) => el('option', { value: option }, option)));
  node.value = selected;
  if (onChange) node.addEventListener('change', () => onChange(node.value));
  return node;
}

function status(value) {
  return el('span', { class: `status ${String(value).toLowerCase()}` }, value);
}

function strongText(text) {
  return el('strong', {}, text);
}

function emptyState(message) {
  return el('div', { class: 'empty' }, message);
}

function settingHint(key) {
  return {
    apiBaseUrl: 'Endpoint backend NestJS mà admin sẽ gọi khi bật đồng bộ online.',
    contentVersion: 'Phiên bản gắn vào bundle export để mobile/backend kiểm soát cập nhật.',
    reviewerPolicy: 'Quy tắc duyệt nội dung trước khi publish.',
    exportTarget: 'Gợi ý nơi đặt bundle sau khi export.',
    mobileAssetRoot: 'Đường dẫn tương đối từ apps/admin/index.html tới thư mục assets của mobile.',
  }[key] || '';
}

function parseWords(text) {
  return String(text || '')
    .split(/\n+/)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [
        hanzi = '',
        pinyin = '',
        meaning = '',
        image = '',
        exampleCn = '',
        examplePy = '',
        exampleVi = '',
      ] = line.split('|').map((part) => part.trim());
      const examples = exampleCn && exampleVi
        ? [{ cn: exampleCn, py: examplePy, vi: exampleVi }]
        : [];
      return word(hanzi, pinyin, meaning, image, '', examples);
    });
}

function word(wordValue, pinyin = '', meaning = '', image = '', query = '', examples = []) {
  return {
    word: String(wordValue || ''),
    pinyin: String(pinyin || ''),
    meaning: String(meaning || ''),
    image,
    query,
    examples: Array.isArray(examples) ? examples : [],
  };
}

function reviewIssue(area, title, issue, severity) {
  return { id: uid(), area, title, issue, severity };
}

function matchesQuery(values) {
  if (!globalQuery) return true;
  return values.join(' ').toLowerCase().includes(globalQuery);
}

function inferLevelFromText(text) {
  const match = String(text || '').match(/HSK\s*\d(?:\s*-\s*\d)?/i);
  return match ? match[0].replace(/\s+/g, ' ').toUpperCase() : '';
}

function hskRank(value) {
  const match = String(value || '').match(/HSK\s*(\d+)/i);
  return match ? Number(match[1]) : 99;
}

function hskLevelOptions(items) {
  return unique((items || [])
    .map((item) => (typeof item === 'string' ? item : item?.level))
    .filter(Boolean))
    .sort((a, b) => hskRank(a) - hskRank(b) || String(a).localeCompare(String(b), 'vi'));
}

function looksBroken(text) {
  return /[ÃÄÂ]|ï¿½|�/.test(text);
}

function slug(text) {
  return String(text || 'item')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '') || 'item';
}

function uid() {
  return Math.random().toString(36).slice(2, 10);
}

function dateStamp() {
  return new Date().toISOString().slice(0, 10);
}

function imageFileName(path) {
  const value = String(path || '');
  if (!value || value.startsWith('data:')) return '';
  return value.split(/[\\/]/).pop() || '';
}

function topicImageUrl(topic) {
  return String(topic?.imageUrl || topic?.imagePath || '').trim();
}

function topicImageName(topic) {
  return topic.uploadedImageName || imageFileName(topicImageUrl(topic));
}

function adminImagePreviewSrc(value) {
  const raw = String(value || '').trim();
  if (!raw) return '';
  const mobileAsset = mobileAssetPreviewSrc(raw);
  if (mobileAsset) return mobileAsset;
  if (raw.startsWith('assets/')) return assetPath(raw.replace(/^assets[\\/]+/, ''));
  if (raw.startsWith('/uploads/')) {
    const baseUrl = normalizeApiBaseUrl(state.settings?.apiBaseUrl);
    return baseUrl === '/api' ? raw : `${baseUrl}${raw}`;
  }
  return raw;
}

function wordImageInputValue(item) {
  return String(item?.imageUrl || item?.imagePath || item?.image || '').trim();
}

function isResolvedImagePath(value) {
  const raw = String(value || '').trim();
  return /^(https?:)?\/\//i.test(raw)
    || raw.startsWith('/uploads/')
    || raw.startsWith('/mobile/assets/')
    || raw.startsWith('mobile/assets/')
    || raw.startsWith('apps/mobile/assets/')
    || raw.startsWith('data:')
    || raw.startsWith('../')
    || raw.startsWith('./')
    || raw.startsWith('assets/');
}

function wordImagePreviewSrc(value, topicId = '') {
  const raw = String(value || '').trim();
  if (!raw) return '';
  const mobileAsset = mobileAssetPreviewSrc(raw);
  if (mobileAsset) return mobileAsset;
  if (raw.startsWith('assets/')) return assetPath(raw.replace(/^assets[\\/]+/, ''));
  if (raw.startsWith('/uploads/')) {
    const baseUrl = normalizeApiBaseUrl(state.settings?.apiBaseUrl);
    return baseUrl === '/api' ? raw : `${baseUrl}${raw}`;
  }
  if (isResolvedImagePath(raw)) return raw;
  return topicId ? assetPath(`images/flashcards/${topicId}/${raw}`) : raw;
}

function wordImagePathForPublish(item, topicId = '') {
  const raw = wordImageInputValue(item);
  return imagePathForContent(raw, topicId);
}

function wordImageFileForExport(item) {
  const raw = wordImageInputValue(item);
  if (!raw) return '';
  return isResolvedImagePath(raw) ? imageFileName(raw) : raw;
}

function assetPath(path) {
  const root = String(state.settings?.mobileAssetRoot || '../mobile/assets').replace(/[\\/]+$/, '');
  return `${root}/${String(path || '').replace(/^[\\/]+/, '')}`;
}

function mobileAssetPreviewSrc(value) {
  const raw = String(value || '').trim().replace(/\\/g, '/');
  const patterns = [
    /^\/mobile\/assets\//,
    /^mobile\/assets\//,
    /^\.\.\/mobile\/assets\//,
    /^\.\/mobile\/assets\//,
    /^apps\/mobile\/assets\//,
    /^\.\/apps\/mobile\/assets\//,
  ];
  for (const pattern of patterns) {
    if (pattern.test(raw)) {
      return `/mobile/assets/${raw.replace(pattern, '')}`;
    }
  }
  return '';
}

function imagePathForContent(value, topicId = '') {
  const raw = String(value || '').trim().replace(/\\/g, '/');
  if (!raw) return '';
  if (/^(https?:)?\/\//i.test(raw) || raw.startsWith('/uploads/') || raw.startsWith('data:')) return raw;
  const mobileAsset = mobileAssetPreviewSrc(raw);
  if (mobileAsset) return `assets/${mobileAsset.replace(/^\/mobile\/assets\//, '')}`;
  if (raw.startsWith('assets/')) return raw;
  if (raw.startsWith('../') || raw.startsWith('./')) return raw;
  return topicId ? `assets/images/flashcards/${topicId}/${raw}` : raw;
}

function sanitizeFileName(name) {
  const cleaned = String(name || 'flashcard-image.jpg')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z0-9._-]+/g, '-')
    .replace(/^-+|-+$/g, '');
  return cleaned || 'flashcard-image.jpg';
}

function loadState() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    return saved ? normalizeState(JSON.parse(saved)) : structuredClone(seedState);
  } catch (_) {
    return structuredClone(seedState);
  }
}

function normalizeState(next) {
  const source = next && typeof next === 'object' ? next : {};
  const settings = { ...seedState.settings, ...(source.settings || {}) };
  settings.apiBaseUrl = normalizeApiBaseUrl(settings.apiBaseUrl);
  const lessons = Array.isArray(source.lessons) ? source.lessons : seedState.lessons;
  return {
    ...structuredClone(seedState),
    ...source,
    settings,
    vocabulary: Array.isArray(source.vocabulary) ? source.vocabulary : seedState.vocabulary,
    flashcards: Array.isArray(source.flashcards) ? source.flashcards : seedState.flashcards,
    pronunciation: Array.isArray(source.pronunciation) ? source.pronunciation : seedState.pronunciation,
    lessons: mergeSeedVideoLessons(lessons),
    grammar: Array.isArray(source.grammar) ? source.grammar : seedState.grammar,
    readingSources: Array.isArray(source.readingSources) ? source.readingSources : seedState.readingSources,
    articles: mergeSeedArticles(source.articles),
    games: Array.isArray(source.games) ? source.games : seedState.games,
    aiSettings: { ...seedState.aiSettings, ...(source.aiSettings || {}) },
    users: Array.isArray(source.users) ? source.users : seedState.users,
    review: Array.isArray(source.review) ? source.review : seedState.review,
    reviewDismissed: Array.isArray(source.reviewDismissed) ? source.reviewDismissed : [],
    auditLogs: Array.isArray(source.auditLogs) ? source.auditLogs : [],
    dashboard: source.dashboard || null,
  };
}

function mergeSeedVideoLessons(lessons) {
  const next = Array.isArray(lessons) ? [...lessons] : [];
  const known = new Set(next.map((lesson) => `${lesson.id || ''}|${lesson.youtubeId || ''}`));
  for (const seed of seedState.lessons.filter((lesson) => lesson.type === 'Video' && lesson.youtubeId)) {
    const key = `${seed.id || ''}|${seed.youtubeId || ''}`;
    if (!known.has(key) && !next.some((lesson) => lesson.youtubeId === seed.youtubeId)) {
      next.push(structuredClone(seed));
    }
  }
  return next;
}

function mergeSeedArticles(articles) {
  const next = Array.isArray(articles) ? [...articles] : [];
  const known = new Set(next.map((article) => String(article.id || '')));
  for (const seed of [...foundationReadingArticles, ...seedState.articles]) {
    if (!known.has(seed.id)) next.push(structuredClone(seed));
  }
  return next;
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function downloadJson(filename, data) {
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  link.click();
  URL.revokeObjectURL(url);
  showToast(`Đã xuất ${filename}.`);
}

function showToast(message) {
  toast.textContent = message;
  toast.classList.add('is-visible');
  clearTimeout(showToast.timer);
  showToast.timer = setTimeout(() => toast.classList.remove('is-visible'), 2600);
}

function setActiveNav() {
  document.querySelectorAll('.nav-item').forEach((item) => {
    item.classList.toggle('is-active', item.dataset.view === activeView);
  });
}

function el(tag, attrs = {}, children = []) {
  const node = document.createElement(tag);
  Object.entries(attrs).forEach(([key, value]) => {
    if (key === 'class') node.className = value;
    else if (key === 'value') node.value = value;
    else node.setAttribute(key, value);
  });
  append(node, children);
  return node;
}

function append(node, children) {
  const list = Array.isArray(children) ? children : [children];
  list.filter((child) => child !== null && child !== undefined).forEach((child) => {
    if (child instanceof Node) node.appendChild(child);
    else node.appendChild(document.createTextNode(String(child)));
  });
}

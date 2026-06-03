-- ====================================================
-- SEED DATA - Chinese Learning App (Magic Chinese)
-- ====================================================

-- =====================
-- 1. VOCABULARIES (HSK 1 - HSK 3)
-- =====================
INSERT INTO vocabularies (simplified, traditional, pinyin, meaning_vi, meaning_en, hsk_level, examples, stroke_count)
VALUES

-- HSK 1 - Ăn uống (Food & Drink)
('苹果', '蘋果', 'píng guǒ', 'quả táo', 'apple', 1, '[{"cn":"我喜欢吃苹果。","py":"Wǒ xǐhuān chī píngguǒ.","vi":"Tôi thích ăn táo."}]', 11),
('水', '水', 'shuǐ', 'nước', 'water', 1, '[{"cn":"我要喝水。","py":"Wǒ yào hē shuǐ.","vi":"Tôi muốn uống nước."}]', 4),
('米饭', '米飯', 'mǐ fàn', 'cơm', 'rice', 1, '[{"cn":"我喜欢吃米饭。","py":"Wǒ xǐhuān chī mǐfàn.","vi":"Tôi thích ăn cơm."}]', 8),
('茶', '茶', 'chá', 'trà', 'tea', 1, '[{"cn":"你喝茶吗？","py":"Nǐ hē chá ma?","vi":"Bạn có uống trà không?"}]', 9),
('面条', '麵條', 'miàn tiáo', 'mì, bún', 'noodles', 1, '[{"cn":"我想吃面条。","py":"Wǒ xiǎng chī miàntiáo.","vi":"Tôi muốn ăn mì."}]', 13),

-- HSK 1 - Thú cưng (Pets & Animals)
('猫', '貓', 'māo', 'con mèo', 'cat', 1, '[{"cn":"我有一只猫。","py":"Wǒ yǒu yī zhī māo.","vi":"Tôi có một con mèo."}]', 11),
('狗', '狗', 'gǒu', 'con chó', 'dog', 1, '[{"cn":"那只狗很可爱。","py":"Nà zhī gǒu hěn kěài.","vi":"Con chó đó rất dễ thương."}]', 8),
('鱼', '魚', 'yú', 'con cá', 'fish', 1, '[{"cn":"我喜欢吃鱼。","py":"Wǒ xǐhuān chī yú.","vi":"Tôi thích ăn cá."}]', 8),
('鸟', '鳥', 'niǎo', 'con chim', 'bird', 2, '[{"cn":"树上有很多鸟。","py":"Shù shàng yǒu hěn duō niǎo.","vi":"Trên cây có nhiều chim."}]', 5),

-- HSK 1 - Gia đình (Family)
('爸爸', '爸爸', 'bà ba', 'bố, ba', 'father', 1, '[{"cn":"我爸爸是老师。","py":"Wǒ bàba shì lǎoshī.","vi":"Ba tôi là giáo viên."}]', 8),
('妈妈', '媽媽', 'mā ma', 'mẹ, má', 'mother', 1, '[{"cn":"我妈妈很善良。","py":"Wǒ māma hěn shànliáng.","vi":"Mẹ tôi rất tốt bụng."}]', 12),
('哥哥', '哥哥', 'gē ge', 'anh trai', 'older brother', 1, '[{"cn":"我哥哥在上海工作。","py":"Wǒ gēge zài Shànghǎi gōngzuò.","vi":"Anh tôi làm việc ở Thượng Hải."}]', 10),
('妹妹', '妹妹', 'mèi mei', 'em gái', 'younger sister', 1, '[{"cn":"我妹妹今年五岁。","py":"Wǒ mèimei jīnnián wǔ suì.","vi":"Em gái tôi năm nay 5 tuổi."}]', 16),

-- HSK 1 - Học tập (Study)
('学习', '學習', 'xué xí', 'học tập', 'to study / learning', 1, '[{"cn":"我每天学习中文。","py":"Wǒ měitiān xuéxí Zhōngwén.","vi":"Tôi học tiếng Trung mỗi ngày."},{"cn":"学习很重要。","py":"Xuéxí hěn zhòngyào.","vi":"Học tập rất quan trọng."}]', 8),
('老师', '老師', 'lǎo shī', 'giáo viên, thầy/cô', 'teacher', 1, '[{"cn":"我的老师很好。","py":"Wǒde lǎoshī hěn hǎo.","vi":"Thầy giáo của tôi rất tốt."}]', 9),
('学生', '學生', 'xué shēng', 'học sinh, sinh viên', 'student', 1, '[{"cn":"他是一个好学生。","py":"Tā shì yīgè hǎo xuéshēng.","vi":"Anh ấy là một học sinh giỏi."}]', 13),
('书', '書', 'shū', 'sách', 'book', 1, '[{"cn":"这本书很有趣。","py":"Zhè běn shū hěn yǒuqù.","vi":"Cuốn sách này rất thú vị."}]', 4),

-- HSK 1 - Màu sắc (Colors)
('红色', '紅色', 'hóng sè', 'màu đỏ', 'red', 1, '[{"cn":"她穿了红色的衣服。","py":"Tā chuān le hóngsè de yīfu.","vi":"Cô ấy mặc áo màu đỏ."}]', 12),
('白色', '白色', 'bái sè', 'màu trắng', 'white', 1, '[{"cn":"这件衣服是白色的。","py":"Zhè jiàn yīfu shì báisè de.","vi":"Chiếc áo này màu trắng."}]', 11),
('黑色', '黑色', 'hēi sè', 'màu đen', 'black', 1, '[{"cn":"我喜欢黑色。","py":"Wǒ xǐhuān hēisè.","vi":"Tôi thích màu đen."}]', 12),

-- HSK 1 - Số đếm (Numbers)
('一', '一', 'yī', 'một', 'one', 1, '[{"cn":"我有一个苹果。","py":"Wǒ yǒu yīgè píngguǒ.","vi":"Tôi có một quả táo."}]', 1),
('二', '二', 'èr', 'hai', 'two', 1, '[{"cn":"我有两个妹妹。","py":"Wǒ yǒu liǎng gè mèimei.","vi":"Tôi có hai em gái."}]', 2),
('三', '三', 'sān', 'ba', 'three', 1, '[{"cn":"三个苹果。","py":"Sān gè píngguǒ.","vi":"Ba quả táo."}]', 3),
('十', '十', 'shí', 'mười', 'ten', 1, '[{"cn":"十个学生。","py":"Shí gè xuéshēng.","vi":"Mười học sinh."}]', 2),

-- HSK 1 - Cảm ơn & Chào hỏi (Greetings)
('你好', '你好', 'nǐ hǎo', 'xin chào', 'hello', 1, '[{"cn":"你好，我叫小明。","py":"Nǐ hǎo, wǒ jiào Xiǎomíng.","vi":"Xin chào, tôi tên là Tiểu Minh."}]', 9),
('谢谢', '謝謝', 'xiè xie', 'cảm ơn', 'thank you', 1, '[{"cn":"谢谢你的帮助。","py":"Xièxiè nǐ de bāngzhù.","vi":"Cảm ơn bạn đã giúp đỡ."}]', 17),
('对不起', '對不起', 'duì bu qǐ', 'xin lỗi', 'sorry', 1, '[{"cn":"对不起，我来晚了。","py":"Duìbuqǐ, wǒ lái wǎn le.","vi":"Xin lỗi, tôi đến muộn."}]', 11),
('再见', '再見', 'zài jiàn', 'tạm biệt', 'goodbye', 1, '[{"cn":"再见，明天见！","py":"Zàijiàn, míngtiān jiàn!","vi":"Tạm biệt, hẹn gặp ngày mai!"}]', 9),

-- HSK 2 - Giao thông (Transportation)
('汽车', '汽車', 'qì chē', 'xe ô tô', 'car', 2, '[{"cn":"他有一辆汽车。","py":"Tā yǒu yī liàng qìchē.","vi":"Anh ấy có một chiếc ô tô."}]', 13),
('公共汽车', '公共汽車', 'gōng gòng qì chē', 'xe buýt', 'bus', 2, '[{"cn":"我坐公共汽车上班。","py":"Wǒ zuò gōnggòng qìchē shàngbān.","vi":"Tôi đi xe buýt đến chỗ làm."}]', 21),
('飞机', '飛機', 'fēi jī', 'máy bay', 'airplane', 2, '[{"cn":"我们坐飞机去北京。","py":"Wǒmen zuò fēijī qù Běijīng.","vi":"Chúng tôi đi máy bay tới Bắc Kinh."}]', 12),

-- HSK 2 - Cảm xúc (Emotions)
('高兴', '高興', 'gāo xìng', 'vui mừng', 'happy', 2, '[{"cn":"我今天很高兴。","py":"Wǒ jīntiān hěn gāoxìng.","vi":"Hôm nay tôi rất vui."}]', 12),
('难过', '難過', 'nán guò', 'buồn', 'sad', 2, '[{"cn":"她今天很难过。","py":"Tā jīntiān hěn nánguò.","vi":"Hôm nay cô ấy rất buồn."}]', 9),

-- HSK 3 - Công việc (Work)
('工作', '工作', 'gōng zuò', 'công việc, làm việc', 'work / job', 2, '[{"cn":"你做什么工作？","py":"Nǐ zuò shénme gōngzuò?","vi":"Bạn làm nghề gì?"},{"cn":"他的工作很忙。","py":"Tāde gōngzuò hěn máng.","vi":"Công việc của anh ấy rất bận."}]', 5),
('公司', '公司', 'gōng sī', 'công ty', 'company', 3, '[{"cn":"他在一家大公司工作。","py":"Tā zài yī jiā dà gōngsī gōngzuò.","vi":"Anh ấy làm ở một công ty lớn."}]', 8),
('会议', '會議', 'huì yì', 'cuộc họp', 'meeting', 3, '[{"cn":"下午有一个会议。","py":"Xiàwǔ yǒu yīgè huìyì.","vi":"Buổi chiều có cuộc họp."}]', 13)

ON CONFLICT (simplified) DO NOTHING;

-- =====================
-- 2. GRAMMAR RULES
-- =====================
INSERT INTO grammar (level, title, explanation, examples)
VALUES

('HSK 1', '"是" để xác nhận danh tính',
'Cấu trúc: Chủ ngữ + 是 (shì) + Bổ ngữ
Dùng để xác nhận danh tính, nghề nghiệp hoặc quốc tịch. Phủ định dùng "不是".',
'我是学生。(Wǒ shì xuéshēng.) - Tôi là học sinh.
他不是老师。(Tā bù shì lǎoshī.) - Anh ấy không phải là giáo viên.
她是中国人吗？(Tā shì Zhōngguó rén ma?) - Cô ấy có phải người Trung Quốc không?'),

('HSK 1', '"有" để diễn tả sở hữu',
'Cấu trúc: Chủ ngữ + 有 (yǒu) + Tân ngữ
Dùng để diễn tả sở hữu (có) hoặc sự tồn tại. Phủ định dùng "没有".',
'我有一本书。(Wǒ yǒu yī běn shū.) - Tôi có một quyển sách.
他没有钱。(Tā méiyǒu qián.) - Anh ấy không có tiền.
你有手机吗？(Nǐ yǒu shǒujī ma?) - Bạn có điện thoại không?'),

('HSK 1', 'Câu nghi vấn với "吗"',
'Thêm 吗 (ma) vào cuối câu khẳng định để tạo câu hỏi Yes/No.
Không cần thay đổi trật tự từ trong câu.',
'你喜欢中文吗？(Nǐ xǐhuān Zhōngwén ma?) - Bạn có thích tiếng Trung không?
他是老师吗？(Tā shì lǎoshī ma?) - Anh ấy có phải giáo viên không?'),

('HSK 1', 'Phủ định với "不" và "没"',
'不 (bù) dùng để phủ định động từ hoặc tính từ
没 / 没有 (méi / méiyǒu) dùng để phủ định 有 hoặc hành động đã xảy ra',
'我不喜欢吃苹果。(Wǒ bù xǐhuān chī píngguǒ.) - Tôi không thích ăn táo.
我没有书。(Wǒ méiyǒu shū.) - Tôi không có sách.
他没去学校。(Tā méi qù xuéxiào.) - Anh ấy đã không đến trường.'),

('HSK 2', '"在" để chỉ vị trí',
'Cấu trúc: Chủ ngữ + 在 (zài) + Địa điểm
Dùng để diễn tả vị trí của người hoặc vật.',
'我在家。(Wǒ zài jiā.) - Tôi ở nhà.
书在桌子上。(Shū zài zhuōzi shàng.) - Sách ở trên bàn.
他在哪里？(Tā zài nǎlǐ?) - Anh ấy ở đâu?'),

('HSK 2', 'Câu so sánh với "比"',
'Cấu trúc: A + 比 (bǐ) + B + Tính từ
Dùng để so sánh hai đối tượng.',
'他比我高。(Tā bǐ wǒ gāo.) - Anh ấy cao hơn tôi.
今天比昨天热。(Jīntiān bǐ zuótiān rè.) - Hôm nay nóng hơn hôm qua.
北京比上海冷。(Běijīng bǐ Shànghǎi lěng.) - Bắc Kinh lạnh hơn Thượng Hải.'),

('HSK 2', 'Động từ mục đích với "để + 去/来"',
'Cấu trúc: 去/来 + Địa điểm + 动词
Ghép 来 (lái - đến) hoặc 去 (qù - đi) với mục đích hành động.',
'我去超市买东西。(Wǒ qù chāoshì mǎi dōngxi.) - Tôi đi siêu thị mua đồ.
她来这里学中文。(Tā lái zhèlǐ xué Zhōngwén.) - Cô ấy đến đây học tiếng Trung.'),

('HSK 3', '"把" cấu trúc xử lý đối tượng',
'Cấu trúc: Chủ ngữ + 把 (bǎ) + Tân ngữ + Động từ + Bổ sung
Dùng khi muốn nhấn mạnh tác động lên đối tượng.',
'他把书放在桌子上。(Tā bǎ shū fàng zài zhuōzi shàng.) - Anh ấy đặt sách lên bàn.
我把作业做完了。(Wǒ bǎ zuòyè zuò wán le.) - Tôi đã làm xong bài tập.'),

('HSK 3', '"被" câu bị động',
'Cấu trúc: Chủ ngữ + 被 (bèi) + Chủ thể hành động + Động từ
Dùng khi chủ ngữ là người bị tác động.',
'苹果被他吃了。(Píngguǒ bèi tā chī le.) - Táo đã bị anh ấy ăn rồi.
作业被老师检查了。(Zuòyè bèi lǎoshī jiǎnchá le.) - Bài tập đã bị giáo viên kiểm tra.');


-- =====================
-- 3. ARTICLES (Reading)
-- =====================
INSERT INTO articles (title, title_vi, content, source, link, hsk_level, active)
VALUES

('你好，北京！', 'Xin chào, Bắc Kinh!',
'北京是中国的首都。北京有很多好吃的东西。我喜欢北京的烤鸭。北京有很多公园，我每天早上去公园运动。北京的地铁很方便，你可以去很多地方。你来过北京吗？',
'Magic Chinese', NULL, 'HSK 1', true),

('我的家人', 'Gia đình của tôi',
'我有一个大家庭。爸爸是医生，妈妈是老师。我有一个哥哥和一个妹妹。哥哥在上海工作，妹妹还在上小学。我们全家人每年过年的时候都回奶奶家。我很爱我的家人。',
'Magic Chinese', NULL, 'HSK 1', true),

('每天的生活', 'Cuộc sống hàng ngày',
'我每天七点起床。早上我喝一杯牛奶，吃一片面包。八点坐地铁去学校。在学校，我学习中文、数学和英文。下午三点半放学，我骑自行车回家。晚上我做作业，然后看电视。十点睡觉。你的每天是什么样子的？',
'Magic Chinese', NULL, 'HSK 1', true),

('中国的传统节日', 'Lễ tết truyền thống của Trung Quốc',
'中国有很多传统节日。春节是最重要的节日，通常在一月或二月。春节的时候，家人聚在一起吃饭，孩子们可以收到红包。中秋节在农历八月十五，人们会赏月、吃月饼。端午节的时候，人们吃粽子、赛龙舟。这些节日让中国文化更丰富。',
'Magic Chinese', NULL, 'HSK 2', true),

('学中文的好处', 'Lợi ích của việc học tiếng Trung',
'现在越来越多的人开始学习中文。为什么？因为中国经济发展很快，中文变得越来越重要。会说中文可以帮助你找到更好的工作机会。另外，学中文还可以了解中国文化，比如中国的历史、饮食和艺术。学中文虽然不容易，但是只要努力，就一定能学好。你学中文多长时间了？',
'Magic Chinese', NULL, 'HSK 2', true),

('在超市购物', 'Mua sắm ở siêu thị',
'今天下午，我去超市买东西。我需要买牛奶、面包、苹果和鸡蛋。在超市里，东西很多，价格也不贵。我找了半个小时，终于找到了所有需要的东西。结账的时候，我用手机支付，非常方便。你喜欢在超市买东西还是在网上买？',
'Magic Chinese', NULL, 'HSK 2', true);

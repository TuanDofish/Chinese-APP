-- ======================================================
-- SEED DATA FINAL - VNChinese App
-- Xóa & nạp lại toàn bộ dữ liệu 8 bảng
-- ======================================================

-- Tắt khoá ngoại tạm thời để TRUNCATE an toàn
SET session_replication_role = 'replica';
TRUNCATE TABLE user_progress, quiz_questions, articles, grammar, vocabularies, lessons, course_levels, users RESTART IDENTITY CASCADE;
SET session_replication_role = 'origin';

-- =====================
-- 1. USERS
-- =====================
INSERT INTO users (email, "passwordHash", "displayName", "avatarUrl", role) VALUES
('admin@vnchinese.local',  'scrypt$1a3fb53279c93f8218369b093bea6d5d$5ed28499116662f475bce95765f859a7c0a0ae13e90703539309cb9dc7d419c0c0940351c4e189f37b8117c1dcba0f3d27f358c50e49895dea6ba7ce9bab118e', 'Admin VNChinese', NULL, 'admin'),
('nguyen@vnchinese.local', 'scrypt$93401c06ecc0da8576a15026bcb75084$4fc60d507627c0b3a91e6ac43a392e8bc68ea19be86ad3054c9369d5a7e8aba2bfb3163a58c3b902c117697e2f0923028307cdc149f290d991538bd19dd61d39', 'Nguyễn Văn A', NULL, 'user'),
('linh@vnchinese.local',   'scrypt$93401c06ecc0da8576a15026bcb75084$4fc60d507627c0b3a91e6ac43a392e8bc68ea19be86ad3054c9369d5a7e8aba2bfb3163a58c3b902c117697e2f0923028307cdc149f290d991538bd19dd61d39', 'Trần Thị Linh', NULL, 'user');

-- =====================
-- 2. COURSE LEVELS
-- =====================
INSERT INTO course_levels (name, description, "totalLessons") VALUES
('HSK 1', 'Cơ bản - Từ vựng nhập môn tiếng Trung', 5),
('HSK 2', 'Sơ cấp - Giao tiếp hàng ngày cơ bản', 4),
('HSK 3', 'Sơ trung cấp - Học tập và công việc', 3);

-- =====================
-- 3. LESSONS
-- =====================
INSERT INTO lessons ("courseLevelId", title, description, order_index) VALUES
-- HSK 1
(1, 'Ăn uống (Food & Drink)',       'Từ vựng về đồ ăn, thức uống hàng ngày', 1),
(1, 'Thú cưng (Pets & Animals)',    'Tên các loài động vật quen thuộc', 2),
(1, 'Gia đình (Family)',            'Cách gọi các thành viên trong gia đình', 3),
(1, 'Học tập (Studying)',           'Trường học, sách vở, thầy cô', 4),
(1, 'Màu sắc & Số đếm',            'Màu cơ bản và số từ 0-10', 5),
-- HSK 2
(2, 'Giao thông (Transportation)',  'Các phương tiện di chuyển', 1),
(2, 'Cảm xúc (Emotions)',          'Diễn tả vui buồn, sức khoẻ', 2),
(2, 'Mua sắm (Shopping)',          'Từ vựng tại siêu thị và cửa hàng', 3),
-- HSK 3
(3, 'Công việc (Work)',             'Văn phòng, công ty, ngành nghề', 1),
(3, 'Du lịch (Travel)',             'Địa điểm, khách sạn, sân bay', 2);

-- =====================
-- 4. VOCABULARIES (dùng currval để lấy lesson_id vừa tạo)
-- =====================
INSERT INTO vocabularies ("lessonId", simplified, traditional, pinyin, meaning_vi, meaning_en, hsk_level, stroke_count, examples) VALUES
-- Lesson 1: Ăn uống
(1, '苹果', '蘋果', 'píng guǒ',  'quả táo',       'apple',    1, 11, '[{"cn":"我喜欢吃苹果。","py":"Wǒ xǐhuān chī píngguǒ.","vi":"Tôi thích ăn táo."}]'),
(1, '水',   '水',   'shuǐ',      'nước',           'water',    1,  4, '[{"cn":"我要喝水。","py":"Wǒ yào hē shuǐ.","vi":"Tôi muốn uống nước."}]'),
(1, '米饭', '米飯', 'mǐ fàn',   'cơm',            'rice',     1,  8, '[{"cn":"我喜欢吃米饭。","py":"Wǒ xǐhuān chī mǐfàn.","vi":"Tôi thích ăn cơm."}]'),
(1, '茶',   '茶',   'chá',       'trà',            'tea',      1,  9, '[{"cn":"你喝茶吗？","py":"Nǐ hē chá ma?","vi":"Bạn có uống trà không?"}]'),
(1, '面条', '麵條', 'miàn tiáo', 'mì sợi',        'noodles',  1, 13, '[{"cn":"我想吃面条。","py":"Wǒ xiǎng chī miàntiáo.","vi":"Tôi muốn ăn mì."}]'),

-- Lesson 2: Thú cưng
(2, '猫',   '貓',  'māo',       'con mèo',        'cat',      1, 11, '[{"cn":"我有一只猫。","py":"Wǒ yǒu yī zhī māo.","vi":"Tôi có một con mèo."}]'),
(2, '狗',   '狗',  'gǒu',       'con chó',        'dog',      1,  8, '[{"cn":"那只狗很可爱。","py":"Nà zhī gǒu hěn kěài.","vi":"Con chó đó dễ thương."}]'),
(2, '鱼',   '魚',  'yú',        'con cá',         'fish',     1,  8, '[{"cn":"我喜欢吃鱼。","py":"Wǒ xǐhuān chī yú.","vi":"Tôi thích ăn cá."}]'),
(2, '鸟',   '鳥',  'niǎo',      'con chim',       'bird',     2,  5, '[{"cn":"树上有很多鸟。","py":"Shù shàng yǒu hěn duō niǎo.","vi":"Trên cây có nhiều chim."}]'),

-- Lesson 3: Gia đình
(3, '爸爸', '爸爸', 'bà ba',    'bố, ba',         'father',   1,  8, '[{"cn":"我爸爸是老师。","py":"Wǒ bàba shì lǎoshī.","vi":"Ba tôi là giáo viên."}]'),
(3, '妈妈', '媽媽', 'mā ma',    'mẹ, má',         'mother',   1, 12, '[{"cn":"我妈妈很善良。","py":"Wǒ māma hěn shànliáng.","vi":"Mẹ tôi rất tốt bụng."}]'),
(3, '哥哥', '哥哥', 'gē ge',    'anh trai',       'older brother', 1, 10, '[{"cn":"我哥哥在上海工作。","py":"Wǒ gēge zài Shànghǎi gōngzuò.","vi":"Anh tôi làm ở Thượng Hải."}]'),
(3, '妹妹', '妹妹', 'mèi mei',  'em gái',         'younger sister', 1, 16, '[{"cn":"我妹妹今年五岁。","py":"Wǒ mèimei jīnnián wǔ suì.","vi":"Em gái tôi năm nay 5 tuổi."}]'),

-- Lesson 4: Học tập
(4, '学习', '學習', 'xué xí',   'học tập',        'to study', 1,  8, '[{"cn":"我每天学习中文。","py":"Wǒ měitiān xuéxí Zhōngwén.","vi":"Tôi học tiếng Trung mỗi ngày."}]'),
(4, '老师', '老師', 'lǎo shī',  'giáo viên',      'teacher',  1,  9, '[{"cn":"我的老师很好。","py":"Wǒde lǎoshī hěn hǎo.","vi":"Thầy tôi rất tốt."}]'),
(4, '学生', '學生', 'xué shēng','học sinh',       'student',  1, 13, '[{"cn":"他是好学生。","py":"Tā shì hǎo xuéshēng.","vi":"Anh ấy là học sinh giỏi."}]'),
(4, '书',   '書',   'shū',      'sách',           'book',     1,  4, '[{"cn":"这本书很有趣。","py":"Zhè běn shū hěn yǒuqù.","vi":"Cuốn sách này rất thú vị."}]'),

-- Lesson 5: Màu sắc & Số
(5, '红色', '紅色', 'hóng sè', 'màu đỏ',          'red',      1, 12, '[{"cn":"她穿红色衣服。","py":"Tā chuān hóngsè yīfu.","vi":"Cô ấy mặc áo đỏ."}]'),
(5, '白色', '白色', 'bái sè',  'màu trắng',       'white',    1, 11, '[{"cn":"这件是白色的。","py":"Zhè jiàn shì báisè de.","vi":"Cái này màu trắng."}]'),
(5, '一',   '一',   'yī',      'một',             'one',      1,  1, '[{"cn":"我有一个苹果。","py":"Wǒ yǒu yīgè píngguǒ.","vi":"Tôi có một quả táo."}]'),
(5, '二',   '二',   'èr',      'hai',             'two',      1,  2, '[{"cn":"我有两个妹妹。","py":"Wǒ yǒu liǎng gè mèimei.","vi":"Tôi có hai em gái."}]'),
(5, '十',   '十',   'shí',     'mười',            'ten',      1,  2, '[{"cn":"十个学生。","py":"Shí gè xuéshēng.","vi":"Mười học sinh."}]'),

-- Lesson 6: Giao thông (HSK 2)
(6, '汽车', '汽車', 'qì chē',  'xe ô tô',         'car',      2, 13, '[{"cn":"他有一辆汽车。","py":"Tā yǒu yīliàng qìchē.","vi":"Anh ấy có một ô tô."}]'),
(6, '飞机', '飛機', 'fēi jī',  'máy bay',         'airplane', 2, 12, '[{"cn":"我们坐飞机去北京。","py":"Wǒmen zuò fēijī qù Běijīng.","vi":"Chúng tôi bay tới Bắc Kinh."}]'),
(6, '地铁', '地鐵', 'dì tiě',  'tàu điện ngầm',  'subway',   2, 13, '[{"cn":"我坐地铁上班。","py":"Wǒ zuò dìtiě shàngbān.","vi":"Tôi đi tàu điện ngầm đi làm."}]'),

-- Lesson 7: Cảm xúc (HSK 2)
(7, '高兴', '高興', 'gāo xìng','vui mừng',        'happy',    2, 12, '[{"cn":"我今天很高兴。","py":"Wǒ jīntiān hěn gāoxìng.","vi":"Hôm nay tôi rất vui."}]'),
(7, '难过', '難過', 'nán guò', 'buồn',            'sad',      2,  9, '[{"cn":"她今天很难过。","py":"Tā jīntiān hěn nánguò.","vi":"Hôm nay cô ấy rất buồn."}]'),

-- Lesson 9: Công việc (HSK 3)
(9, '工作', '工作', 'gōng zuò','công việc',       'work/job', 2,  5, '[{"cn":"你做什么工作？","py":"Nǐ zuò shénme gōngzuò?","vi":"Bạn làm nghề gì?"}]'),
(9, '公司', '公司', 'gōng sī', 'công ty',         'company',  3,  8, '[{"cn":"他在大公司工作。","py":"Tā zài dà gōngsī gōngzuò.","vi":"Anh ấy làm ở công ty lớn."}]');

-- =====================
-- 5. GRAMMAR
-- =====================
INSERT INTO grammar ("lessonId", level, title, explanation, examples) VALUES
(1,  'HSK 1', '喜欢 – Diễn tả sở thích',          'Chủ ngữ + 喜欢 + Động từ/Danh từ. Diễn tả điều mình yêu thích.',                            '我喜欢吃苹果。(Wǒ xǐhuān chī píngguǒ.) - Tôi thích ăn táo.'),
(4,  'HSK 1', '是 – Xác nhận danh tính',           'Chủ ngữ + 是 + Bổ ngữ. Phủ định: 不是.',                                                     '我是学生。(Wǒ shì xuéshēng.) - Tôi là học sinh.'),
(2,  'HSK 1', '有 – Diễn tả sở hữu',               'Chủ ngữ + 有 + Danh từ. Phủ định: 没有.',                                                     '我有一只猫。(Wǒ yǒu yī zhī māo.) - Tôi có một con mèo.'),
(4,  'HSK 1', '吗 – Câu hỏi Yes/No',               'Thêm 吗 vào cuối câu để tạo câu hỏi. Không đảo trật tự từ.',                                  '你是老师吗？(Nǐ shì lǎoshī ma?) - Bạn có phải giáo viên không?'),
(6,  'HSK 2', '坐 – Đi bằng phương tiện',          'Chủ ngữ + 坐 + Phương tiện + 去/来 + Địa điểm.',                                             '我坐飞机去北京。(Wǒ zuò fēijī qù Běijīng.) - Tôi đi máy bay tới Bắc Kinh.'),
(7,  'HSK 2', '比 – So sánh hơn kém',              'A + 比 + B + Tính từ. Dùng để so sánh hai sự vật.',                                           '今天比昨天热。(Jīntiān bǐ zuótiān rè.) - Hôm nay nóng hơn hôm qua.'),
(9,  'HSK 3', '把 – Cấu trúc xử lý đối tương',    'Chủ ngữ + 把 + Tân ngữ + Động từ + Bổ sung. Nhấn mạnh vào đối tượng bị tác động.',          '他把书放在桌上。(Tā bǎ shū fàng zài zhuō shàng.) - Anh ấy đặt sách lên bàn.');

-- =====================
-- 6. QUIZ QUESTIONS
-- =====================
INSERT INTO quiz_questions ("lessonId", "questionType", "questionText", options, "correctAnswer") VALUES
(1, 'mcq',       '"苹果" có nghĩa là gì?',                                        '["Con mèo","Quả táo","Nước","Cơm"]',         'Quả táo'),
(1, 'mcq',       'Từ nào là "Nước" trong tiếng Trung?',                          '["茶","苹果","水","米饭"]',                    '水'),
(2, 'translate', 'Dịch sang Tiếng Việt: 我有一只猫。',                             NULL,                                          'Tôi có một con mèo.'),
(3, 'mcq',       'Chọn chữ Hán phù hợp với nghĩa "Mẹ"?',                        '["爸爸","哥哥","妈妈","妹妹"]',               '妈妈'),
(4, 'mcq',       '"学生" (xuéshēng) nghĩa là gì?',                               '["Giáo viên","Sách","Học sinh","Bài tập"]',   '学sinh'),
(6, 'mcq',       '"飞机" (fēijī) là phương tiện gì?',                             '["Xe ô tô","Tàu điện ngầm","Xe đạp","Máy bay"]','Máy bay'),
(7, 'mcq',       '"高兴" có nghĩa là gì?',                                        '["Buồn","Vui mừng","Tức giận","Sợ hãi"]',    'Vui mừng');

-- =====================
-- 7. ARTICLES
-- =====================
INSERT INTO articles (title, title_vi, content, source, hsk_level, active) VALUES
('你好，北京！', 'Xin chào, Bắc Kinh!',
 '北京是中国的首都。北京有很多好吃的东西。我喜欢北京的烤鸭。北京有很多公园，我每天早上去公园运动。你来过北京吗？',
 'VNChinese', 'HSK 1', true),

('我的家人', 'Gia đình của tôi',
 '我有一个大家庭。爸爸是医生，妈妈是老师。我有一个哥哥和一个妹妹。哥哥在上海工作，妹妹还在上小学。我很爱我的家人。',
 'VNChinese', 'HSK 1', true),

('每天的生活', 'Cuộc sống hàng ngày',
 '我每天七点起床。早上喝一杯牛奶，吃一片面包。八点坐地铁去学校学习中文和英文。下午三点半放学，骑自行车回家。晚上做作业，然后看电视。十点睡觉。',
 'VNChinese', 'HSK 1', true),

('中国的传统节日', 'Lễ tết truyền thống của Trung Quốc',
 '中国有很多传统节日。春节是最重要的节日，通常在一月或二月。春节的时候，家人聚在一起吃饭，孩子们可以收到红包。中秋节在农历八月十五，人们会赏月、吃月饼。',
 'VNChinese', 'HSK 2', true),

('在超市购物', 'Mua sắm ở siêu thị',
 '今天下午，我去超市买东西。我需要买牛奶、面包、苹果和鸡蛋。在超市里，东西很多，价格也不贵。结账的时候，我用手机支付，非常方便。',
 'VNChinese', 'HSK 2', true),

('学中文的好处', 'Lợi ích của việc học tiếng Trung',
 '现在越来越多的人开始学习中文。因为中国经济发展很快，中文变得越来越重要。会说中文可以帮助你找到更好的工作机会。另外，学中文还可以了解中国文化。',
 'VNChinese', 'HSK 3', true);

-- =====================
-- 8. USER PROGRESS
-- =====================
INSERT INTO user_progress ("userId", "lessonId", status, score, "completed_at") VALUES
(2, 1, 'completed',   100, NOW()),
(2, 2, 'completed',    90, NOW()),
(2, 3, 'in_progress',  60, NULL),
(3, 1, 'completed',    85, NOW()),
(3, 2, 'in_progress',  40, NULL);

-- Đồng bộ lại sequences
SELECT setval('users_id_seq',         (SELECT MAX(id) FROM users));
SELECT setval('course_levels_id_seq',  (SELECT MAX(id) FROM course_levels));
SELECT setval('lessons_id_seq',        (SELECT MAX(id) FROM lessons));
SELECT setval('vocabularies_id_seq',   (SELECT MAX(id) FROM vocabularies));
SELECT setval('grammar_id_seq',        (SELECT MAX(id) FROM grammar));
SELECT setval('quiz_questions_id_seq', (SELECT MAX(id) FROM quiz_questions));
SELECT setval('articles_id_seq',       (SELECT MAX(id) FROM articles));
SELECT setval('user_progress_id_seq',  (SELECT MAX(id) FROM user_progress));

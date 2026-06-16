-- ====================================================
-- SEED DATA V8 - VNChinese
-- 8 Tables Structure (No Flashcards/UserQuizResults)
-- ====================================================

-- =====================
-- 1. USERS & ADMINS
-- =====================
INSERT INTO users (email, "passwordHash", "displayName", "avatarUrl", role)
VALUES
('admin@vnchinese.local', 'scrypt$1a3fb53279c93f8218369b093bea6d5d$5ed28499116662f475bce95765f859a7c0a0ae13e90703539309cb9dc7d419c0c0940351c4e189f37b8117c1dcba0f3d27f358c50e49895dea6ba7ce9bab118e', 'Admin VNChinese', NULL, 'admin'),
('student@vnchinese.local', 'scrypt$93401c06ecc0da8576a15026bcb75084$4fc60d507627c0b3a91e6ac43a392e8bc68ea19be86ad3054c9369d5a7e8aba2bfb3163a58c3b902c117697e2f0923028307cdc149f290d991538bd19dd61d39', 'Người học VNChinese', NULL, 'user')
ON CONFLICT DO NOTHING;

-- =====================
-- 2. COURSE LEVELS
-- =====================
INSERT INTO course_levels (id, name, description, "totalLessons")
VALUES
(1, 'HSK 1', 'Cấp độ cơ bản nhất, làm quen với tiếng Trung', 5),
(2, 'HSK 2', 'Giao tiếp hàng ngày ở mức độ cơ bản', 4),
(3, 'HSK 3', 'Phát triển kỹ năng cho công việc và học tập', 3)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- =====================
-- 3. LESSONS
-- =====================
INSERT INTO lessons (id, "courseLevelId", title, description, order_index)
VALUES
-- HSK 1
(1, 1, 'Bài 1: Ăn uống (Food & Drink)', 'Từ vựng về trái cây, nước và các đồ ăn cơ bản.', 1),
(2, 1, 'Bài 2: Thú cưng (Pets)', 'Tên gọi các loài động vật thường gặp.', 2),
(3, 1, 'Bài 3: Gia đình (Family)', 'Cách gọi tên các thành viên trong gia đình.', 3),
(4, 1, 'Bài 4: Học tập (Study)', 'Trường học, từ vựng liên quan đến học hành.', 4),
(5, 1, 'Bài 5: Màu sắc và Đếm số (Colors & Numbers)', 'Các màu cơ bản và số từ 1 đến 10.', 5),

-- HSK 2
(6, 2, 'Bài 1: Giao thông (Transportation)', 'Các loại phương tiện giao thông.', 1),
(7, 2, 'Bài 2: Cảm xúc (Emotions)', 'Cách diễn tả cảm xúc vui buồn.', 2)
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title;

-- =====================
-- 4. VOCABULARIES
-- =====================
INSERT INTO vocabularies (id, "lessonId", simplified, traditional, pinyin, meaning_vi, meaning_en, hsk_level, stroke_count, examples)
VALUES
-- Lesson 1: Food & Drink
(1, 1, '苹果', '蘋果', 'píng guǒ', 'quả táo', 'apple', 1, 11, '[{"cn":"我喜欢吃苹果。","py":"Wǒ xǐhuān chī píngguǒ.","vi":"Tôi thích ăn táo."}]'),
(2, 1, '水', '水', 'shuǐ', 'nước', 'water', 1, 4, '[{"cn":"我要喝水。","py":"Wǒ yào hē shuǐ.","vi":"Tôi muốn uống nước."}]'),

-- Lesson 2: Pets
(3, 2, '猫', '貓', 'māo', 'con mèo', 'cat', 1, 11, '[{"cn":"我有一只猫。","py":"Wǒ yǒu yī zhī māo.","vi":"Tôi có một con mèo."}]'),
(4, 2, '狗', '狗', 'gǒu', 'con chó', 'dog', 1, 8, '[{"cn":"那只狗很可爱。","py":"Nà zhī gǒu hěn kěài.","vi":"Con chó đó rất dễ thương."}]'),

-- Lesson 3: Family
(5, 3, '爸爸', '爸爸', 'bà ba', 'bố, ba', 'father', 1, 8, '[{"cn":"我爸爸是老师。","py":"Wǒ bàba shì lǎoshī.","vi":"Ba tôi là giáo viên."}]'),
(6, 3, '妈妈', '媽媽', 'mā ma', 'mẹ, má', 'mother', 1, 12, '[{"cn":"我妈妈很善良。","py":"Wǒ māma hěn shànliáng.","vi":"Mẹ tôi rất tốt bụng."}]'),

-- Lesson 4: Study
(7, 4, '学习', '學習', 'xué xí', 'học tập', 'to study', 1, 8, '[{"cn":"学习很重要。","py":"Xuéxí hěn zhòngyào.","vi":"Học tập rất quan trọng."}]'),
(8, 4, '学生', '學生', 'xué shēng', 'học sinh', 'student', 1, 13, '[{"cn":"他是一个好学生。","py":"Tā shì yīgè hǎo xuéshēng.","vi":"Anh ấy là một học sinh giỏi."}]'),

-- Lesson 6: Transportation (HSK 2)
(9, 6, '汽车', '汽車', 'qì chē', 'xe ô tô', 'car', 2, 13, '[{"cn":"他有一辆汽车。","py":"Tā yǒu yī liàng qìchē.","vi":"Anh ấy có một chiếc ô tô."}]')
ON CONFLICT (id) DO UPDATE SET simplified = EXCLUDED.simplified;

-- =====================
-- 5. GRAMMAR
-- =====================
INSERT INTO grammar (id, "lessonId", level, title, explanation, examples)
VALUES
(1, 4, 'HSK 1', '"是" để xác nhận danh tính', 'Cấu trúc: Chủ ngữ + 是 (shì) + Bổ ngữ. Phủ định dùng "不是".', '我是学生。(Wǒ shì xuéshēng.) - Tôi là học sinh.'),
(2, 2, 'HSK 1', '"有" để diễn tả sở hữu', 'Cấu trúc: Chủ ngữ + 有 (yǒu) + Tân ngữ.', '我有一本书。(Wǒ yǒu yī běn shū.) - Tôi có một quyển sách.'),
(3, 1, 'HSK 1', 'Động từ chỉ ý thích', 'Cấu trúc Chủ ngữ + 喜欢 (xǐhuan) + Động từ/Tân ngữ.', '我喜欢吃苹果。(Wǒ xǐhuān chī píngguǒ.) - Tôi thích ăn táo.')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title;

-- =====================
-- 6. QUIZ QUESTIONS
-- =====================
INSERT INTO quiz_questions (id, "lessonId", "questionType", "questionText", options, "correctAnswer")
VALUES
(1, 1, 'mcq', 'Từ nào dưới đây có nghĩa là "Quả táo"?', '["水", "面条", "苹果", "茶"]', '苹果'),
(2, 2, 'translate', 'Dịch sang tiếng Trung: "Tôi có một con mèo."', NULL, '我有一只猫。'),
(3, 4, 'mcq', 'Chọn chữ Hán đúng cho Pinyin "xué shēng"?', '["学习", "学生", "老师", "学校"]', '学生')
ON CONFLICT (id) DO UPDATE SET "questionText" = EXCLUDED."questionText";

-- =====================
-- 7. ARTICLES (Reading)
-- =====================
INSERT INTO articles (id, title, title_vi, content, source, hsk_level)
VALUES
(1, '你好，北京！', 'Xin chào, Bắc Kinh!', '北京是中国的首都。北京有很多好吃的东西。', 'VNChinese', 'HSK 1'),
(2, '我的家人', 'Gia đình của tôi', '我有一个大家庭。爸爸是医生，妈妈是老师。', 'VNChinese', 'HSK 1')
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title;

-- =====================
-- 8. USER PROGRESS
-- =====================
INSERT INTO user_progress (id, "userId", "lessonId", status, score, "completed_at")
VALUES
(1, 2, 1, 'completed', 100, NOW()),
(2, 2, 2, 'in_progress', 50, NULL)
ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status;

-- Automatically update Sequences so future inserts don't fail
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
SELECT setval('course_levels_id_seq', (SELECT MAX(id) FROM course_levels));
SELECT setval('lessons_id_seq', (SELECT MAX(id) FROM lessons));
SELECT setval('vocabularies_id_seq', (SELECT MAX(id) FROM vocabularies));
SELECT setval('grammar_id_seq', (SELECT MAX(id) FROM grammar));
SELECT setval('quiz_questions_id_seq', (SELECT MAX(id) FROM quiz_questions));
SELECT setval('articles_id_seq', (SELECT MAX(id) FROM articles));
SELECT setval('user_progress_id_seq', (SELECT MAX(id) FROM user_progress));

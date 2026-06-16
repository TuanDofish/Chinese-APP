# Đặc tả luồng chạy và định hướng build app học tiếng Trung

## 1. Mục tiêu sản phẩm

Ứng dụng giúp người học tiếng Trung luyện từ vựng, flashcard theo chủ đề, tra từ, đọc bài, luyện phát âm, làm quiz, học ngữ pháp và theo dõi tiến độ. Trải nghiệm chính cần nhanh, học được offline với dữ liệu seed, và có thể nâng cấp bằng API/admin khi cần quản lý nội dung tập trung.

## 2. Kiến trúc hiện tại

- Mobile app: Flutter, nằm tại `apps/mobile`.
- Backend API: NestJS, nằm tại `api`, phục vụ tra từ, ngữ pháp, đọc bài và gợi ý ảnh.
- Dữ liệu offline: JSON trong `apps/mobile/assets/data`.
- Ảnh flashcard: `apps/mobile/assets/images/flashcards`, có `index.json` và `metadata.json` theo từng chủ đề.
- Tiến độ người học: lưu cục bộ bằng `shared_preferences` qua `ProgressService`.
- TTS/phát âm: `flutter_tts`, `speech_to_text`.

## 3. Luồng khởi động app

1. Người dùng mở app.
2. Flutter load `main.dart`, dựng màn hình chính và các tab học.
3. Các repository khởi tạo lazy-load, chỉ đọc dữ liệu khi màn hình cần.
4. Khi vào flashcard/từ điển, `DictionaryRepository.ensureLoaded()` nạp:
   - danh sách từ hard-code cơ bản;
   - `dictionary_seed_clean.json`;
   - `dictionary_hsk14_compact.json`;
   - `assets/images/flashcards/index.json` để map ảnh, pinyin và nghĩa theo flashcard.
5. App ưu tiên dữ liệu local để phản hồi nhanh, sau đó mới gọi API khi cần tra từ mở rộng.

## 4. Luồng học flashcard

1. Người dùng chọn tab/bảng chủ đề.
2. `FlashcardRepository.loadTopics()` tạo danh sách chủ đề từ hai nguồn:
   - plan hard-code theo HSK;
   - toàn bộ chủ đề trong `flashcards/index.json`, bỏ qua topic trùng id.
3. Mỗi từ được resolve qua `DictionaryRepository.forFlashcard()`.
4. Thứ tự ưu tiên dữ liệu:
   - metadata flashcard: ảnh, pinyin, nghĩa Việt;
   - từ điển seed local;
   - HSK compact;
   - fallback “Nghĩa tiếng Việt đang cập nhật”.
5. Người dùng bấm thẻ để xem nghĩa/ví dụ, bấm loa để nghe TTS, bấm lưu để thêm vào sổ tay.
6. Tiến độ học được ghi bằng `ProgressService`.

## 5. Luồng tra từ

1. Người dùng nhập Hán tự, pinyin hoặc nghĩa tiếng Việt.
2. App tìm trong index local trước để trả nhanh.
3. Nếu dữ liệu local thiếu nghĩa/ví dụ, app có thể gọi API `/dictionary/search`.
4. Kết quả được làm sạch bằng `TextSanitizer`, chuyển pinyin số sang dấu bằng `PinyinUtils`.
5. Người dùng có thể mở panel chi tiết để xem nghĩa, ví dụ, Hán Việt, loại từ và phát âm.

## 6. Luồng sổ tay

1. Khi học/tra từ, người dùng bấm lưu.
2. `ProgressService.toggleFavorite(word)` cập nhật danh sách từ yêu thích.
3. Màn sổ tay đọc danh sách này, resolve lại dữ liệu bằng `VocabDataHelper`/repository.
4. Người dùng có thể nghe, mở chi tiết hoặc xóa khỏi sổ tay.

## 7. Luồng quiz và luyện tập

1. Quiz lấy danh sách từ theo HSK/chủ đề.
2. App tạo câu hỏi từ nghĩa, pinyin, Hán tự và ví dụ.
3. Khi trả lời, app cập nhật đúng/sai, điểm và số từ đã học.
4. Kết quả được lưu local để màn thống kê tổng hợp.

## 8. Luồng đọc bài và tra từ trong bài

1. App nạp bài đọc từ `reading_hsk.json` hoặc tin seed/live.
2. Bài được tách câu, hiển thị Hán tự, pinyin và dịch.
3. Khi người dùng chạm vào từ trong câu, app lookup local bằng `DictionaryRepository.lookupAt()`.
4. Nếu có dữ liệu, hiện nghĩa nhanh; nếu không, gọi API/fallback.

## 9. Luồng ngữ pháp và AI

1. Bài ngữ pháp lấy từ `grammar_hsk.json`/`grammar_hsk14.json`.
2. Người dùng xem cấu trúc, giải thích, ví dụ.
3. Với grammar checker, app gửi câu lên service AI/API nếu có cấu hình.
4. Kết quả trả về gồm điểm, câu sửa, lỗi và giải thích.

## 10. Hướng build app hoàn chỉnh

- Chuẩn hóa dữ liệu: giữ `dictionary_seed_clean.json`, `flashcards/index.json` là nguồn đúng UTF-8; thêm kiểm tra CI phát hiện mojibake.
- Tối ưu flashcard: mỗi topic 10-20 từ, ảnh riêng cho từng từ, nghĩa Việt đầy đủ, ví dụ ngắn.
- Offline-first: mọi bài HSK 1-4, chủ đề phổ biến, quiz cơ bản phải chạy không cần mạng.
- Online-enhanced: API chỉ dùng cho tra từ nâng cao, dịch/gợi ý ví dụ, đồng bộ tài khoản.
- Cá nhân hóa: mục tiêu ngày, streak, từ yếu, ôn lại theo spaced repetition.
- Nội dung mở rộng: HSK 5-6, business Chinese, du lịch, công sở, mạng xã hội, công nghệ, y tế, pháp luật, văn hóa.
- Chất lượng: thêm test parser JSON, test repository lookup, test không có chuỗi “Nghĩa Việt đang cập nhật” trong flashcard đã có metadata.

## 11. Ý tưởng admin web quản lý app

Admin web nên là dashboard riêng, có thể build bằng Next.js/React, gọi NestJS API.

### Module chính

- Đăng nhập và phân quyền: Super Admin, Content Editor, Reviewer, Support.
- Quản lý từ điển: CRUD từ, pinyin, nghĩa Việt, nghĩa Anh, HSK, loại từ, Hán Việt, ví dụ.
- Quản lý flashcard: CRUD topic, thứ tự topic, màu/icon, danh sách từ, ảnh, trạng thái publish.
- Quản lý ảnh: upload, crop, nén ảnh, xem ảnh bị trùng, gắn nguồn/license.
- Quản lý bài đọc: CRUD bài HSK/news, câu, pinyin, dịch, từ khóa.
- Quản lý ngữ pháp: CRUD mẫu câu, giải thích, ví dụ, bài tập.
- Quản lý quiz: ngân hàng câu hỏi, đáp án, độ khó, thống kê câu sai nhiều.
- Quản lý người dùng: hồ sơ, tiến độ, streak, gói học, phản hồi.
- Kiểm duyệt nội dung: draft, review, approved, published, archived.
- Analytics: topic được học nhiều, từ bị lỗi nghĩa, API slow, crash log.

### Luồng publish nội dung

1. Editor tạo hoặc sửa nội dung.
2. Hệ thống validate: thiếu pinyin, thiếu nghĩa Việt, ảnh trùng, chuỗi mojibake, ví dụ rỗng.
3. Reviewer duyệt.
4. Admin publish thành phiên bản content bundle.
5. Mobile app tải bundle mới hoặc dùng bundle đóng gói sẵn nếu offline.

### API cần có cho admin

- `POST /admin/auth/login`
- `GET /admin/dashboard`
- `GET/POST/PATCH/DELETE /admin/vocabulary`
- `GET/POST/PATCH/DELETE /admin/flashcard-topics`
- `POST /admin/assets/upload`
- `GET/POST/PATCH/DELETE /admin/reading`
- `GET/POST/PATCH/DELETE /admin/grammar`
- `GET/POST/PATCH/DELETE /admin/quizzes`
- `GET /admin/reports/content-quality`
- `POST /admin/content-bundles/publish`

### Data model đề xuất

- `users`: tài khoản học viên/admin.
- `vocabulary`: từ, pinyin, nghĩa, HSK, loại từ.
- `example_sentences`: ví dụ theo từ.
- `flashcard_topics`: chủ đề, icon, màu, level, publish state.
- `flashcard_words`: mapping topic-word, ảnh, thứ tự.
- `media_assets`: file ảnh, nguồn, license, hash chống trùng.
- `lessons`: bài học từ vựng/ngữ pháp/đọc.
- `quiz_questions`: câu hỏi và đáp án.
- `user_progress`: tiến độ học.
- `content_versions`: phiên bản bundle đã publish.

## 12. Checklist chất lượng trước khi release

- Không còn chuỗi mojibake trong Dart/JSON.
- Không còn fallback nghĩa ở các flashcard có metadata.
- Mỗi topic có ảnh đại diện khác nhau nếu có thể.
- Mỗi từ flashcard có pinyin và nghĩa Việt.
- App mở màn flashcard dưới 1 giây sau lần load đầu.
- Ảnh được nén dưới 200 KB/tấm nếu không cần chất lượng cao.
- Có test format/analyze Flutter trước khi build APK.

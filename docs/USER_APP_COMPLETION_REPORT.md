# Báo cáo hoàn thiện phần người dùng VNChinese

Ngày cập nhật: 06/06/2026

## 1. Mục tiêu

Hoàn thiện các phần chính của app người dùng gồm Hôm nay, Từ vựng, Ngữ pháp, Đọc và Tài khoản theo hướng dùng được ngay cả khi backend chưa chạy. Trọng tâm là sửa lỗi màn Ngữ pháp đang báo không kết nối được `http://127.0.0.1:3001/grammar/check`, đồng thời loại bỏ số liệu giả trên trang chủ.

## 2. Hiện trạng trước khi sửa

- Màn Ngữ pháp gọi backend AI trước. Khi backend port `3001` tắt, app hiển thị lỗi kết nối và vẫn dựng thẻ kết quả như một lần chấm thất bại.
- Trang Hôm nay hiển thị số cố định như streak, từ hôm nay, phút học, lượt AI sửa câu dù người dùng chưa thực hiện thao tác.
- Màn Tài khoản phụ thuộc `/profile`; khi API không chạy thì dùng fallback có số liệu mẫu, dễ gây hiểu nhầm là dữ liệu thật.
- Một số thao tác học như lưu từ, mở bài đọc, luyện phát âm chưa được ghi về một nguồn tiến độ chung.

## 3. Phần đã build trong `apps/mobile/lib/main.dart`

### 3.1. Trang Hôm nay

- Chuyển `HomeScreen` sang màn có trạng thái để nạp `LearningProgressSnapshot`.
- Số liệu trên dashboard hiện lấy từ `SharedPreferences`:
  - ngày streak,
  - số từ học hôm nay trên mục tiêu ngày,
  - số phút học hôm nay,
  - số lượt sửa câu ngữ pháp hôm nay.
- Nội dung hero đổi theo trạng thái thật: người dùng chưa học thì mời bắt đầu phiên học, đã học thì hiển thị tiến độ hôm nay.
- Nút nhanh dẫn thẳng tới Từ vựng và Ngữ pháp.

### 3.2. Từ vựng

- Khi người dùng lưu một từ mới vào sổ tay, app ghi nhận một từ học hôm nay và cộng thời gian học ước tính.
- Khi hoàn thành một bài flashcard, app ghi thêm phút học.
- Sổ tay vẫn lưu cục bộ trên thiết bị bằng `NotebookStore`, không cần backend.

### 3.3. Ngữ pháp

- Thêm fallback kiểm tra nội bộ bằng `GrammarChecker` khi backend AI chưa phản hồi.
- Trường hợp câu đúng như `我们想去学校`, app không còn báo lỗi kết nối đỏ; app trả kết quả kiểm tra nội bộ và câu chuẩn có dấu câu.
- Trường hợp câu sai như `我不学校去`, app sửa bằng quy tắc nội bộ thành `我不去学校。`.
- Mỗi lần kiểm tra được lưu vào lịch sử, gồm câu nhập, câu sửa, điểm, thời gian.
- Nút lịch sử trên màn Ngữ pháp mở bottom sheet xem các lần kiểm tra gần nhất.

### 3.4. Đọc và phát âm

- Khi người dùng mở một bài đọc, app ghi nhận số bài đọc tuần này và cộng phút học.
- Khi người dùng mở video, app cộng phút học.
- Khi luyện phát âm xong, app lưu điểm phát âm trung bình cục bộ.

### 3.5. Tài khoản

- `ProfileRepository.load()` ưu tiên API nếu có, nhưng tự động dùng hồ sơ cục bộ nếu backend tắt.
- `ProfileRepository.updateGoal()` lưu mục tiêu HSK, số từ/ngày và phút/ngày vào thiết bị trước, sau đó đồng bộ API theo best effort.
- Fallback tài khoản đã bỏ số liệu mẫu cao như 42 từ, 91 điểm, 12 streak; dữ liệu hiển thị bây giờ bắt đầu từ tiến độ thật.
- Các thông báo UI đã đổi từ “qua API” sang ngữ cảnh local/offline-first.

## 4. Kế hoạch thiết kế hoàn thiện tiếp theo

| Giai đoạn | Mục tiêu | Công việc chi tiết | Ưu tiên |
|---|---|---|---|
| 1 | Ổn định trải nghiệm người dùng | Hoàn tất offline-first, bỏ số liệu giả, sửa fallback ngữ pháp, lưu tiến độ local | Đã xong |
| 2 | Làm sạch chất lượng toàn module mobile | Xử lý warning còn lại trong `vocab_data_helper.dart`, `quiz_screen.dart`, `magic_vocab_screen.dart`, `news_reader_screen.dart`; bỏ file/màn cũ không dùng | Cao |
| 3 | Đồng bộ backend thật | Chuẩn hóa API `/profile`, `/grammar/check`, `/reading/news`, `/dictionary/*`; thêm trạng thái online/offline rõ trong repository | Cao |
| 4 | Hoàn thiện học liệu | Kiểm tra lại toàn bộ dữ liệu HSK, pinyin, nghĩa tiếng Việt, ví dụ; loại bỏ dữ liệu mojibake trong các helper cũ | Cao |
| 5 | Cá nhân hóa | Gắn session người dùng với mục tiêu HSK, lịch sử học, sổ tay và tiến độ đa thiết bị | Trung bình |
| 6 | Kiểm thử sản phẩm | Thêm widget test cho 5 tab chính, test fallback khi API tắt, test lưu mục tiêu, test lịch sử ngữ pháp | Cao |
| 7 | Tối ưu UI | Kiểm tra responsive mobile/web, giảm text dài trong card nhỏ, hoàn thiện trạng thái empty/loading/error | Trung bình |
| 8 | Chuẩn bị demo/bảo vệ | Viết script demo: đăng nhập, học từ, kiểm tra ngữ pháp, đọc bài, xem tài khoản; chụp ảnh màn hình minh họa | Trung bình |

## 5. Kiểm thử đã chạy

- `dart format lib/main.dart`: thành công.
- `flutter analyze lib/main.dart`: không có issue.
- `flutter test`: tất cả test hiện có đều pass.

Ghi chú: `flutter analyze` toàn project vẫn báo các warning/info cũ ở nhiều file phụ, ví dụ `vocab_data_helper.dart`, `quiz_screen.dart`, `magic_vocab_screen.dart`, `news_reader_screen.dart`. Các cảnh báo này không nằm trong phần sửa chính hôm nay và không chặn smoke test.

## 6. Cập nhật nâng cấp ngày 06/06/2026

### 6.1. Ngữ pháp AI thật

- Backend hiện chỉ còn một endpoint chấm ngữ pháp duy nhất: `POST /grammar/check`.
- Endpoint này gọi Google Gemini từ backend, thử lần lượt `GEMINI_MODEL`, `gemini-2.5-flash`, `gemini-2.0-flash`, `gemini-1.5-flash`.
- Response trả thêm `source`, `provider`, `model` để app user/admin biết kết quả có phải AI thật hay không.
- Frontend không còn tự nâng điểm `0` thành `90/60`; nếu AI backend lỗi hoặc thiếu key, app hiển thị “Chưa chấm được bằng AI” và chỉ đưa gợi ý nội bộ, không giả vờ là điểm AI.
- Kết quả ngữ pháp hiện có thêm badge nguồn chấm và danh sách gợi ý diễn đạt.

### 6.2. Từ vựng và flashcard

- Loader flashcard asset đã phân cấp topic theo HSK 1-4 thay vì để level `Chủ đề`, nên nhiều chủ đề hơn sẽ hiện trong selector HSK.
- Các topic asset như chào hỏi, gia đình, ăn uống, trường học, giao thông, sức khỏe, mua sắm, thể thao, truyền thông... được đưa vào đúng cấp học.
- Thumbnail topic đã bỏ chip chữ nhỏ đè trên ảnh để tránh lỗi overflow kiểu “overflowed by x pixels”.
- `TopicCard` giới hạn tên topic một dòng và dùng `Wrap` cho nhãn, giúp layout mượt hơn trên viewport hẹp.

### 6.3. Video shadowing

- Video detail hiện poll vị trí player ổn định hơn và khóa câu đang luyện.
- Khi phát một câu, video tự pause ở cuối câu.
- Người học ghi âm lại câu; sau khi chấm điểm, app tự chuyển sang câu tiếp theo nếu bật chế độ tự dừng.
- Điểm phát âm từ video cũng được ghi vào tiến độ học local.

### 6.4. Admin

- Admin seed có thêm nhiều topic đồng nhất với app user: chào hỏi, ăn uống, trường học, giao thông...
- Admin có nút “Nạp từ app user” để đọc `apps/mobile/assets/images/flashcards/index.json`.
- Khi import/nạp topic từ mobile, admin tự gán level HSK theo id topic.
- Dashboard admin có panel kiểm tra nhanh AI ngữ pháp dùng cùng endpoint `/grammar/check`.
- Settings có nút test API và test AI ngữ pháp.

### 6.5. Kiểm thử cập nhật

- `npm run build` trong `api`: thành công.
- `flutter analyze lib/main.dart lib/grammar_ai_service.dart`: không có issue.
- `flutter test`: pass.
- `node --check apps/admin/app.js`: pass.

## 7. Kết luận

Các tab người dùng chính đã chuyển sang hướng dùng được ngay với dữ liệu local. Backend vẫn có thể được bật để đồng bộ và dùng AI thật, nhưng khi backend tắt app không còn hiển thị số liệu giả hoặc biến lỗi kết nối thành trải nghiệm hỏng.

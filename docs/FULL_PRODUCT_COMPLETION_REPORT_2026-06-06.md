# Báo cáo hoàn thiện VNChinese

Ngày bàn giao: 06/06/2026

## 1. Phạm vi đã hoàn thiện

Đợt build này tập trung hoàn thiện trải nghiệm người học và nối phần quản trị với cùng dữ liệu của app:

- Hôm nay và tiến độ học thực.
- Từ vựng, flashcard, chủ đề và quiz.
- Ngữ pháp AI, lịch sử kiểm tra và nguồn chấm rõ ràng.
- Đọc báo trực tuyến, đọc câu bằng TTS và tra từ.
- Video shadowing theo timing, tự dừng, ghi âm và chuyển câu.
- Tài khoản, đăng ký, đăng nhập, mục tiêu học và giờ nhắc học.
- Gia sư AI.
- Admin quản lý nội dung, người dùng, video, nguồn báo, game và AI.
- Luồng xuất bản nội dung từ admin sang backend và app user.

## 2. Flashcard và từ vựng

### Kết quả

- Flashcard chi tiết đã đổi sang đúng bố cục yêu cầu:
  - một từ Hán tự lớn;
  - pinyin có dấu thanh bên dưới;
  - nghĩa tiếng Việt rõ ràng;
  - ví dụ chỉ hiện khi lật thẻ.
- Bỏ phần ảnh và nhãn đè lên mặt flashcard.
- Giữ ảnh đại diện ở danh sách chủ đề để người học nhận diện nhanh.
- Có 20 chủ đề asset, gồm động vật, đồ ăn, gia đình, trường học, mua sắm, sức khỏe, thời tiết, nhà cửa, quần áo, địa điểm, thể thao, thiên nhiên, giải trí, đời sống thành phố và các chủ đề khác.
- Tên chủ đề tiếng Việt đã được sửa dấu.
- Pinyin và nghĩa tiếng Việt trong manifest đã được chuẩn hóa lại.
- Thêm quiz chọn nghĩa theo từng chủ đề.
- Lưu từ và hoàn thành bài học được ghi vào tiến độ HSK thật.

### Công cụ dữ liệu

- `tools/sync_flashcard_metadata.py`: sửa pinyin, nghĩa và tên chủ đề nhưng giữ nguyên file ảnh.
- `tools/flashcard_manifest.json`: nguồn nội dung flashcard.
- `apps/mobile/assets/images/flashcards/index.json`: catalog app user.

Admin có thể tạo chủ đề, nhập từng từ theo định dạng:

```text
Hán tự | pinyin | nghĩa Việt | tên ảnh | câu Trung | pinyin câu | dịch câu
```

Sau khi kiểm tra QA, bấm `Xuất bản` để gửi catalog sang backend. App user ưu tiên catalog backend và tự dùng asset cục bộ khi mất mạng.

## 3. Video và luyện phát âm

### Luồng đã build

- Video có timing thật sẽ tự theo dõi câu hiện tại.
- Đến cuối câu, video tự dừng.
- Người học ghi âm lại câu.
- App nhận dạng lời nói, chấm độ khớp văn bản và lưu điểm.
- Khi hoàn thành, app chuyển sang câu tiếp theo.
- Có nút phát lại đoạn, câu tiếp theo, bật/tắt pinyin và nghĩa Việt.
- Video không có timing không còn giả lập chạy phụ đề. App hiển thị rõ `Chưa có timing` và chuyển sang luyện từng câu thủ công.
- Các YouTube ID đã xác định không khả dụng được lọc khỏi app.

### Dữ liệu hiện tại

- Catalog backend có 9 bài video khả dụng.
- Bài `Chinese Listening Practice` có 388 câu tiếng Trung và tiếng Việt đã khớp timing từ caption YouTube.
- Các video Little Fox tắt caption chỉ có câu mẫu, chưa thể tự đồng bộ toàn bộ video một cách đáng tin cậy.

### Khi nào cần cung cấp timestamp

Bạn không cần tự tách thời gian đối với video có caption YouTube công khai. Dùng:

```powershell
python tools\youtube_transcript_import.py VIDEO_ID --lesson-id LESSON_ID
```

Đối với video tắt caption, cần một trong các dữ liệu sau:

- file SRT hoặc VTT;
- danh sách `start | end | câu Trung | pinyin | nghĩa Việt`;
- transcript có mốc giây từng câu.

Admin đã có trình nhập transcript đúng định dạng này. Không nên tự đoán timing vì sẽ làm video dừng sai câu.

## 4. Đọc báo và phát âm

### Đọc báo

- App tự thử tải tin mới khi mở màn Đọc.
- Có bộ lọc theo nguồn báo.
- Backend đang đọc RSS từ 4 nguồn: 中国新闻网, VOA 中文, BBC 中文 và RFI 中文.
- Kiểm thử ngày 06/06/2026 trả được 24 bài.
- Trong bài đọc, app tách câu, đọc TTS và cho chạm từ để tra nghĩa.
- Admin có thể thêm, sửa, bật hoặc tắt nguồn RSS rồi xuất bản.

### Phát âm

Điểm hiện tại dựa trên kết quả nhận dạng tiếng Trung và độ khớp với câu mẫu. Cách này phù hợp cho luyện nói cơ bản nhưng chưa phân tích chính xác thanh điệu, âm đầu và âm cuối.

Muốn chấm phát âm chuyên sâu như sản phẩm thương mại, nên nối thêm dịch vụ chuyên dụng như Azure Speech Pronunciation Assessment. Gemini không nên được dùng để tự chấm âm thanh khi backend chưa gửi và phân tích file ghi âm.

## 5. Tài khoản và tiến độ

- Đã có đăng ký, đăng nhập và lưu phiên.
- Admin có thể tạo, sửa, khóa hoặc mở khóa người dùng.
- Trang tài khoản lấy tiến độ thật từ thiết bị thay cho số liệu mẫu.
- Mục tiêu HSK, số từ/ngày và phút/ngày phản ánh lên trang chính.
- Giờ nhắc học có thể chỉnh bằng bộ chọn thời gian và được lưu lại.
- Lộ trình HSK dùng số từ thực tế đã học.
- Sổ từ, điểm phát âm, số bài đọc và phút học được cập nhật theo hoạt động.

Giờ nhắc học hiện được lưu và hiển thị trong app. Thông báo hệ điều hành chạy khi app đã đóng cần thêm plugin notification cho Android/iOS hoặc service worker cho web.

## 6. Ngữ pháp và gia sư AI

- Frontend không còn tự cho điểm giả khi AI không phản hồi.
- Backend trả rõ provider, model và nguồn chấm.
- Có phản hồi lỗi, câu sửa, pinyin, dịch nghĩa và gợi ý diễn đạt.
- Có màn Gia sư AI với lịch sử hội thoại và prompt nhanh.
- Backend hỗ trợ cả:
  - Google AI Studio API key dạng `AIza...`;
  - Vertex AI Express Mode API key dạng `AQ...`.

Khóa hiện tại được nhận diện là Vertex AI Express Mode. Kiểm thử thật trả `403 SERVICE_DISABLED`, nghĩa là khóa đã được nhận diện nhưng project chưa bật Vertex AI API.

Thao tác còn cần thực hiện:

1. Mở `https://console.cloud.google.com/apis/library/aiplatform.googleapis.com`.
2. Chọn đúng project chứa API key hiện tại.
3. Bấm Enable cho Vertex AI API.
4. Đợi vài phút.
5. Khởi động lại backend.

Không cần đổi code hoặc thay khóa chỉ vì prefix `AQ`.

## 7. Admin

Admin đã được xây lại thành control center gồm:

- Dashboard tổng quan và QA.
- Quản lý từ vựng.
- Quản lý chủ đề và flashcard.
- Quản lý bài học.
- Quản lý video và transcript.
- Quản lý nguồn báo.
- Quản lý quiz và trò chơi.
- Quản lý người dùng thật qua backend.
- Kiểm tra grammar AI, chatbot và health.
- Import/export JSON.
- Nút `Xuất bản` đồng bộ nội dung sang app user.

Catalog được lưu tại:

```text
api/data/managed-content.json
```

Backend tự bootstrap từ asset mobile nếu chưa có catalog admin, nên lần chạy đầu không bị rỗng dữ liệu.

## 8. Cách chạy

### Dịch vụ đang chạy

- User app: `http://127.0.0.1:62676`
- Admin: `http://127.0.0.1:8082/admin/index.html`
- API health: `http://127.0.0.1:3001/health`
- Adminer: `http://127.0.0.1:8080`

### Tài khoản admin local

```text
Email: admin@vnchinese.local
Mật khẩu: admin123456
```

Nên đổi mật khẩu mặc định trước khi triển khai thật.

### Khởi động lại thủ công

```powershell
docker compose up -d postgres redis adminer
cd api
npm run build
npm run start:prod
```

Mở terminal khác:

```powershell
cd apps/mobile
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 62676
```

Mở terminal khác:

```powershell
cd apps
python -m http.server 8082
```

## 9. Kiểm thử đã chạy

- `flutter analyze lib/main.dart lib/auth_service.dart lib/grammar_ai_service.dart`: không có lỗi.
- `flutter test`: pass.
- `npm run build`: pass.
- `npm test -- --runInBand`: pass.
- `node --check apps/admin/app.js`: pass.
- `python -m py_compile tools/youtube_transcript_import.py tools/sync_flashcard_metadata.py`: pass.
- Publish catalog lớn có transcript 388 câu: pass sau khi nâng giới hạn JSON lên 10 MB.
- Đăng nhập admin backend: pass.
- RSS trực tuyến: pass.
- Responsive login admin desktop/mobile: pass.
- Flutter web user sau restart: render bình thường.

## 10. Phần nên nâng cấp tiếp

Các hạng mục sau cần dịch vụ hoặc dữ liệu ngoài, không nên giả lập:

- Bật Vertex AI API để grammar và chatbot chạy thật.
- Thêm Azure Speech hoặc dịch vụ tương đương để chấm thanh điệu chuyên sâu.
- Bổ sung SRT/VTT cho các video tắt caption.
- Thêm notification nền cho nhắc học khi app đã đóng.
- Đồng bộ tiến độ đa thiết bị bằng bảng user progress thay vì chỉ lưu local.
- Upload ảnh lên object storage thay vì giữ đường dẫn asset hoặc data URL trong admin.

## 11. Kết luận

App hiện có luồng học hoàn chỉnh theo hướng offline-first và có backend khi trực tuyến. Các số liệu giả đã được loại khỏi màn chính, admin đã có quyền quản lý người dùng và publish nội dung, video có timing thật đã chạy theo từng câu, còn AI đã hỗ trợ đúng loại khóa Vertex hiện tại. Điểm chặn duy nhất của grammar/chatbot lúc bàn giao là Vertex AI API chưa được bật trong project Google Cloud.

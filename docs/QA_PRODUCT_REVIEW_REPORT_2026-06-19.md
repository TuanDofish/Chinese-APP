# Báo cáo QA/Product/UI Review hệ thống VNChinese

Ngày kiểm thử: 19/06/2026  
Vai trò đánh giá: QA Lead + Product Manager + UI/UX Reviewer  
Phạm vi: `apps/mobile/`, `api/`, `apps/admin/`, dữ liệu runtime qua API local.

> Lưu ý: Báo cáo này chỉ đọc, chạy kiểm thử và đánh giá. Không sửa code, không refactor, không xóa file.

## Tóm tắt điều hành

VNChinese đã có nền tảng đủ rộng cho một đồ án tốt nghiệp: Flutter app, backend NestJS, PostgreSQL, admin web, học từ vựng, từ điển, đọc bài, luyện nói, video shadowing, tiến độ và quản trị nội dung. Tuy nhiên, trạng thái hiện tại chưa nên xem là ổn định để demo tự do. Cần khóa phạm vi demo và sửa các lỗi Critical trước, đặc biệt là AI Gemini gọi thật đang lỗi 503, encoding tiếng Việt/tiếng Trung từng xuất hiện, cấu hình chạy môi trường dễ gây nhầm port, và dữ liệu video/admin chưa đồng nhất với app user.

Kết luận ngắn: đủ tiềm năng để bảo vệ đồ án nếu sửa checklist Critical/High và chuẩn bị kịch bản demo kiểm soát. Chưa đạt mức production.

## PHẦN 1. Kiểm tra khả năng chạy hệ thống

### Kết quả runtime

| Hạng mục | Kết quả | Bằng chứng kiểm tra | Nhận xét |
|---|---:|---|---|
| Backend NestJS | Chạy được | `GET http://localhost:3001/health` trả 200 | API đang sống tại port 3001. |
| PostgreSQL/Docker | Chạy được | `docker ps`: `chinese_app_db` map `5433->5432`, `chinese_app_redis` map `6379->6379` | Cần Docker chạy trước API. Có thêm host port `5432` đang mở, dễ nhầm DB local. |
| Endpoint `/health` | Chạy được | `status: ok`, `service: VNChinese API` | Health báo AI configured nhưng chưa đủ chứng minh AI dùng được. |
| Admin web | Chạy được | `GET http://127.0.0.1:8080` trả 200 | Admin server chạy qua `scripts/serve-admin.js`. |
| Admin proxy API | Chạy được | `GET http://127.0.0.1:8080/api/health` trả 200 | Proxy `/api` từ admin sang backend hoạt động. |
| Admin login online | Chạy được | Login `admin@vnchinese.local / admin123456` trả user role `admin` | Backend auth OK trong phiên này. |
| Mobile Flutter CLI | Chưa xác nhận được | `flutter --version`, `dart --version`, `flutter analyze` bị treo hơn 2 phút và phải dừng | Có Flutter SDK trong PATH, nhưng CLI không phản hồi trong phiên test. Screenshot trước đó cho thấy Flutter Web từng chạy được. |
| Gemini API | Lỗi khi gọi thật | `/health` báo key hợp lệ, nhưng `POST /grammar/check` trả 503 | Critical: key chưa được cấp quyền hoặc provider/API key sai. |
| RSS live | Chạy được | `GET /reading/news` trả tin mới ngày 19/06/2026 từ 中国新闻网/VOA/BBC | Nên có fallback vì phụ thuộc mạng/nguồn ngoài. |
| Dictionary API | Chạy được | `GET /dictionary/search?q=你好` trả pinyin `nǐ hǎo`, nghĩa `xin chào`, ví dụ | Tốt để demo. |
| Pronunciation score | Chạy được | `你好` vs `你好` trả 100; `你好` vs `你` trả 45 | Chấm điểm có số trung gian, không chỉ 0/100. |
| Ảnh admin/mobile | Serve được | `/mobile/assets/...jpg` trả 200; `/uploads/flashcards/...jpg` trả 200 | Backend/serve-admin có phục vụ ảnh, UI admin vẫn cần normalize path tốt hơn. |

### Port và cấu hình cần nhớ

| Dịch vụ | Port hiện tại | File/liên quan | Rủi ro |
|---|---:|---|---|
| API NestJS | 3001 | `api/dist/src/main`, `scripts/start-vnchinese-dev.ps1` | Nếu API chưa lên, admin login báo `ECONNREFUSED 127.0.0.1:3001`. |
| Admin web | 8080 | `scripts/serve-admin.js` | `docker-compose.yml` có Adminer cũng dùng 8080, có thể conflict nếu bật Adminer. |
| PostgreSQL container | 5433 | `docker-compose.yml`, `api/src/app.module.ts` | Host cũng có 5432 đang mở, dễ cấu hình nhầm. |
| Redis container | 6379 | `docker-compose.yml` | Không phải luồng demo chính. |

### Vấn đề API base URL

| Nền tảng chạy app | `localhost:3001` có ổn không? | Cách đúng |
|---|---|---|
| Flutter Web trên cùng máy | Có thể ổn | `http://localhost:3001` hoặc `http://127.0.0.1:3001`. |
| Android emulator | Không ổn | Dùng `http://10.0.2.2:3001`. |
| Điện thoại thật | Không ổn | Dùng IP LAN của máy chạy backend, ví dụ `http://192.168.x.x:3001`. |
| iOS simulator | Thường ổn với localhost, nhưng cần test | Nên dùng config qua `--dart-define=API_BASE_URL=...`. |

File liên quan: `apps/mobile/lib/core/config/app_config.dart`, `apps/mobile/lib/features/auth/auth_service.dart`, `apps/mobile/lib/features/vocabulary/dictionary_repository.dart`.

### Lỗi/rủi ro runtime quan trọng

| Mức độ | Vấn đề | Nguyên nhân có thể | Đề xuất sửa |
|---|---|---|---|
| Critical | `/grammar/check` trả 503 dù `/health` báo AI configured | API key Gemini có format đúng nhưng chưa được cấp quyền/không đúng provider | Trước demo phải test một câu thật; health nên kiểm tra quyền bằng request nhỏ hoặc thêm trạng thái `ai.usable`. |
| Critical | Mobile CLI bị treo trong phiên test | Flutter cache/tool lock/Windows shell/path issue, chưa xác định được | Chạy lại riêng `flutter doctor -v`, `flutter clean`, `flutter pub get`; ghi log nếu treo. |
| High | Encoding tiếng Việt/tiếng Trung từng hiển thị mojibake | Một số file/source/log có dấu hiệu encoding không đồng nhất; terminal Windows cũng có thể gửi `??` nếu không dùng UTF-8 | Chuẩn hóa toàn bộ file sang UTF-8, kiểm tra Chrome UI, API body UTF-8, DB collation. |
| High | Script dev từng báo API không ready | API cần build `dist`, DB cần sẵn sàng, port owner bị kill/start lại | Script nên in log API error khi fail thay vì chỉ timeout. |
| Medium | Admin 8080 có thể conflict Adminer | `docker-compose.yml` có Adminer port 8080, admin web cũng 8080 | Đổi Adminer sang 8081 hoặc admin web sang 8080 cố định và tắt Adminer. |

## PHẦN 2. Test luồng người dùng thường

Mức kiểm thử: đối chiếu code, API runtime và ảnh chụp UI trước đó. Mobile UI chưa được chạy automation trong phiên này do Flutter CLI treo.

### 1. Mở app lần đầu

| Tiêu chí | Đánh giá |
|---|---|
| Màn đầu | `VNChineseApp` dùng `AuthGate` trong `apps/mobile/lib/main.dart` và `apps/mobile/lib/features/auth/auth_flow.dart`. |
| AuthGate | Có restore session qua `AuthService.currentSession()`. |
| Loading | Có màn loading ngắn. |
| Chưa đăng nhập | Chuyển về auth screen. |
| Rủi ro | Fallback local/guest làm demo dễ chạy, nhưng có thể làm người chấm không rõ đâu là online backend, đâu là local. |

Text flow:

```text
Mở app
  -> AuthGate kiểm tra session
    -> Có session: MainScreen/AppShell
    -> Không có session: AuthScreen
      -> Login/Register/Guest
```

### 2. Đăng ký

| Tiêu chí | Đánh giá |
|---|---|
| Form | Có email/password/display name/level trong `auth_flow.dart`. |
| Validate | Có validate cơ bản, chưa đủ mạnh cho production. |
| Session | Sau đăng ký có lưu session nếu backend/local thành công. |
| Lỗi | Có thông báo, nhưng fallback local có thể che mất lỗi server thật. |
| Khuyến nghị demo | Nên demo login bằng tài khoản có sẵn; đăng ký chỉ demo nếu backend chắc chắn chạy. |

### 3. Đăng nhập

| Tiêu chí | Đánh giá |
|---|---|
| Online backend | Admin account đã test thành công qua `/auth/login`. User thường cần test thêm trực tiếp trong app. |
| Local fallback | Có, giúp app không chết khi API tắt nhưng gây hiểu nhầm về đồng bộ dữ liệu. |
| Sai mật khẩu | Có xử lý lỗi, cần kiểm UI mobile thực tế. |
| Sau login | Đi vào `MainScreen/AppShell` 5 tab. |
| Rủi ro | Nếu demo Android/emulator mà vẫn dùng `localhost`, login online sẽ fail. |

### 4. Trang Home

| Tiêu chí | Đánh giá |
|---|---|
| Người mới hiểu bắt đầu ở đâu | Tạm ổn nhờ CTA học tiếp/kiểm tra/chơi game. |
| Metrics/streak/progress | Có nhưng khi user mới toàn số 0 dễ tạo cảm giác app rỗng. |
| Shortcut | Hợp lý: từ vựng, ngữ pháp, đọc, mini game. |
| Giao diện | Đã đẹp hơn trước, nhưng phải kiểm lại font/encoding trên web. |
| Đề xuất | Thêm “Hôm nay nên học gì” theo HSK và 1 bài học demo nổi bật. |

### 5. Từ vựng/Flashcard

| Tiêu chí | Đánh giá |
|---|---|
| Chọn HSK/chủ đề | Có topic/HSK, dữ liệu topic từ backend/assets. |
| Nội dung thẻ | Có Hán tự, pinyin, nghĩa, ảnh, nghe, ghi âm. Flashcard đã hợp hướng “gọn” hơn. |
| TTS | Có `flutter_tts`. |
| Lưu từ/sổ tay | Có `NotebookStore` trong `dictionary_repository.dart`. |
| Đánh dấu đã học | Có ghi progress qua local/remote best-effort. |
| Quiz/mini game | Có game/quiz theo topic, nhưng cần giải thích phạm vi rõ. |
| Rủi ro | Ảnh có thể bị lặp hoặc không preview nếu đường dẫn lẫn asset/upload. Admin cần normalize đường dẫn trước publish. |

### 6. Từ điển

| Tiêu chí | Kết quả |
|---|---|
| Tra chữ Hán | Chạy được: test `你好` trả đúng pinyin/nghĩa/ví dụ. |
| Tra tiếng Việt/pinyin | Có logic local/remote, cần test thêm UI. |
| Kết quả | Có pinyin, nghĩa, ví dụ. |
| Empty/loading/error | Có trạng thái cơ bản, cần làm đẹp empty state. |
| Đề xuất | Thêm lịch sử tra từ và nút lưu rõ hơn trong kết quả. |

### 7. Ngữ pháp

| Tiêu chí | Đánh giá |
|---|---|
| Danh sách theo HSK | Có dữ liệu 231 bài trong catalog. |
| Nội dung bài | Có pattern, giải thích, ví dụ, pinyin/nghĩa. |
| UI học | Dễ demo, nhưng cần kiểm font Hán tự/pinyin. |
| Rủi ro | Một số file có dấu hiệu mojibake khi đọc source/log. |

### 8. AI kiểm tra ngữ pháp

| Tiêu chí | Kết quả |
|---|---|
| Gửi backend | Mobile gọi `POST /grammar/check` qua `GrammarAiService`. |
| Gemini hoạt động | Không hoạt động trong test thật: 503 “Gemini không chấp nhận API key hoặc key chưa được cấp quyền.” |
| Fallback | App có fallback local với kết quả yếu hơn. |
| Dễ hiểu | Nếu AI chạy thì format tốt; nếu lỗi phải báo thân thiện hơn. |
| Lịch sử | Có lưu lịch sử kiểm tra trong progress/history. |
| Khuyến nghị demo | Chỉ demo AI sau khi test câu thật ngay trước buổi bảo vệ. |

### 9. Reading/RSS

| Tiêu chí | Kết quả |
|---|---|
| Bài đọc seed | Có `readingSources` trong catalog, nhưng catalog hiện chỉ 2 nguồn/bài đọc chính. |
| RSS live | Chạy được trong test, trả tin ngày 19/06/2026. |
| Click từ | Có bottom sheet tra từ qua dictionary. |
| Lưu từ từ bài đọc | Chưa thấy rõ CTA lưu từ trong word sheet bài đọc; cần bổ sung nếu muốn demo luồng này. |
| TTS đọc bài | Có TTS từng câu/bài ở reading. |
| UX | Phần đọc báo live có thể quá “tin tức”; nên định vị là “Bài đọc ngắn + tra từ”, không phải app báo. |

### 10. Luyện phát âm

| Tiêu chí | Kết quả |
|---|---|
| TTS mẫu | Có. |
| STT/micro | Có `speech_to_text` và xin quyền qua plugin. Cần test thiết bị thật. |
| Chấm điểm | Backend scorer trả số trung gian; test `你好`/`你` trả 45. |
| Căn cứ chấm | `api/src/app.service.ts`: normalize chữ Hán, LCS chữ Hán, similarity pinyin, length ratio. |
| Ai chấm | Backend local scorer, không phải giáo viên/AI chuyên phát âm. |
| Khuyến nghị | Luôn ghi “điểm tham khảo theo STT + so khớp văn bản/pinyin”. |

### 11. Video shadowing

| Tiêu chí | Kết quả |
|---|---|
| User có thấy video | Có, nhưng ít hơn admin. |
| Transcript timed | 18 video published trong backend, chỉ 4 video đạt rule practice-ready để user thấy. |
| Auto-pause | Controller đã có logic poll 120ms/auto-pause/chờ ghi âm/resume. |
| Người học hiểu thao tác | UI hiện khá rõ, nhưng khu danh sách câu có lúc hẹp trên màn nhỏ. |
| Rủi ro dữ liệu | Nhiều video dài nhưng chỉ có 4-5 câu hoặc timestamp 0/0, không nên demo. |

Kết quả lọc video thực tế:

| Tổng video backend | Video đủ điều kiện user | Lý do bị loại phổ biến |
|---:|---:|---|
| 18 | 4 | Ít hơn 8 subtitles, span dưới 20 giây, timestamp 0/0, hoặc YouTube ID nằm trong danh sách unavailable. |

### 12. Profile/Progress

| Tiêu chí | Đánh giá |
|---|---|
| Streak/từ đã học/từ lưu | Có local + remote best-effort. |
| Mục tiêu ngày | Có API `/learning/goal` và local fallback. |
| Đăng xuất | Có xóa session và về login. |
| UI profile | Đủ demo, nhưng cần làm rõ dữ liệu nào là real và dữ liệu nào là local. |
| Rủi ro | Đồng bộ đa thiết bị chỉ đạt một phần, vì nhiều thứ vẫn dựa SharedPreferences. |

## PHẦN 3. Test luồng admin

### 1. Admin login

| Tiêu chí | Đánh giá |
|---|---|
| Login admin | Chạy được qua backend với `admin@vnchinese.local / admin123456`. |
| Chặn user thường | Backend có `AdminAuthGuard`, cần test UI bằng user thường. |
| Offline admin mode | Hữu ích khi demo không có API, nhưng nguy hiểm vì có thể làm người quản trị tưởng đã publish thật. |
| Đề xuất | Offline mode cần banner “Chỉ chỉnh localStorage, không đồng bộ app user”. |

### 2. Dashboard admin

| Chỉ số test được | Giá trị runtime |
|---|---:|
| Users total | 5 |
| Admins | 2 |
| Content dashboard vocabulary | 121196 |
| Catalog vocabulary published | 341 |
| Topics | 20 |
| Grammar | 231 |
| Articles in catalog | 2 |
| Pronunciation | 80 |
| Videos | 18 |
| Latest version | `database-unified-v1` |

Nhận xét: dashboard có số liệu thật, nhưng nhãn “vocabulary” dễ gây hiểu nhầm vì dashboard đang đếm kho từ lớn, còn catalog user trả 341 mục published. Nên tách “Kho từ điển” và “Từ vựng bài học”.

### 3. Quản lý từ vựng

| Tiêu chí | Đánh giá |
|---|---|
| Thêm/sửa/xóa | Có UI và API admin, chưa thực hiện test ghi dữ liệu trong phiên này để tránh thay đổi DB. |
| Validate | Có validate cơ bản, nhưng cần chặn thiếu Hán tự/pinyin/nghĩa/HSK. |
| Publish sang mobile | Backend `/content/catalog` hoạt động. Cần test một record nháp -> publish -> mobile reload. |
| Rủi ro | Nếu admin ở offline mode, thay đổi không đến app user. |

### 4. Quản lý flashcard/topic

| Tiêu chí | Đánh giá |
|---|---|
| Thêm topic | Có. |
| Upload ảnh | Backend `POST /admin/media/flashcard`, static `/uploads/flashcards/...` hoạt động. |
| Ảnh hiện admin | Endpoint ảnh OK, nhưng UI vẫn có tình huống “Không xem được ảnh” do path chưa normalize đủ nhất quán. |
| Ảnh hiện mobile | Nếu DB lưu URL `/uploads/...` hoặc absolute URL, mobile cần resolve đúng theo API base. Cần test end-to-end sau publish. |
| Vấn đề asset/upload | Dữ liệu cũ dùng `assets/...` hoặc `../mobile/assets/...`; dữ liệu mới dùng `/uploads/...`. Cần một chuẩn duy nhất cho DB. |

File liên quan: `apps/admin/app.js`, `scripts/serve-admin.js`, `api/src/media.controller.ts`, `apps/mobile/lib/features/vocabulary/flashcard_repository.dart`.

### 5. Quản lý ngữ pháp

| Tiêu chí | Đánh giá |
|---|---|
| Thêm/sửa/xóa | Có UI/API, chưa test ghi. |
| Nội dung đủ | Có pattern, explanation, examples JSON. |
| Mobile hiển thị | `/content/catalog` trả grammar, mobile đọc qua repository. |
| Rủi ro | Form admin cần Dynamic Form rõ hơn cho ví dụ thay vì textarea lớn. |

### 6. Quản lý bài đọc/RSS

| Tiêu chí | Đánh giá |
|---|---|
| Thêm nguồn/bài | Có UI quản lý nguồn/bài. |
| Preview | Có mức cơ bản. |
| Kiểm RSS lỗi | RSS live chạy trong phiên này, nhưng admin cần nút “Test nguồn” và trạng thái lỗi rõ. |
| Rủi ro | Nguồn tin ngoài có nội dung chính trị/thời sự, nên demo bằng bài seed ổn định hơn. |

### 7. Quản lý luyện nói/video

| Tiêu chí | Đánh giá |
|---|---|
| Câu luyện nói | Có 80 câu published, dùng được cho user. |
| Video/transcript | Có 18 video, nhưng chỉ 4 đạt practice-ready. |
| Cảnh báo dữ liệu | Admin có cột check/trạng thái nhưng chưa đủ nổi bật về “sẽ hiện/không hiện trên app user”. |
| Video dài ít câu | Nhiều record có 4-5 câu, timestamp 0/0 hoặc span quá ngắn. Không đạt trải nghiệm shadowing. |

Quy tắc cần hiện rõ trong admin:

```text
Video hiện ở app user khi:
  có title + youtubeId
  tất cả subtitles có end_time > start_time
  số subtitles >= 8
  tổng span transcript >= 20 giây
  youtubeId không nằm trong danh sách unavailable
```

### 8. Quản lý người dùng

| Tiêu chí | Đánh giá |
|---|---|
| Xem danh sách | Có dashboard/recent users; UI user management tồn tại. |
| Tạo/sửa/khóa | Có API hướng admin, chưa test ghi. |
| Phân quyền | Backend có role `admin/user`. |
| Rủi ro | Cần đảm bảo user thường không gọi được `/admin/*`. |

### 9. UI/UX admin

| Tiêu chí | Đánh giá |
|---|---|
| CMS chuyên nghiệp | Đang ở mức demo tốt hơn trước, nhưng chưa đạt CMS thật. |
| Bảng/modal/form | Còn overflow, khoảng trắng top, sidebar scroll/bottom action chưa mượt. |
| File `app.js` | Quá lớn, monolithic, khó bảo trì. |
| Nên giữ tĩnh hay rewrite | Trước bảo vệ không nên rewrite React/Vue. Nên modular hóa nhỏ và fix UI hiện tại. |

## PHẦN 4. Đánh giá UI/UX toàn app

| Màn hình | Dễ hiểu | Chuyên nghiệp | Vấn đề chính | Ưu tiên |
|---|---|---|---|---|
| Login | Khá | Khá | Cần thông báo API/local rõ hơn; kiểm encoding | High |
| Register | Khá | Trung bình | Validate còn nhẹ; fallback dễ gây hiểu nhầm | Medium |
| Home | Khá | Khá | User mới thấy nhiều số 0; cần CTA học hôm nay rõ | High |
| Vocabulary | Khá | Khá | Cần filter HSK/topic rõ và empty state | High |
| Dictionary | Tốt | Khá | Thiếu lịch sử tra, empty state cần đẹp hơn | Medium |
| Flashcard Lesson | Tốt | Khá | Ảnh lặp/broken path nếu dữ liệu chưa chuẩn; cần ghi rõ điểm phát âm tham khảo | High |
| Grammar | Tốt | Khá | Cần đảm bảo font Hán tự/pinyin; bài quá dài cần spacing | Medium |
| AI Grammar Check | Ý tưởng tốt | Phụ thuộc API | Hiện API Gemini gọi thật lỗi 503 | Critical |
| Reading Article | Khá | Trung bình khá | Tin live hơi giống web báo; nên chuyển thành “bài đọc ngắn có tra từ” | Medium |
| Pronunciation Practice | Khá | Khá | Cần feedback rõ hơn và xin quyền mic tốt | High |
| Video Shadowing | Ý tưởng mạnh | Khá | Dữ liệu video chưa đồng đều, transcript thiếu | Critical/High |
| Profile | Khá | Trung bình khá | Cần làm rõ real progress/local progress | Medium |
| Admin Login | Khá | Khá | Offline mode cần cảnh báo mạnh | High |
| Admin Dashboard | Khá | Khá | Metric label gây hiểu nhầm; cần trạng thái dữ liệu thật | High |
| Admin Content Editor | Trung bình | Chưa đồng đều | Modal/form còn vỡ, ảnh path chưa nhất quán, app.js lớn | High |

## PHẦN 5. So sánh với đề cương đồ án

| Yêu cầu đề cương | Tình trạng hiện tại | Đánh giá | Có nên demo? | Cần sửa trước bảo vệ |
|---|---|---|---|---|
| Giao diện tiếng Việt thân thiện | Có, nhưng từng xuất hiện mojibake | Đạt một phần | Có, sau khi kiểm encoding | Fix UTF-8 toàn app và test Chrome. |
| Học từ vựng chuẩn HSK | Có HSK/topic/flashcard | Đạt | Có | Chuẩn hóa ảnh và dữ liệu demo. |
| Tra từ điển Trung - Việt | API chạy tốt | Đạt | Có | Thêm lịch sử nếu còn thời gian. |
| AI kiểm tra ngữ pháp | Có UI/backend, nhưng Gemini lỗi 503 | Chưa đạt runtime | Chỉ demo sau khi sửa | Fix key/quyền provider, fallback đẹp. |
| Luyện phát âm với nhận diện giọng nói | Có STT/TTS/scorer | Đạt một phần | Có, nói rõ tham khảo | Test mic thiết bị thật. |
| Đọc tin tức tiếng Trung và tra từ | RSS live chạy, click-to-translate có | Đạt một phần | Có, dùng bài seed/RSS ổn định | Bổ sung lưu từ từ bài đọc nếu cần. |
| Làm đề thi thử HSK | Có quiz/game, chưa thấy đề thi thử chuẩn format HSK | Đạt một phần | Không gọi là “đề thi thử HSK” | Demo là quiz luyện từ. |
| Theo dõi tiến độ học tập | Có local + API best-effort | Đạt một phần | Có | Chuẩn bị user demo có dữ liệu. |
| Đặt mục tiêu hằng ngày | Có | Đạt | Có | Test save/reload. |
| Minigame ghi nhớ từ vựng | Có | Đạt một phần | Có ngắn | Dữ liệu và hướng dẫn rõ. |
| Admin quản lý học liệu | Có admin + publish | Đạt một phần | Có | Test publish end-to-end 1 item. |
| Đồng bộ dữ liệu đa thiết bị | Có backend nhưng nhiều local fallback | Đạt một phần thấp | Không nhấn mạnh | Nói “đồng bộ học liệu qua backend”, không hứa full user sync. |
| Backend/API/database | Có NestJS + PostgreSQL | Đạt | Có | Script dev phải chạy ổn. |
| Bảo mật API key AI | Key nằm backend, nhưng quyền lỗi | Đạt một phần | Chỉ demo sau fix | Không để key trong mobile; kiểm `.env`. |

## PHẦN 6. Đề xuất thêm/bớt/thay đổi tính năng

### 1. Nên giữ và làm nổi bật khi bảo vệ

| Tính năng | Lý do |
|---|---|
| Flashcard HSK có ảnh + nghe + ghi âm | Dễ nhìn, đúng trọng tâm học ngoại ngữ. |
| Từ điển Trung - Việt | Runtime đã test tốt, có dữ liệu thật. |
| Đọc bài và click từ để tra nghĩa | Tạo khác biệt so với app flashcard đơn giản. |
| Luyện phát âm có chấm điểm tham khảo | Có backend scorer, trả điểm trung gian. |
| Progress/streak/mục tiêu ngày | Cho thấy app có vòng lặp học tập. |
| Admin publish học liệu | Thể hiện backend/database/admin, phù hợp đồ án. |

### 2. Nên thêm nếu còn thời gian

| Tính năng | Mức effort | Lợi ích |
|---|---|---|
| Onboarding chọn HSK | Vừa | Người mới hiểu luồng học. |
| Gợi ý “Bài học hôm nay” | Vừa | Home bớt trống khi user mới. |
| Lịch sử tra từ | Nhỏ-vừa | Tăng cảm giác app học thật. |
| Lịch sử AI grammar hiển thị rõ | Nhỏ | Dễ demo tiến bộ học tập. |
| Bộ dữ liệu demo phát âm/video ổn định | Vừa | Giảm rủi ro khi bảo vệ. |
| Admin badge “Sẽ hiện trên app user” | Nhỏ | Giải thích mismatch admin-user. |

### 3. Nên tạm ẩn hoặc giảm phạm vi

| Tính năng | Lý do |
|---|---|
| RSS live | Phụ thuộc mạng/nguồn ngoài; nên có fallback seed. |
| Video chưa đủ transcript | Nhiều video không đạt practice-ready; chỉ demo 1-2 video chuẩn. |
| AI grammar nếu chưa sửa key | Gọi thật đang 503; demo fallback sẽ yếu. |
| Chấm phát âm như “chuẩn tuyệt đối” | Hiện là STT + so khớp text/pinyin, nên gọi là tham khảo. |

### 4. Không nên làm thêm lúc này

| Không nên làm | Lý do |
|---|---|
| Viết lại toàn bộ admin bằng React/Vue | Rủi ro lớn trước bảo vệ. |
| Làm đủ HSK 1-6 toàn bộ dữ liệu | Tốn dữ liệu, không tăng nhiều điểm demo nếu chưa sạch. |
| Thêm nhiều game | Dễ loãng sản phẩm, khó test. |
| Social/community | Phạm vi quá lớn. |
| Production auth/JWT hoàn chỉnh | Nên để sau bảo vệ nếu hệ thống demo đang ổn. |

## PHẦN 7. Checklist sửa trước khi bảo vệ

### Critical - bắt buộc sửa trước khi demo

| Việc cần sửa | Lý do | File/khu vực |
|---|---|---|
| Fix Gemini `/grammar/check` gọi thật | Hiện lỗi 503, demo AI sẽ fail | `api/src/app.service.ts`, `.env`, Google AI/Gemini config |
| Chốt quy trình chạy dev ổn định | User từng gặp API/admin không lên | `scripts/start-vnchinese-dev.ps1`, `api/server-prod.error.log` |
| Chuẩn hóa API base URL theo nền tảng | Android/emulator sẽ fail nếu dùng localhost | `apps/mobile/lib/core/config/app_config.dart` |
| Kiểm và fix encoding UTF-8 | Từng có mojibake tiếng Việt | toàn bộ `apps/mobile`, `api`, `apps/admin` |
| Chọn 1-2 video demo có transcript chuẩn | 14/18 video không đủ điều kiện user | `api` DB video transcript, `apps/admin` video QA |
| Test admin publish end-to-end | Đồ án cần chứng minh admin -> backend -> app | `apps/admin/app.js`, `api/src/content.service.ts` |

### High - rất nên sửa

| Việc cần sửa | Lý do |
|---|---|
| Làm loading/error/empty state đẹp hơn cho AI/RSS/dictionary | Tránh cảm giác app lỗi khi API ngoài fail. |
| Chuẩn hóa ảnh flashcard: DB lưu URL/path một kiểu | Tránh admin thấy “Không xem được ảnh”. |
| Admin hiển thị badge “visible in user app” cho video/topic/bài học | Giải thích khác biệt admin-user. |
| Fix layout admin: bỏ khoảng trắng top, sidebar/footer action không bị kẹt | Admin đang có cảm giác vỡ giao diện. |
| Tạo user demo có progress thật | Home/Profile đỡ toàn số 0. |

### Medium - sửa nếu còn thời gian

| Việc cần sửa | Lý do |
|---|---|
| Thêm lịch sử tra từ | Tăng trải nghiệm học. |
| Cải thiện profile/statistics | Demo đẹp hơn. |
| Làm rõ quiz/game là tự tạo từ flashcard | Người chấm hiểu nguồn dữ liệu. |
| Refactor nhỏ `apps/admin/app.js` thành module | Dễ bảo trì, nhưng không bắt buộc cho demo. |

### Low - để sau bảo vệ

| Việc cần sửa | Lý do |
|---|---|
| Rewrite admin sang React/Vue | Lớn, rủi ro. |
| Auth/JWT production-grade | Cần sau khi sản phẩm ổn. |
| Đồng bộ đa thiết bị hoàn chỉnh | Phạm vi lớn. |
| Mở rộng HSK 5-6 đầy đủ | Dữ liệu phải sạch, không nên làm vội. |

## PHẦN 8. Định hướng demo bảo vệ 5-7 phút

### Chuẩn bị trước demo

```text
1. Chạy Docker/Postgres và API.
2. Mở admin tại http://127.0.0.1:8080.
3. Mở app user bằng nền tảng đã test chắc.
4. Test ngay:
   - /health
   - đăng nhập user demo
   - /grammar/check với một câu thật
   - 1 video shadowing chuẩn
5. Chuẩn bị tài khoản demo có progress, vài từ đã lưu.
```

### Kịch bản đề xuất

| Thời lượng | Màn/luồng | Nội dung demo |
|---:|---|---|
| 0:00-0:45 | Login/Home | Đăng nhập user demo, giới thiệu mục tiêu ngày/streak/shortcut. |
| 0:45-1:45 | Flashcard | Chọn HSK/topic, xem ảnh/Hán tự/pinyin/nghĩa, nghe TTS, lưu từ. |
| 1:45-2:20 | Dictionary | Tra `你好` hoặc một từ HSK, xem ví dụ và lưu. |
| 2:20-3:05 | Grammar | Mở bài ngữ pháp theo HSK, xem mẫu câu/ví dụ. |
| 3:05-3:50 | AI Grammar | Chỉ demo nếu API đã sửa; nhập câu sai/đúng và xem feedback. |
| 3:50-4:35 | Reading | Mở bài đọc seed/RSS ổn định, click từ để hiện pinyin/nghĩa. |
| 4:35-5:20 | Pronunciation | Nghe mẫu, ghi âm một câu ngắn, giải thích điểm tham khảo. |
| 5:20-6:05 | Video Shadowing | Demo video đã chọn, auto-pause cuối câu, ghi âm, chuyển câu. |
| 6:05-7:00 | Admin | Vào admin, cho thấy quản lý flashcard/video, badge publish, giải thích dữ liệu đẩy qua backend. |

### Nên tránh trong demo

| Tránh demo | Lý do |
|---|---|
| Video có 4-5 câu hoặc timestamp 0/0 | Dễ bị hỏi vì sao video dài mà ít phụ đề. |
| RSS live nếu mạng yếu | Có thể timeout hoặc nội dung không phù hợp. |
| AI grammar nếu chưa test pass ngay trước buổi bảo vệ | Hiện đang lỗi 503. |
| Admin offline mode | Dễ làm người chấm hiểu nhầm là đã publish thật. |
| Đăng ký tài khoản mới nếu backend không chắc | Login demo account an toàn hơn. |

### Phương án dự phòng

| Nếu lỗi | Dự phòng |
|---|---|
| AI fail | Dùng fallback local, nói rõ hệ thống có kiến trúc backend AI nhưng key demo chưa cấp quyền; tốt nhất sửa trước. |
| RSS fail | Dùng bài đọc seed trong catalog. |
| Mic không nhận | Demo TTS và cho xem cơ chế điểm bằng dữ liệu đã ghi/hoặc câu ngắn đã test. |
| Admin không lên | Mở report/ảnh chụp admin, nhưng cần sửa script để tránh tình huống này. |

## PHẦN 9. Kết luận cuối cùng

### 1. App hiện tại đã đủ để bảo vệ đồ án chưa?

Đủ để bảo vệ nếu sửa các lỗi Critical và demo theo phạm vi kiểm soát. Chưa đủ để demo tự do toàn bộ chức năng, đặc biệt là AI, video và admin publish.

### 2. Nếu chấm theo sản phẩm sinh viên, app đạt mức nào?

Ở trạng thái hiện tại: khoảng 7.0-7.5/10 do có nhiều module và backend thật nhưng còn lỗi runtime/UX/dữ liệu. Nếu sửa Gemini, encoding, video demo data và admin publish end-to-end: có thể lên 8.0-8.5/10 cho đồ án sinh viên.

### 3. Ba điểm mạnh nhất

| Điểm mạnh | Lý do |
|---|---|
| Phạm vi tính năng rộng và đúng đề tài | Từ vựng, từ điển, ngữ pháp, đọc, phát âm, video, tiến độ, admin. |
| Có backend/database/admin thật | Không chỉ là UI tĩnh; có PostgreSQL, API, auth, content catalog. |
| Một số luồng học có giá trị thật | Dictionary chạy tốt, pronunciation có scorer, reading click-to-translate, flashcard có ảnh/TTS. |

### 4. Ba điểm yếu nguy hiểm nhất

| Điểm yếu | Vì sao nguy hiểm |
|---|---|
| Gemini gọi thật đang lỗi 503 | AI grammar là điểm nhấn đề cương; demo fail sẽ mất điểm mạnh. |
| Dữ liệu video/admin chưa đồng nhất với app user | Admin thấy 18 video nhưng user chỉ thấy 4, dễ bị hỏi và khó giải thích nếu UI không cảnh báo. |
| Encoding/API environment chưa ổn định | Mojibake hoặc localhost sai nền tảng làm app trông thiếu chuyên nghiệp. |

### 5. Trong 3 ngày cuối nên sửa gì?

```text
1. Fix Gemini key/quyền và test /grammar/check thật.
2. Chuẩn hóa encoding UTF-8, test toàn bộ màn chính trên Chrome/mobile.
3. Chọn và sửa 1-2 video shadowing chuẩn để demo.
4. Fix admin layout, ảnh preview, badge dữ liệu sẽ hiện ở user.
5. Chuẩn bị user demo + seed data + checklist chạy trước bảo vệ.
```

### 6. Trong 1 tuần cuối nên sửa gì?

```text
1. Hoàn thiện admin publish end-to-end cho flashcard/grammar/video.
2. Thêm empty/loading/error state đẹp cho AI/RSS/API fail.
3. Thêm lịch sử tra từ hoặc cải thiện history AI.
4. Viết smoke test ngắn cho backend health, auth, dictionary, content catalog.
5. Làm tài liệu hướng dẫn chạy demo rõ ràng.
```

### 7. Nếu chỉ được sửa 5 việc

| Thứ tự | Việc |
|---:|---|
| 1 | Fix Gemini `/grammar/check` gọi thật. |
| 2 | Fix encoding tiếng Việt/tiếng Trung toàn app. |
| 3 | Chốt script chạy backend/admin/mobile và API base URL theo nền tảng. |
| 4 | Chuẩn hóa dữ liệu video: chỉ publish/hiển thị video practice-ready. |
| 5 | Fix admin ảnh/publish end-to-end và layout không overflow. |

## Kết luận thực dụng cho đồ án

VNChinese có nền tảng tốt và đủ “chất đồ án” vì đã vượt khỏi mức app tĩnh: có Flutter app, backend, database, admin, AI endpoint, RSS, pronunciation scoring và quản lý tiến độ. Điểm cần làm bây giờ không phải thêm nhiều chức năng mới, mà là làm cho những luồng demo chính chạy chắc, dữ liệu sạch và giao diện không vỡ. Nên tập trung bảo vệ quanh 6 điểm: flashcard HSK, từ điển, ngữ pháp/AI, bài đọc click-to-translate, luyện phát âm, admin quản lý học liệu.

Bạn có muốn tôi bắt đầu sửa theo checklist ưu tiên không?

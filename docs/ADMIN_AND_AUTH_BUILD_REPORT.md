# Báo cáo build Admin, Database và Auth VNChinese

Ngày cập nhật: 2026-06-04

## 1. Admin VNChinese

Admin hiện nằm tại:

```text
apps/admin/index.html
```

Các phần đã chỉnh:

- Đổi toàn bộ nhận diện từ `Magic Chinese` sang `VNChinese`.
- Chỉnh màu giao diện theo app mobile: nền giấy ấm, đỏ cinnabar, màu mực tối, sidebar cùng tinh thần với màn đăng nhập app.
- Đổi localStorage key sang `vnchinese_admin_state_v2` để tránh dùng lại dữ liệu admin cũ.
- Thêm `Mobile asset root`, mặc định `../mobile/assets`, để admin dựng đường dẫn ảnh flashcard từ bundle mobile.
- Thêm panel `Kết nối với app VNChinese` ở dashboard để nhìn nhanh nguồn index, số topic publish và API base URL.
- Thêm nút `Kiểm tra API` trong cấu hình, gọi thử endpoint `/profile`.
- Đổi export bundle thành `vnchinese-content-YYYY-MM-DD.json`.

## 2. Flashcard và ảnh

Nguồn flashcard mobile:

```text
apps/mobile/assets/images/flashcards/index.json
```

Các phần đã chỉnh:

- Admin import được `index.json` và tự dựng preview ảnh theo `topic.id + image`.
- Card flashcard có fallback rõ: nếu ảnh lỗi đường dẫn, admin hiển thị thông báo thay vì để ô ảnh trống.
- Thêm nút `Đăng ảnh` cho từng topic. Ảnh được đọc bằng `FileReader`, lưu vào state admin dưới dạng preview và hiện ngay.
- Khi export, admin không nhét chuỗi base64 vào field `image`; admin dùng tên file upload để bundle sạch hơn.
- Thêm topic thật `media_society` cho `Truyền thông và xã hội` vào mobile bundle.
- Topic `media_society` có 10 từ, đủ Hán tự, pinyin, nghĩa Việt và 10 ảnh riêng trong thư mục:

```text
apps/mobile/assets/images/flashcards/media_society/
```

Lưu ý quan trọng: admin hiện là web tĩnh, nên trình duyệt không thể tự ghi ảnh upload vào thư mục source code. Khi publish thật cần copy ảnh vào asset hoặc xây backend upload media.

## 3. Database hiện tại

Backend đang dùng NestJS + TypeORM + PostgreSQL:

```text
api/src/app.module.ts
```

Các entity hiện có:

- `users`
- `user_progress`
- `course_levels`
- `lessons`
- `vocabularies`
- `example_sentences`
- `grammar`
- `articles`
- `quiz_questions`

Đã bổ sung:

- Auth API dùng bảng `users`.
- Mật khẩu hash bằng `scrypt` của Node, không cần thêm dependency.
- Seed SQL đổi brand sang VNChinese và thêm tài khoản dev:
  - `admin@vnchinese.local` / `admin123`
  - `student@vnchinese.local` / `student123`

Nên bổ sung khi lên production:

- `refresh_tokens` hoặc `sessions` để quản lý phiên đăng nhập dài hạn.
- `password_reset_tokens` cho quên mật khẩu.
- `flashcard_topics` và `flashcard_words` nếu muốn quản lý flashcard trực tiếp trong DB thay vì chỉ JSON asset.
- `media_assets` để upload, preview, duyệt và gắn ảnh vào flashcard.
- `content_versions` để quản lý publish/rollback bundle.
- `admin_audit_logs` để ghi lại ai sửa/xóa/duyệt nội dung.
- `user_saved_words` cho sổ tay từ mới thật theo từng user.
- `user_daily_goals` hoặc mở rộng `user_progress` để lưu mục tiêu học.

`synchronize: true` đang phù hợp dev, nhưng khi production nên tắt và chuyển sang migration.

## 4. Luồng đăng ký/đăng nhập app

Mobile:

```text
apps/mobile/lib/auth_service.dart
apps/mobile/lib/main.dart
```

Luồng chạy:

1. `AuthGate` mở app và gọi `AuthService.restoreSession()`.
2. Nếu có session đã lưu, app vào `MainScreen`.
3. Nếu chưa có session, app hiển thị form đăng nhập/đăng ký.
4. Đăng ký kiểm tra họ tên, email, mật khẩu và xác nhận mật khẩu.
5. Đăng nhập/đăng ký ưu tiên gọi backend:

```text
POST /auth/login
POST /auth/register
```

6. Nếu backend chưa chạy, mobile dùng fallback local bằng `SharedPreferences` để vẫn test được app.
7. Nút `Học thử không cần tài khoản` tạo session guest.
8. Đăng xuất xóa session và quay lại màn auth.

Backend:

```text
api/src/auth.controller.ts
api/src/auth.service.ts
```

Endpoint đã thêm:

- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/me?token=...`

## 5. Hướng build admin hoàn chỉnh

MVP hiện tại:

- Web tĩnh quản lý nội dung local.
- Import/export JSON.
- QA dữ liệu thiếu pinyin/nghĩa/ảnh.
- Preview ảnh và upload preview.
- Kiểm tra kết nối API.

Bản admin production nên phát triển tiếp:

- Đăng nhập admin bằng role `admin`, `editor`, `reviewer`.
- Kết nối DB thật qua API, không chỉ `localStorage`.
- Upload ảnh qua endpoint media, lưu vào `media_assets`.
- CRUD flashcard topic/word trực tiếp trong DB.
- Workflow `draft -> review -> published -> archived`.
- Lịch sử chỉnh sửa và rollback phiên bản content.
- Dashboard lỗi dữ liệu, ảnh thiếu, từ chưa có ví dụ, topic học nhiều.
- Công cụ export bundle cho mobile offline và đồng bộ backend.

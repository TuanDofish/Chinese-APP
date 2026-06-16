# VNChinese Admin

Admin web tĩnh để quản lý nội dung VNChinese. Khi đăng nhập trực tuyến, dữ liệu được đọc và xuất bản vào PostgreSQL thông qua backend NestJS; `localStorage` chỉ là bộ nhớ đệm/phương án chỉnh sửa offline.

## Cách mở

Mở trực tiếp file:

```text
apps/admin/index.html
```

Không cần `npm install`. Backend phải chạy tại URL cấu hình, mặc định `http://127.0.0.1:3001`. Dữ liệu PostgreSQL là nguồn chính; bản trong `localStorage` dùng để tránh mất nội dung đang chỉnh sửa khi tải lại trang.

## Liên kết với app mobile

- Import nguồn flashcard từ `apps/mobile/assets/images/flashcards/index.json` bằng nút `Import JSON` hoặc `Nạp index mobile`.
- Admin dựng preview ảnh theo cấu hình `Mobile asset root`, mặc định là `../mobile/assets`.
- Export `flashcard-index.admin-export.json` để cập nhật lại bundle flashcard của app.
- Export `vnchinese-content-YYYY-MM-DD.json` để lưu toàn bộ nội dung admin.

## Upload ảnh flashcard

Nút `Đăng ảnh` đọc file ảnh bằng trình duyệt và preview ngay trong admin. Vì admin đang là file tĩnh, trình duyệt không thể tự ghi ảnh vào thư mục `apps/mobile/assets`; khi publish thật cần một trong hai cách:

1. Copy ảnh vào thư mục topic tương ứng trong `apps/mobile/assets/images/flashcards/<topic_id>/`.
2. Dùng backend upload media riêng và lưu URL/asset path trả về.

## Quy trình đề xuất

1. Chạy PostgreSQL và backend.
2. Mở `apps/admin/index.html`, đăng nhập tài khoản admin.
3. Admin tự tải từ vựng, topic, bài học, video, phát âm, nguồn đọc và người dùng từ backend.
4. Sửa nội dung, bấm `✓` để chạy QA.
5. Bấm `Xuất bản`; backend upsert dữ liệu trong một transaction.
6. Backend tạo `content_versions` và ghi thao tác vào `admin_audit_logs`; app mobile đọc dữ liệu mới qua `/content/*`.

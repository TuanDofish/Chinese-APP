# Tích hợp cơ sở dữ liệu VNChinese

## Nguồn dữ liệu thống nhất

PostgreSQL là nguồn dữ liệu chính cho backend, mobile và admin. Mô hình đích gồm 20 bảng trong:

`docs/chuong-2/schema/chinese_learning_app.sql`

Ba bảng cũ `grammar`, `example_sentences`, `user_progress` chỉ được giữ tạm để các endpoint TypeORM cũ tiếp tục hoạt động. Không thêm dữ liệu nghiệp vụ mới vào ba bảng này.

## Luồng dữ liệu

- Admin đăng nhập qua `/auth/login`, tải catalog bằng `/admin/content`.
- Khi bấm **Xuất bản**, admin gửi catalog đến `PUT /admin/content`.
- Backend upsert dữ liệu trong một transaction, tạo `content_versions` và ghi `admin_audit_logs`.
- Mobile ưu tiên dữ liệu từ `/content/*`; asset Flutter là dữ liệu dự phòng khi offline.
- Tiến độ trên thiết bị vẫn được lưu cục bộ và đồng bộ lên `/learning/*` khi người dùng đăng nhập.
- Lỗi và kết quả Gemini được ghi vào `ai_interactions`.

## Endpoint nội dung

| Endpoint | Dữ liệu |
| --- | --- |
| `GET /content/flashcards` | Topic, từ và ví dụ flashcard |
| `GET /content/grammar` | Ngữ pháp HSK 1-4 |
| `GET /content/pronunciation` | Câu luyện phát âm |
| `GET /content/videos` | Video và transcript có timing |
| `GET /content/articles` | Bài đọc trong PostgreSQL |
| `GET /reading/news` | Tin RSS đang hoạt động |
| `GET /dictionary/*` | Từ điển và ví dụ |

## Endpoint tiến độ

Các endpoint sau yêu cầu `Authorization: Bearer <token>`:

- `GET /learning/summary`
- `PUT /learning/goal`
- `PUT /learning/words/:word`
- `POST /learning/attempts`
- `POST /learning/reading`
- `POST /learning/study-time`

## Khởi động

```powershell
docker compose up -d postgres
cd api
npm run seed:app-data
npm run build
npm run start:prod
```

Admin dùng API mặc định `http://127.0.0.1:3001`. Mobile web dùng `http://localhost:3001`. Khi chạy trên điện thoại thật, truyền địa chỉ máy phát triển:

```powershell
flutter run --dart-define=API_BASE_URL=http://<IP-MAY-TINH>:3001
```

`DB_SYNC` mặc định tắt. Chỉ bật `DB_SYNC=true` trong môi trường phát triển đặc biệt; schema chuẩn phải được quản lý bằng file SQL và script seed.

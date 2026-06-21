# Cấu Hình Google Sign-In Cho VNChinese

Google Sign-In đã được tích hợp ở Flutter và backend. Để nút Google đăng nhập thật, dự án vẫn cần **Google OAuth Client ID** của chính dự án VNChinese. Gemini API key không thể dùng thay OAuth Client ID.

## 1. Tạo OAuth Client ID

Trong Google Cloud Console của tài khoản sở hữu dự án VNChinese:

1. Chọn hoặc tạo project Google Cloud.
2. Hoàn tất OAuth consent screen với tên ứng dụng `VNChinese`.
3. Dùng Web OAuth client của VNChinese:
   `567840262106-filnk22a2fdh33vildrem5npg1kb4qmg.apps.googleusercontent.com`.
4. Thêm authorized JavaScript origins cho môi trường demo, ví dụ:
   - `http://localhost:7357`
   - `http://127.0.0.1:7357`
5. Sao chép Client ID dạng `...apps.googleusercontent.com`. Client ID là định danh công khai, nhưng không đưa Gemini key hoặc client secret vào Flutter.

Android OAuth client hiện tại:

- Client ID: `567840262106-4snod22r9mcm9gm1g4pbmvlinoufrnib.apps.googleusercontent.com`
- Package: `com.vnchinese.app`
- SHA-1: `95:02:E0:13:83:8C:2C:3A:98:C3:49:48:30:96:E2:0B:F3:29:2B:E7`

Android dùng Web Client ID làm `serverClientId`; Android Client ID được Google
chọn tự động từ package và SHA-1.

## 2. Cấu hình backend

Trong `api/.env`, thêm Client ID Web (không thêm client secret):

```env
GOOGLE_OAUTH_CLIENT_IDS=567840262106-filnk22a2fdh33vildrem5npg1kb4qmg.apps.googleusercontent.com,567840262106-4snod22r9mcm9gm1g4pbmvlinoufrnib.apps.googleusercontent.com
```

Khởi động lại API sau khi thay đổi. Endpoint `POST /auth/google` sẽ kiểm tra ID token với audience này, sau đó tạo hoặc cập nhật user trong PostgreSQL.

## 3. Chạy Flutter Web ở port cố định

Google kiểm tra origin chính xác nên không dùng port ngẫu nhiên khi demo:

```powershell
.\scripts\start-vnchinese-web.ps1
```

Trong VS Code, mở **Run and Debug** và chọn
`VNChinese Web (Google OAuth)`. Không dùng cấu hình Dart mặc định vì Flutter
sẽ chọn port ngẫu nhiên như `50899`, làm Google trả `Error 400:
origin_mismatch`.

Nếu chạy thủ công:

```powershell
cd "apps/mobile"
flutter run -d chrome --web-hostname localhost --web-port 7357 --dart-define=API_BASE_URL=http://localhost:3001 --dart-define=GOOGLE_WEB_CLIENT_ID=567840262106-filnk22a2fdh33vildrem5npg1kb4qmg.apps.googleusercontent.com
```

## 4. Kiểm tra

1. API: `GET http://localhost:3001/health` phải trả về `status: ok`.
2. Mở `http://localhost:7357` và bấm nút Google chính thức.
3. Sau khi chọn tài khoản, app gọi `POST /auth/google`.
4. User mới xuất hiện trong PostgreSQL và vào thẳng màn hình chính.

Khi Client ID chưa được cấu hình, app vẫn chạy bằng email/guest và hiển thị thông báo rõ ràng thay vì lỗi vỡ giao diện.

# Báo cáo khảo sát hệ thống Admin hiện tại

**Dự án:** VNChinese - ứng dụng học tiếng Trung  
**Phạm vi khảo sát:** `apps/admin/`, `scripts/serve-admin.js`, `scripts/start-vnchinese-dev.ps1`, các endpoint NestJS liên quan trong `api/src/*controller.ts`  
**Ngày khảo sát:** 18/06/2026

## 1. Tóm tắt hiện trạng

Admin hiện tại là một **web admin tĩnh viết bằng HTML/CSS/JavaScript thuần**, không dùng React, Vue, Angular hay Flutter Web. Toàn bộ giao diện, state, logic nhập liệu, render bảng, modal editor, QA, import/export và gọi API đang tập trung chủ yếu trong một file lớn: `apps/admin/app.js`.

Admin hỗ trợ hai chế độ vận hành:

- **Online admin:** đăng nhập qua NestJS API, tải dữ liệu từ backend/PostgreSQL và xuất bản lại qua `/admin/content`.
- **Offline admin:** không đăng nhập, làm việc với dữ liệu mẫu hoặc dữ liệu đang lưu trong `localStorage`, có thể export JSON thủ công.

Hiện đã có script khởi động riêng để chạy đủ bộ:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\start-vnchinese-dev.ps1
```

Script này bật Docker/PostgreSQL, API NestJS và admin static server. Admin static server hiện dùng Node (`scripts/serve-admin.js`) và có proxy `/api` để giảm lỗi CORS/khác host.

## 2. Cấu trúc thư mục và công nghệ

| Khu vực | File/thư mục | Vai trò hiện tại |
|---|---|---|
| Admin UI | `apps/admin/index.html` | Khung HTML chính: login form, sidebar, topbar, dialog editor, toast, import image/input. |
| Admin logic | `apps/admin/app.js` | Toàn bộ state, render UI, event handler, editor form, import/export, QA, API client. |
| Admin style | `apps/admin/styles.css` | CSS thuần cho layout sidebar, bảng, card, dialog, responsive. |
| Tài liệu cũ | `apps/admin/README.md` | Hướng dẫn mở admin, import/export, liên kết mobile. Một số mô tả chưa theo kịp logic mới. |
| Static server | `scripts/serve-admin.js` | Node HTTP server phục vụ file admin và proxy `/api/*` sang API `3001`. |
| Dev startup | `scripts/start-vnchinese-dev.ps1` | Khởi động Docker, PostgreSQL/Redis, NestJS API và admin server. |
| Backend auth/user | `api/src/auth.controller.ts` | Login, user admin, dashboard. |
| Backend content | `api/src/content.controller.ts` | Catalog/content publish, audit logs, content public endpoints. |
| Backend health/AI | `api/src/app.controller.ts` | `/health`, `/ai/chat`, `/pronunciation/score`, image suggestion. |

### Công nghệ đang dùng

| Thành phần | Công nghệ |
|---|---|
| Frontend admin | HTML5, CSS3, JavaScript thuần |
| State frontend | Object `state` trong memory + `localStorage` key `vnchinese_admin_state_v2` |
| Auth session | `sessionStorage`: `vnchinese_admin_token`, `vnchinese_admin_user` |
| Dialog nhập liệu | Native `<dialog>` + form tự render bằng JS |
| API client | `fetch()` bọc qua `fetchApi()` và `apiFetch()` |
| Static serving | Node `http.createServer()` |
| Backend | NestJS |
| Database chính | PostgreSQL qua backend |
| Admin online auth | Bearer token tự ký từ backend |

## 3. Kiến trúc frontend hiện tại

Admin không có router framework. Sidebar lưu view hiện tại bằng biến:

```text
activeView = dashboard | vocabulary | flashcards | lessons | videos | reading | speaking | games | users | ai | review | settings
```

Khi bấm menu:

```text
click nav-item
  -> activeView = button.dataset.view
  -> render()
  -> render map chọn đúng hàm renderX()
  -> viewRoot.innerHTML = ''
  -> appendChild(renderer())
```

State chính:

```text
seedState
  vocabulary[]
  flashcards[]
  lessons[]
  grammar[]
  readingSources[]
  articles[]
  pronunciation[]
  games[]
  aiSettings
  users[]
  review[]
  auditLogs[]
  dashboard
  settings
```

Khi tải trang:

```text
loadState()
  -> đọc localStorage(vnchinese_admin_state_v2)
  -> normalizeState()
  -> nếu lỗi thì dùng seedState
```

Khi lưu:

```text
saveState()
  -> localStorage.setItem(STORAGE_KEY, JSON.stringify(state))
```

## 4. Feature Inventory

### 4.1 Thanh điều hướng và chức năng chính

| Menu | View key | Nội dung hiển thị | Nút/thao tác chính |
|---|---:|---|---|
| Tổng quan | `dashboard` | Metric người dùng, học viên hoạt động, phút học, nội dung publish, video đã timing; biểu đồ nhập học 7 ngày; phân bổ HSK; tình trạng QA; luồng publish; kết nối app; test AI; nhật ký gần đây. | Đồng bộ dashboard, Tải lại nội dung DB, Đồng bộ users, Test câu sai mẫu. |
| Từ vựng | `vocabulary` | Bảng từ vựng: Hán tự, pinyin, nghĩa Việt, HSK, loại từ, trạng thái. Có filter HSK và search toàn cục. | Thêm từ, Sửa, Xóa/lưu trữ. |
| Flashcard | `flashcards` | Lưới topic flashcard, ảnh preview, trạng thái, số từ, danh sách từ rút gọn. Có hướng dẫn nhập topic. | Import JSON, Nạp từ app user, Thêm topic, Xuất index, Sửa, Đăng ảnh, Nhân bản, Xóa/lưu trữ. |
| Bài học | `lessons` | Bảng bài học tổng hợp gồm nhiều loại: Ngữ pháp, Đọc hiểu, Video. Bên dưới có bảng mẫu ngữ pháp HSK. | Thêm bài, Sửa, Xóa/lưu trữ; Thêm ngữ pháp, Sửa ngữ pháp, Lưu trữ ngữ pháp. |
| Video & transcript | `videos` | Metric video, số video đã timing, số cần timing, số đang publish; bảng video gồm title, YouTube ID, HSK, số phụ đề, trạng thái timing, trạng thái publish. | Xuất video catalog, Thêm video, Transcript/Sửa, Xóa/lưu trữ. |
| Đọc hiểu | `reading` | Bảng nguồn RSS/API; mô tả luồng đọc; bảng bài đọc trong PostgreSQL gồm source, HSK, title, summary, status. | Kiểm tra RSS, Thêm nguồn, Sửa nguồn, Bật/tắt nguồn, Thêm bài đọc, Sửa bài đọc, Lưu trữ bài đọc. |
| Luyện nói | `speaking` | Metric số câu luyện nói, published, số tình huống, dữ liệu thiếu; bảng câu gồm HSK, topic, câu Trung, pinyin, nghĩa Việt, trạng thái. | Nạp từ app user, Thêm câu, Sửa, Xóa/lưu trữ. |
| Quiz & trò chơi | `games` | Bảng trò chơi: tên, loại, phạm vi dữ liệu, trạng thái. | Thêm trò chơi, Sửa, Xóa/lưu trữ. |
| Người dùng | `users` | Metric user, active, blocked, admin; bảng user gồm tên, email, vai trò, mục tiêu, tiến độ, lần đăng nhập cuối, trạng thái. | Đồng bộ API, Thêm user, Chi tiết, Sửa, Khóa/Mở. |
| Trung tâm AI | `ai` | Metric trạng thái AI grammar, tutor, level mặc định, provider; textarea prompt gia sư. | Test chấm ngữ pháp, Test chatbot, Kiểm tra health. |
| Kiểm duyệt | `review` | Hàng chờ QA/review gồm area, title, issue, severity. | Duyệt tất cả, Chạy QA, Duyệt từng mục. |
| Cấu hình | `settings` | Các setting hệ thống: API base URL, content version, reviewer policy, export target, mobile asset root. | Lưu từng setting, Kiểm tra API, Test AI ngữ pháp, Xuất content bundle, Xuất flashcard index, Khôi phục mẫu. |

### 4.2 Topbar và thao tác toàn cục

| Thành phần | Chức năng |
|---|---|
| `adminIdentity` | Hiển thị user admin online hoặc offline admin. |
| `apiStatus` | Hiển thị trạng thái API: chưa kiểm tra, online, warning, offline. |
| `Xuất bản` | Publish toàn bộ content hiện tại lên backend `/admin/content`. |
| Search box | Tìm toàn cục trong view hiện tại. |
| QA button | Chạy `runQualityChecks()` và chuyển sang view kiểm duyệt. |
| Reset button | Khôi phục dữ liệu mẫu `seedState`. |
| Export bundle | Xuất toàn bộ state thành file JSON. |
| Import JSON | Import `flashcard index` hoặc content bundle. |
| Logout | Xóa session token trong `sessionStorage`. |

## 5. Data Workflows

### 5.1 Luồng đăng nhập Admin

```text
Admin nhập email/password
  -> loginAdmin()
  -> fetchApi('/auth/login', POST)
     -> thử lần lượt:
        1. state.settings.apiBaseUrl
        2. /api proxy cùng origin
        3. http(s)://<current-host>:3001
        4. http://127.0.0.1:3001
        5. http://localhost:3001
  -> backend trả user + token
  -> lưu token vào sessionStorage
  -> enterAdmin(true)
     -> loadAdminDashboard()
     -> loadPublishedContent()
     -> loadBackendUsers()
     -> loadAuditLogs()
  -> render dashboard/admin shell
```

Nếu API không sẵn sàng, login form hiển thị lỗi hướng dẫn chạy `scripts/start-vnchinese-dev.ps1`.

### 5.2 Luồng Offline Admin

```text
Click "Quản lý nội dung offline"
  -> enterAdmin(false)
  -> không gọi backend
  -> render dữ liệu từ localStorage hoặc seedState
  -> có thể sửa/import/export
  -> không publish online nếu chưa có adminToken
```

### 5.3 Luồng thêm/sửa từ vựng

Editor fields:

| Field | Dạng |
|---|---|
| `simplified` | input |
| `pinyin` | input |
| `meaningVi` | input |
| `hsk` | select HSK 1-6 |
| `type` | input |
| `status` | select draft/review/published/archived |

JSON lưu trong `state.vocabulary[]`:

```json
{
  "id": "generated-or-existing-id",
  "simplified": "你好",
  "pinyin": "nǐ hǎo",
  "meaningVi": "xin chào",
  "hsk": "HSK 1",
  "type": "cụm từ",
  "status": "published"
}
```

Flow:

```text
Thêm/Sửa từ
  -> openVocabularyEditor()
  -> openEditor()
  -> onSave()
  -> upsert('vocabulary', item)
  -> saveState()
  -> render()
```

### 5.4 Luồng thêm/sửa Flashcard

Hiện tại editor chính đã chuyển sang **Dynamic Grid**, không còn nhập bằng một textarea lớn. Tuy nhiên trong code vẫn còn helper legacy `parseWords(text)` và README vẫn nhắc format `|`, đây là dấu hiệu tài liệu/logic cũ chưa được dọn hoàn toàn.

Thông tin topic:

| Field | Dạng |
|---|---|
| `id` | input, slug |
| `name` | input |
| `level` | input |
| `status` | select draft/review/published/archived |
| `imagePath` | input |
| `words` | custom grid |

Grid từ trong topic:

| Cột | Ý nghĩa |
|---|---|
| Hán tự | `word` |
| Pinyin | `pinyin` |
| Nghĩa Việt | `meaning` |
| Ảnh | `image` |
| Xóa | xóa dòng khỏi grid |

JSON nội bộ trong `state.flashcards[]`:

```json
{
  "id": "food",
  "name": "Đồ ăn",
  "level": "HSK 1",
  "status": "published",
  "imagePath": "../mobile/assets/images/flashcards/food/edfec00f07.jpg",
  "uploadedImageName": "",
  "words": [
    {
      "word": "米饭",
      "pinyin": "mǐfàn",
      "meaning": "cơm",
      "image": "rice.jpg",
      "query": "cơm 米饭",
      "examples": []
    }
  ]
}
```

Khi export sang flashcard index:

```json
{
  "version": "2026.06.04-admin",
  "topics": [
    {
      "id": "food",
      "name": "Đồ ăn",
      "level": "HSK 1",
      "status": "published",
      "words": [
        {
          "word": "米饭",
          "pinyin": "mǐfàn",
          "meaning": "cơm",
          "image": "rice.jpg",
          "query": "cơm 米饭",
          "examples": []
        }
      ]
    }
  ]
}
```

Flow:

```text
Thêm/Sửa topic
  -> openTopicEditor()
  -> createFlashcardWordsGrid()
  -> validateFlashcardWords()
     - thiếu Hán tự
     - thiếu pinyin
     - thiếu nghĩa Việt
     - trùng từ trong topic
  -> upsert('flashcards', topic)
  -> saveState()
  -> render()
```

Luồng ảnh:

```text
Click "Đăng ảnh"
  -> input file image/*
  -> FileReader đọc ảnh thành data URL
  -> preview ngay trong admin
  -> lưu imagePath dạng data URL trong localStorage
```

Lưu ý: vì admin là web tĩnh, upload ảnh hiện **chưa ghi file thật** vào `apps/mobile/assets`. Khi publish thật vẫn cần backend media upload hoặc copy ảnh vào assets.

### 5.5 Luồng quản lý bài học

`state.lessons[]` hiện đang là danh sách phẳng, trộn nhiều loại bài học:

```json
{
  "id": "abc123",
  "type": "Ngữ pháp",
  "title": "Câu hỏi với 吗",
  "level": "HSK 1",
  "items": 6,
  "status": "published"
}
```

Các loại đang xuất hiện trong UI:

| Type | Ý nghĩa | Nơi quản lý |
|---|---|---|
| `Ngữ pháp` | Bài học ngữ pháp tổng hợp | View Bài học |
| `Đọc hiểu` | Bài đọc/bài học đọc | View Bài học + View Đọc hiểu |
| `Video` | Video shadowing | View Bài học + View Video |

Flow:

```text
Thêm/Sửa bài học
  -> openLessonEditor()
  -> nhập type/title/level/items/status
  -> upsert('lessons', lesson)
  -> saveState()
```

Hạn chế: bài học chưa là container lesson-centric đầy đủ. Vocabulary, grammar, quiz, video vẫn nằm ở các collection riêng; `lessons[]` chỉ đóng vai trò danh sách mô tả/bộ đếm.

### 5.6 Luồng quản lý ngữ pháp

Grammar được quản lý trong `state.grammar[]`, nằm trong view Bài học.

Editor fields:

| Field | Dạng |
|---|---|
| `level` | select HSK 1-6 |
| `title` | input |
| `pattern` | input |
| `explanation` | textarea |
| `examplesText` | textarea, mỗi dòng `Trung | pinyin | Việt` |
| `note` | input |
| `status` | select |

JSON:

```json
{
  "id": "grammar_ma_question",
  "level": "HSK 1",
  "title": "Câu hỏi với 吗",
  "pattern": "S + V/O + 吗？",
  "explanation": "...",
  "examples": [
    {
      "cn": "你好吗？",
      "py": "Nǐ hǎo ma?",
      "vi": "Bạn khỏe không?"
    }
  ],
  "note": "...",
  "status": "published"
}
```

### 5.7 Luồng Video Shadowing

Video được lưu trong `state.lessons[]` với `type = "Video"`. Khi publish, video được tách ra thành payload `videos[]`.

Editor video hiện có:

| Field | Dạng |
|---|---|
| `title` | input |
| `youtubeId` | input |
| `source` | input |
| `level` | select HSK 1-4 |
| `status` | select draft/review/published/archived |
| `transcript` | custom grid có YouTube Player |

Grid transcript:

| Cột | Ý nghĩa |
|---|---|
| Start | giây bắt đầu |
| End | giây kết thúc |
| Câu Trung | câu phụ đề tiếng Trung |
| Pinyin | pinyin có dấu |
| Nghĩa Việt | bản dịch |
| Start button | lấy `currentTime` từ YouTube Player |
| End button | lấy `currentTime` từ YouTube Player |

JSON nội bộ:

```json
{
  "id": "video_1",
  "type": "Video",
  "title": "Hello Song",
  "youtubeId": "m_rDIzj6DRE",
  "source": "YouTube",
  "level": "HSK 1",
  "status": "review",
  "transcript": [
    {
      "start": 0,
      "end": 3.2,
      "cn": "你好，你好。",
      "py": "Nǐ hǎo, nǐ hǎo.",
      "vi": "Xin chào, xin chào."
    }
  ],
  "items": 1,
  "transcriptStatus": "timed"
}
```

Publish payload:

```json
{
  "videos": [
    {
      "id": "video_1",
      "title": "Hello Song",
      "titleCn": "",
      "level": "HSK 1",
      "youtubeId": "m_rDIzj6DRE",
      "source": "YouTube",
      "status": "review",
      "transcriptStatus": "timed",
      "subtitles": [
        {
          "start": 0,
          "end": 3.2,
          "cn": "你好，你好。",
          "py": "Nǐ hǎo, nǐ hǎo.",
          "vi": "Xin chào, xin chào."
        }
      ]
    }
  ]
}
```

Flow:

```text
Thêm/Sửa video
  -> openVideoEditor()
  -> createVideoTranscriptGrid()
     -> load YouTube IFrame API nếu có youtubeId
     -> admin bấm Start/End để lấy currentTime
  -> validateTranscriptRows()
     - có câu tiếng Trung
     - start/end hợp lệ
     - end > start
     - không overlap với dòng trước
  -> transcriptStatus = timed hoặc untimed
  -> lưu vào state.lessons[]
```

Hiện view Video có thống kê:

```text
Tổng video
Số video đã khớp câu/timed
Số video cần timing
Số video đang published
```

### 5.8 Luồng Đọc hiểu / Đọc báo

View hiện tại dùng nhãn **Đọc hiểu**, nhưng vẫn có phần nguồn tin/RSS trực tuyến.

Nguồn đọc:

```json
{
  "id": "bbc",
  "name": "BBC 中文",
  "level": "HSK 4",
  "status": "active",
  "url": "https://feeds.bbci.co.uk/zhongwen/simp/rss.xml"
}
```

Bài đọc:

```json
{
  "id": "article_school_day",
  "source": "VNChinese",
  "level": "HSK 2",
  "title": "我的一天",
  "titleVi": "Một ngày của tôi",
  "summaryVi": "...",
  "content": "...",
  "link": "",
  "status": "published",
  "sentences": []
}
```

Flow kiểm tra RSS:

```text
Click "Kiểm tra RSS"
  -> testReadingApi()
  -> GET /reading/news
  -> showToast số bài mới hoặc lỗi
```

### 5.9 Luồng Luyện nói

Pronunciation data:

```json
{
  "id": "h1_01",
  "level": "HSK 1",
  "topic": "Giao tiếp hằng ngày",
  "cn": "你好。",
  "py": "Nǐ hǎo.",
  "vi": "Xin chào.",
  "status": "published"
}
```

Flow nạp từ app user:

```text
Click "Nạp từ app user"
  -> fetch ../mobile/assets/data/reading_hsk.json
  -> map thành state.pronunciation[]
  -> saveState()
```

### 5.10 Luồng User Management

Online mode:

```text
Click "Đồng bộ API"
  -> GET /admin/users
  -> state.users = response
```

Tạo/sửa user:

```text
openUserEditor()
  -> nếu online:
       POST /admin/users
       PATCH /admin/users/:id
     nếu offline:
       upsert('users', ...)
```

Khóa/mở user:

```text
PATCH /admin/users/:id/status
body: { "status": "active" | "blocked" }
```

Chi tiết user:

```text
GET /admin/users/:id
```

## 6. Cơ chế kết nối Backend và API Contracts

### 6.1 API client trong admin

Admin hiện có hai lớp gọi API:

```text
fetchApi(path, options)
  -> tự thử nhiều base URL
  -> nhớ base URL chạy được vào state.settings.apiBaseUrl

apiFetch(path, options)
  -> yêu cầu adminToken
  -> thêm Authorization: Bearer <token>
  -> tự logout nếu 401/403
```

Danh sách base URL thử tự động:

```text
state.settings.apiBaseUrl
/api
http(s)://<current-host>:3001
http://127.0.0.1:3001
http://localhost:3001
```

`scripts/serve-admin.js` proxy:

```text
GET/POST/PUT/PATCH http://127.0.0.1:8080/api/*
  -> proxy sang http://127.0.0.1:3001/*
```

### 6.2 Endpoint admin đang dùng

| Chức năng | Method | Endpoint | Auth | Ghi chú |
|---|---:|---|---|---|
| Health check | GET | `/health` | Không | Kiểm tra API/AI status. |
| Login admin | POST | `/auth/login` | Không | Trả `user` và `token`. |
| Lấy dashboard | GET | `/admin/dashboard` | Bearer admin | Metric users/learning/content/activity. |
| Lấy users | GET | `/admin/users` | Bearer admin | Đồng bộ bảng user. |
| Chi tiết user | GET | `/admin/users/:id` | Bearer admin | Profile + progress/analytics. |
| Tạo user | POST | `/admin/users` | Bearer admin | Tạo user/editor/reviewer/admin. |
| Sửa user | PATCH | `/admin/users/:id` | Bearer admin | Update profile/role/status/password. |
| Khóa/mở user | PATCH | `/admin/users/:id/status` | Bearer admin | Body `{ status }`. |
| Lấy nội dung admin | GET | `/admin/content` | Bearer admin | Catalog đầy đủ, gồm cả nội dung chưa public. |
| Publish content | PUT | `/admin/content` | Bearer admin | Upsert content bundle vào backend. |
| Audit logs | GET | `/admin/audit-logs?limit=30` | Bearer admin | Nhật ký thao tác admin. |
| Public catalog | GET | `/content/catalog` | Không | App user có thể đọc. |
| Public flashcards | GET | `/content/flashcards` | Không | App user có thể đọc. |
| Public videos | GET | `/content/videos` | Không | App user có thể đọc. |
| Grammar check | POST | `/grammar/check` | Không | Admin dùng để test AI grammar. |
| AI chat | POST | `/ai/chat` | Không | Admin dùng để test chatbot. |
| Reading news | GET | `/reading/news` | Không | Kiểm tra nguồn tin/RSS. |

### 6.3 Publish payload chính

Khi bấm `Xuất bản`, admin tạo payload:

```json
{
  "version": "2026.06.04-admin",
  "vocabulary": [],
  "flashcards": [],
  "pronunciation": [],
  "videos": [],
  "lessons": [],
  "grammar": [],
  "articles": [],
  "readingSources": [],
  "games": [],
  "aiSettings": {}
}
```

Flow publish:

```text
Click Xuất bản
  -> nếu chưa login: báo cần đăng nhập admin online
  -> runQualityChecks()
  -> nếu có severity = fail:
       merge vào review queue
       chuyển sang view Kiểm duyệt
       dừng publish
  -> build payload
  -> PUT /admin/content
  -> backend publish
  -> load dashboard/content/audit logs
  -> render()
```

### 6.4 Offline / local JSON

Các thao tác không cần backend:

| Chức năng | Cơ chế |
|---|---|
| Offline admin | Không gọi API, dùng `localStorage`/`seedState`. |
| Import JSON | FileReader đọc file JSON trong trình duyệt. |
| Export content bundle | Tạo Blob và download JSON. |
| Export flashcard index | Tạo Blob và download JSON. |
| Export video catalog | Tạo Blob và download JSON. |
| Upload ảnh preview | FileReader đọc ảnh thành data URL, không ghi file thật. |

## 7. Kiểm soát chất lượng hiện có

`runQualityChecks()` kiểm tra các nhóm sau:

| Nhóm | Rule hiện có |
|---|---|
| Flashcard topic | Thiếu ảnh đại diện; topic chưa published; tên có thể thiếu dấu tiếng Việt. |
| Flashcard word | Thiếu pinyin/nghĩa; mojibake; trùng từ trong topic; ảnh bị dùng lại cho nhiều từ. |
| Vocabulary | Thiếu pinyin/nghĩa; trạng thái chưa published. |
| Luyện nói | Thiếu topic/câu Trung/pinyin/nghĩa; trạng thái chưa published. |
| Grammar | Thiếu title/pattern/explanation; trạng thái chưa published. |
| Articles | Thiếu title/content/summary; mojibake; trạng thái chưa published. |
| Video | Thiếu YouTube ID; transcript thiếu câu/pinyin/nghĩa; start/end sai; timing overlap; quá ít phụ đề; transcript chưa timed. |

Flow QA:

```text
Click nút QA
  -> runQualityChecks()
  -> mergeReviewIssues()
  -> state.review cập nhật
  -> chuyển activeView = review
```

Review queue:

```text
state.review[] = {
  id,
  area,
  title,
  issue,
  severity
}
```

## 8. Hạn chế kỹ thuật và Technical Debts

| Mức độ | Vấn đề | Tác động | Gợi ý nâng cấp |
|---|---|---|---|
| Cao | `apps/admin/app.js` là file monolith khoảng 95KB, chứa cả data seed, render UI, API client, editor, QA, import/export. | Khó bảo trì, khó test, dễ tạo regression khi thêm module mới. | Tách theo module: `features/flashcards`, `features/videos`, `features/users`, `core/api`, `core/state`, `components`. |
| Cao | State frontend dựa nhiều vào `localStorage`, chưa có draft/published model rõ ở frontend. | Admin có thể nhầm dữ liệu local với dữ liệu backend; khó rollback/publish theo phiên bản. | Thiết kế state theo `draftContent`, `publishedContent`, `contentVersion`, `dirtyChanges`. |
| Cao | `lessons[]` đang là danh sách phẳng, chưa lesson-centric thật sự. | Vocabulary, grammar, quiz, video chưa được gom vào một lesson container thống nhất. | DB/schema lesson-centric: `Lesson -> Components[] -> Vocabulary/Grammar/Video/Quiz`. |
| Cao | Một số chuỗi trong source/seed/README bị mojibake. | UI hiển thị sai tiếng Việt/tiếng Trung, giảm độ tin cậy dữ liệu. | Chuẩn hóa UTF-8, thêm script kiểm tra mojibake trong CI/admin QA. |
| Trung bình | Flashcard đã có grid mới nhưng code vẫn còn helper textarea legacy và README cũ. | Dễ gây hiểu nhầm cho người nhập liệu/chuyên gia mới đọc docs. | Xóa helper legacy hoặc ghi rõ chỉ để import tương thích. Cập nhật README. |
| Trung bình | Upload ảnh chỉ preview bằng data URL, không ghi file vào assets/backend. | Publish thật vẫn phải xử lý ảnh thủ công; dễ mất ảnh hoặc sai path. | Thêm media API: `POST /admin/media`, trả asset URL/path, validate kích thước/format. |
| Trung bình | Video Timing có YouTube player và nút Start/End nhưng chưa có workflow import transcript tự động. | Video dài vẫn cần nhập tay từng câu, dễ thiếu phụ đề. | Thêm import `.srt/.vtt`, auto split transcript, bulk timing, validation overlap trực quan. |
| Trung bình | QA chủ yếu chạy ở frontend. | Backend vẫn cần tự validate để bảo vệ dữ liệu publish. | Chuyển rule quan trọng sang backend validation trong `PUT /admin/content`. |
| Trung bình | Không có role-based UI chi tiết. | Editor/reviewer/admin có thể nhìn cùng UI nếu backend cho phép token. | Ẩn/disable thao tác theo role; backend vẫn là nguồn quyền chính. |
| Trung bình | Không có test tự động cho admin JS. | Khó đảm bảo login/publish/import không hỏng sau refactor. | Thêm Playwright smoke tests cho login, publish blocked by QA, proxy health. |
| Thấp | Static admin không có build/bundler. | Dễ chạy, nhưng khó mở rộng component phức tạp. | Nếu nâng cấp lớn, cân nhắc React + Vite + shadcn/MUI hoặc vẫn giữ static nhưng tách ES modules. |
| Thấp | API base URL có auto-detect nhưng setting vẫn là input text tự do. | Người dùng có thể nhập URL sai. | Thêm nút auto-detect/test và badge endpoint đang dùng. |

## 9. Đánh giá readiness cho nâng cấp Admin

### Điểm mạnh hiện tại

- Có đầy đủ menu quản trị cơ bản cho content, user, AI, QA.
- Đã có online/offline mode, import/export JSON, publish backend.
- Có QA frontend cho nhiều loại dữ liệu.
- Video editor đã có YouTube IFrame và nút lấy Start/End.
- Flashcard editor đã chuyển từ textarea sang grid nhập từng dòng.
- Có script khởi động dev và proxy `/api` giúp giảm lỗi kết nối.

### Rủi ro chính

- Kiến trúc frontend monolithic, chưa phù hợp để mở rộng admin chuyên nghiệp.
- Data model chưa lesson-centric nên khó quản lý bài học tổng hợp.
- Draft/published chưa được thể hiện rõ trong UI/state admin.
- Upload media và quản lý asset vẫn bán thủ công.
- Nhiều text seed/source có dấu hiệu lỗi encoding.
- Chưa có test tự động đảm bảo các luồng admin quan trọng.

## 10. Đề xuất hướng nâng cấp

### 10.1 Kiến trúc lại frontend admin

Đề xuất tách theo cấu trúc:

```text
apps/admin/
  src/
    app/
      routes/
      layout/
      state/
    core/
      api/
      auth/
      validation/
      types/
    features/
      dashboard/
      vocabulary/
      flashcards/
      lessons/
      videos/
      reading/
      speaking/
      games/
      users/
      ai/
      review/
      settings/
    components/
      DataGrid/
      EditorDialog/
      StatusBadge/
      Toolbar/
      MetricCard/
```

Nếu cần phát triển nhanh, nên dùng:

| Lựa chọn | Phù hợp khi |
|---|---|
| React + Vite + shadcn/ui | Muốn admin hiện đại, component linh hoạt, dễ build data grid/custom form. |
| React + MUI | Muốn DataGrid, form, dialog, layout có sẵn và ổn định. |
| Ant Design | Muốn admin enterprise nhanh, nhiều component bảng/form/tree sẵn. |
| Giữ JS thuần + ES Modules | Muốn ít thay đổi stack, nhưng vẫn cần tách file rõ ràng. |

### 10.2 Data model lesson-centric

Mục tiêu:

```text
Lesson
  id
  hskLevel
  subject
  type
  title
  status
  components[]

Component
  id
  type: vocabulary | grammar | video | quiz | reading | speaking
  order
  payload
```

Tree-view đề xuất:

```text
HSK 1
  Chủ đề: Giao tiếp
    Lesson Type: Vocabulary
      Lesson: Chào hỏi cơ bản
    Lesson Type: Video Shadowing
      Lesson: Hello Song
HSK 2
  Chủ đề: Đồ ăn
    Lesson Type: Flashcard
      Lesson: Đồ ăn thường ngày
```

### 10.3 Draft/Published rõ ràng

Đề xuất workflow:

```text
Draft edit
  -> Auto validate
  -> Preview
  -> Submit review
  -> Approve
  -> Publish new content version
  -> App user fetches latest JSON/API
```

DB nên tách:

```text
content_drafts
content_versions
published_content
admin_audit_logs
```

Không để app user đọc dữ liệu admin đang sửa dở.

### 10.4 QA nên chuyển thành hợp đồng backend

Frontend vẫn cảnh báo tức thời, nhưng backend cần chặn publish nếu:

- Trùng từ trong cùng topic.
- Thiếu pinyin/nghĩa/câu Trung.
- Video timing overlap hoặc end <= start.
- Video dài nhưng subtitle quá thưa.
- Ảnh không đúng format/path.
- Encoding có dấu hiệu mojibake.

## 11. Kết luận

Admin hiện tại đã đủ để vận hành nội dung ở mức prototype/nội bộ: có CRUD cơ bản, import/export, publish, QA và quản lý user. Tuy nhiên, để trở thành admin production chuyên nghiệp cho hệ thống học tiếng Trung, cần nâng cấp theo ba hướng chính:

1. **Tách kiến trúc frontend khỏi file monolith.**
2. **Thiết kế lại dữ liệu theo lesson-centric + draft/published rõ ràng.**
3. **Chuẩn hóa nhập liệu bằng data grid/form builder, media upload, video timing và backend validation.**

Bản hiện tại là nền tốt để chuyển tiếp sang một Admin v2, nhưng không nên tiếp tục mở rộng lâu dài trong cùng một file `app.js`.

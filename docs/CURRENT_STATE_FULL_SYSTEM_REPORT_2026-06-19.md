# Báo cáo hiện trạng hệ thống VNChinese

Ngày khảo sát: 19/06/2026  
Phạm vi: app Flutter, backend NestJS, admin web, dữ liệu asset/JSON và script chạy local.  
Nguyên tắc: chỉ đọc mã nguồn và tổng hợp. Không chỉnh sửa code chức năng.

## 1. Tổng quan dự án

| Hạng mục | Hiện trạng |
|---|---|
| Tên app | VNChinese |
| Mục tiêu | Ứng dụng học tiếng Trung cho người Việt: từ vựng HSK, flashcard, từ điển, ngữ pháp, AI sửa câu, đọc hiểu/RSS, luyện nói, video shadowing, tiến độ học tập và admin quản trị nội dung. |
| Mobile/user app | Flutter, nằm tại `apps/mobile/`. |
| Admin | Web tĩnh HTML/CSS/JavaScript, nằm tại `apps/admin/`. |
| Backend | NestJS + TypeORM + PostgreSQL, nằm tại `api/`. |
| Database | PostgreSQL qua Docker, service `postgres`, database `chinese_app`, port host `5433`. |
| Cache/phụ trợ | Redis có trong `docker-compose.yml`, nhưng chưa xác định được mức sử dụng thực tế trong code đã đọc. |
| Dịch vụ ngoài | Google Gemini API qua backend, Google Translate endpoint không chính thức trong dictionary translate, RSS báo, YouTube IFrame/oEmbed, speech-to-text và text-to-speech qua package Flutter. |
| Nền tảng app | Source có Android, iOS, Web, Windows, macOS, Linux trong `apps/mobile/`. Ảnh chụp và lỗi trước đó cho thấy đang chạy Flutter Web trên Chrome. Chưa xác định được mức hoàn thiện build native Android/iOS. |

### Cấu trúc thư mục chính

```text
Chinese app/
├─ apps/
│  ├─ mobile/              # Flutter app cho user
│  └─ admin/               # Admin web tĩnh
├─ api/                    # Backend NestJS + TypeORM
├─ docs/                   # Tài liệu dự án
├─ scripts/                # Script chạy dev, serve admin, seed/export
├─ data/                   # Dữ liệu phụ trợ
├─ artifacts/              # Output/snapshot build hoặc dữ liệu sinh ra
└─ docker-compose.yml      # PostgreSQL, Redis, Adminer
```

Backend riêng có tồn tại tại `api/`. Ngoài ra có một thư mục `apps/mobile/api/` giống một NestJS project lồng trong mobile; chưa xác định được còn dùng hay là mã thừa/cũ.

## 2. Kiến trúc app

### Mobile Flutter

| Thành phần | File chính | Vai trò |
|---|---|---|
| Entry point | `apps/mobile/lib/main.dart` | Khởi tạo `VNChineseApp`, khai báo theme, `home: AuthGate()`, gom nhiều file bằng `part`. |
| App shell | `apps/mobile/lib/app/app_shell.dart` | `MainScreen`, bottom navigation 5 tab bằng `NavigationBar` và `IndexedStack`. |
| Shared UI | `apps/mobile/lib/app/shared_widgets.dart` | Card, shell, tab segment, level selector, dashboard widgets. |
| Config | `apps/mobile/lib/core/config/app_config.dart` | `API_BASE_URL`, `GEMINI_API_KEY` qua `--dart-define`; mặc định API là `http://localhost:3001`. |
| Models | `apps/mobile/lib/core/models/app_models.dart` | Model dữ liệu chung: profile, progress, vocab, flashcard, grammar, article, video. |
| State/progress | `apps/mobile/lib/core/services/learning_progress_store.dart` | Lưu tiến độ local bằng `SharedPreferences`, đồng bộ best-effort lên `/learning/*`. |

Mô hình kiến trúc hiện tại là feature-folder + repository/service cục bộ. Chưa phải Clean Architecture hoàn chỉnh. State chủ yếu dùng `StatefulWidget` + `setState`, có dùng `Provider/ChangeNotifier` cho `VideoLearningController`.

Điều hướng app không dùng router tập trung như GoRouter. Luồng chính:

```text
main.dart
└─ AuthGate
   ├─ nếu có session -> MainScreen
   └─ nếu chưa có session -> AuthScreen

MainScreen
├─ Tab 0: HomeScreen
├─ Tab 1: VocabularyScreen
├─ Tab 2: GrammarScreen
├─ Tab 3: ReadingPracticeScreen
└─ Tab 4: ProfileScreen

Các màn hình con dùng Navigator.push + MaterialPageRoute.
```

### Backend NestJS

| Thành phần | File | Vai trò |
|---|---|---|
| Bootstrap | `api/src/main.ts` | Load `.env`, bật CORS, serve `/uploads`, khởi tạo DB thủ công, listen port 3001. |
| Module | `api/src/app.module.ts` | TypeORM PostgreSQL, entities, controllers, services. |
| Auth | `api/src/auth.controller.ts`, `api/src/auth.service.ts` | Đăng ký, đăng nhập, token HMAC, user/admin, dashboard admin. |
| Content | `api/src/content.controller.ts`, `api/src/content.service.ts` | Public `/content/*`, admin `/admin/content`, publish vào PostgreSQL. |
| Learning | `api/src/learning.controller.ts`, `api/src/learning.service.ts` | Summary, goal, word progress, attempts, reading, study time. |
| Dictionary | `api/src/dictionary.controller.ts`, `api/src/dictionary.service.ts` | Search, detail, examples, translate, cache. |
| Reading/RSS | `api/src/reading.controller.ts` | Nguồn RSS, lấy bài, fetch nội dung bài thật. |
| AI/Speech | `api/src/app.controller.ts`, `api/src/app.service.ts` | `/ai/chat`, `/grammar/check`, `/pronunciation/score`, `/health`. |
| Upload | `api/src/media.controller.ts` | Upload ảnh flashcard admin vào `/uploads/flashcards`. |

### Admin web

Admin là web tĩnh:

| File | Vai trò |
|---|---|
| `apps/admin/index.html` | Layout login, sidebar, topbar, dialog editor. |
| `apps/admin/styles.css` | Style toàn bộ admin. |
| `apps/admin/app.js` | Toàn bộ state, render views, API client, editor, upload, QA, publish. Đây là file lớn và khá monolithic. |
| `scripts/serve-admin.js` | Server Node tĩnh cho admin, proxy `/api` sang backend và proxy `/mobile/assets` để xem ảnh app. |

## 3. Danh sách màn hình hiện có

### User app Flutter

| Màn hình | Đường dẫn file | Vai trò | Ai dùng | Dữ liệu | Ghi chú |
|---|---|---|---|---|---|
| `AuthGate` | `apps/mobile/lib/features/auth/auth_flow.dart` | Quyết định đã đăng nhập hay chưa | User | `SharedPreferences`, API auth | Có restore session. |
| `AuthScreen` | `apps/mobile/lib/features/auth/auth_flow.dart` | Đăng nhập, đăng ký, vào khách | User | API `/auth/*`, fallback local | Không thấy route riêng cho admin trong app mobile. |
| `MainScreen` | `apps/mobile/lib/app/app_shell.dart` | Khung tab chính | User | UI/state local | 5 tab bottom navigation. |
| `HomeScreen` | `apps/mobile/lib/features/home/home_screen.dart` | Trang hôm nay học gì, metrics, shortcut | User | `LearningProgressStore` | Có timer ghi phút học mỗi phút. |
| `AiTutorScreen` | `apps/mobile/lib/features/home/home_screen.dart` | Chat gia sư AI | User | Backend `/ai/chat` | Nếu API/Gemini lỗi sẽ báo chưa kết nối. |
| `VocabularyScreen` | `apps/mobile/lib/features/vocabulary/vocabulary_screen.dart` | Từ điển, bài học flashcard, sổ tay | User | Repository + API fallback asset | Tab chính của từ vựng. |
| `DictionaryPanel` | `apps/mobile/lib/features/vocabulary/vocabulary_screen.dart` | Tra từ nhanh | User | Local dictionary + `/dictionary/search` | Có debounce, TTS, lưu sổ tay. |
| `FlashcardTopicsPanel` | `apps/mobile/lib/features/vocabulary/vocabulary_screen.dart` | Danh sách topic flashcard | User | `/content/flashcards`, fallback `assets/images/flashcards/index.json` | Lọc HSK 1-4. |
| `NotebookPanel` | `apps/mobile/lib/features/vocabulary/vocabulary_screen.dart` | Sổ tay từ đã lưu | User | `SharedPreferences` | Chưa thấy sync notebook đầy đủ hai chiều. |
| `FlashcardLessonScreen` | `apps/mobile/lib/features/vocabulary/flashcard_lesson_screen.dart` | Học từng flashcard | User | Topic flashcard | Có nghe, lưu, mic/chấm điểm. |
| `FlashcardQuizScreen` | `apps/mobile/lib/features/vocabulary/flashcard_lesson_screen.dart` | Quiz nhanh trong topic | User | Topic flashcard | Ghi tiến độ quiz local. |
| `VocabularyListScreen` | `apps/mobile/lib/features/vocabulary/vocabulary_list_screen.dart` | Danh sách/bài học từ vựng HSK | User | `assets/data/hsk_complete.json` và helpers | Có thể là màn hình cũ/luồng phụ. |
| `VocabularyDetailScreen` | `apps/mobile/lib/features/vocabulary/vocabulary_detail_screen.dart` | Chi tiết từ, ví dụ, ảnh, phát âm | User | Dictionary/API/examples | Có TTS, favorite. |
| `MagicVocabScreen` | `apps/mobile/lib/features/vocabulary/magic_vocab_screen.dart` | Học từ kiểu tương tác/game hóa | User | Chưa đọc sâu toàn bộ | Có TTS. |
| `GrammarScreen` | `apps/mobile/lib/features/grammar/grammar_screen.dart` | Bài học ngữ pháp và AI sửa câu | User | `/content/grammar`, asset fallback, `/grammar/check` | Nếu AI lỗi trả kết quả local score 0. |
| `GrammarCheckerScreen` | `apps/mobile/lib/features/grammar/grammar_checker_screen.dart` | Màn kiểm tra ngữ pháp riêng | User | API/local | Có thể là màn hình phụ/cũ. |
| `ReadingPracticeScreen` | `apps/mobile/lib/features/reading/reading_practice_screen.dart` | Phát âm, đọc hiểu, video | User | `/content/pronunciation`, `/content/articles`, `/content/videos`, assets fallback | Tab đọc chính. |
| `NewsArticleReaderScreen` | `apps/mobile/lib/features/reading/reading_practice_screen.dart` | Đọc bài, click từ để xem nghĩa | User | Article content, dictionary local | Đúng yêu cầu click từ mới hiện pinyin/nghĩa. |
| `NewsReaderScreen` | `apps/mobile/lib/features/reading/news_reader_screen.dart` | Reader tin/bài đọc nâng cao | User | API/RSS, TTS, STT | Có thể là màn hình cũ hoặc thay thế. |
| `PronunciationScreen` | `apps/mobile/lib/features/reading/pronunciation_screen.dart` | Luyện phát âm riêng | User | `pronunciation_data.dart` | Màn phụ. |
| `VideoLessonDetailScreen` | `apps/mobile/lib/features/reading/video_lesson_detail_screen.dart` | Video shadowing mới | User | YouTube IFrame, `VideoLearningController`, `/pronunciation/score` | Có active learning/viewing mode. |
| `VideoReadingScreen` / `VideoPlayerScreen` | `apps/mobile/lib/features/reading/video_reading_screen.dart` | Video player cũ/phụ | User | `assets/data/video_lessons.json` | Có logic riêng, có thể trùng với màn mới. |
| `ProfileScreen` | `apps/mobile/lib/features/profile/profile_screen.dart` | Tài khoản, mục tiêu, tiến độ, đăng xuất | User | `ProfileRepository`, `LearningProgressStore` | Update goal local + backend best-effort. |
| `StatsScreen` | `apps/mobile/lib/features/profile/stats_screen.dart` | Thống kê học tập | User | `LearningProgressStore` | Màn phụ. |
| `MiniGameScreen` | `apps/mobile/lib/features/games/mini_game_screen.dart` | Mini games nhiều dạng | User | Vocab truyền vào/local | Có matching, fill-in, listen choose, sentence order. |
| `QuizScreen` | `apps/mobile/lib/features/games/quiz_screen.dart` | Quiz nghĩa từ | User | Vocab list | Có TTS và ghi kết quả. |

### Admin web

Admin không tách thành nhiều file screen. Tất cả view render bằng function trong `apps/admin/app.js`.

| Menu admin | Function render | Hiển thị/chức năng chính | Dữ liệu |
|---|---|---|---|
| Tổng quan | `renderDashboard` | Metrics user/content/AI, luồng publish, hoạt động gần đây, đồng bộ users | `/admin/dashboard`, local state |
| Từ vựng | `renderVocabulary` | Bảng từ vựng, thêm/sửa/xóa, lọc/tìm | `/admin/content`, publish qua `/admin/content` |
| Flashcard | `renderFlashcards` | Topic cards, ảnh, số từ, sửa topic, đăng ảnh, nhân bản, xóa | `/content/flashcards`, upload `/admin/media/flashcard` |
| Bài học | `renderLessons` | Workspace lesson-centric, tree HSK -> subject -> type -> component, preview/export | State lesson/flashcard/grammar/video |
| Video & transcript | `renderVideos` | Danh sách video, check YouTube, transcript editor, QA, export catalog | Lessons type Video |
| Đọc hiểu | `renderReading` | Nguồn đọc/bài đọc, sửa/lưu trữ | Articles/readingSources |
| Luyện nói | `renderSpeaking` | Câu luyện nói, HSK/topic, thêm/sửa/xóa | Pronunciation |
| Quiz & trò chơi | `renderGames` | Game template, nguồn dữ liệu, trạng thái | Metadata games; nhiều game là auto-generated |
| Người dùng | `renderUsers` | User list/detail, tạo/sửa/khóa user | `/admin/users` |
| Trung tâm AI | `renderAiStudio` | Cấu hình/health AI | `/health`, state settings |
| Kiểm duyệt | `renderReview` | Hàng chờ QA, duyệt/ẩn, chạy QA | `runQualityChecks()` |
| Cấu hình | `renderSettings` | API base URL, mobile asset root, policy | localStorage/settings |

## 4. Luồng hoạt động của người dùng thường

### Mở app và đăng nhập

```text
Mở app
└─ VNChineseApp
   └─ AuthGate.restoreSession()
      ├─ Có session trong SharedPreferences
      │  └─ MainScreen
      └─ Không có session
         └─ AuthScreen
            ├─ Đăng nhập -> POST /auth/login -> lưu session
            ├─ Đăng ký -> POST /auth/register -> lưu session
            └─ Vào khách -> tạo guest session local
```

Nếu backend không phản hồi, `AuthService` có fallback user local trong `SharedPreferences`. Cơ chế này giúp demo offline nhưng làm phân quyền/dữ liệu thật khó kiểm soát hơn.

### Học từ vựng và sổ tay

```text
MainScreen > Tab Từ vựng
├─ Từ điển
│  ├─ nhập Hán tự/pinyin/nghĩa
│  ├─ lookup local dictionary
│  ├─ nếu không có -> GET /dictionary/search
│  ├─ nghe bằng flutter_tts
│  └─ lưu/bỏ lưu -> NotebookStore SharedPreferences
├─ Bài học flashcard
│  ├─ GET /content/flashcards
│  ├─ fallback assets/images/flashcards/index.json
│  ├─ chọn HSK/topic -> FlashcardLessonScreen
│  ├─ nghe từ -> flutter_tts
│  ├─ mic -> speech_to_text -> POST /pronunciation/score hoặc local scorer
│  └─ ghi tiến độ -> LearningProgressStore
└─ Sổ tay
   └─ đọc danh sách từ lưu trong SharedPreferences
```

### Học ngữ pháp và AI sửa câu

```text
MainScreen > Tab Ngữ pháp
├─ Bài học
│  ├─ GET /content/grammar
│  └─ fallback assets/data/grammar_hsk14.json hoặc dữ liệu cứng
└─ AI kiểm tra
   ├─ nhập câu tiếng Trung
   ├─ POST /grammar/check
   │  └─ backend gọi Gemini
   ├─ nếu lỗi -> local GrammarChecker, score 0
   └─ lưu history/progress vào SharedPreferences + best-effort /learning/attempts
```

### Luyện phát âm, đọc hiểu và video

```text
MainScreen > Tab Đọc
├─ Phát âm
│  ├─ GET /content/pronunciation
│  ├─ fallback assets/data/reading_hsk.json
│  ├─ nghe mẫu bằng TTS
│  ├─ ghi âm bằng speech_to_text
│  └─ chấm điểm local PronunciationScorer
├─ Đọc hiểu
│  ├─ GET /content/articles hoặc assets/data/reading_news_seed.json
│  ├─ nếu bấm nguồn mới -> GET /reading/news RSS
│  ├─ mở bài -> NewsArticleReaderScreen
│  ├─ nếu live article -> GET /reading/article?url=...
│  └─ click Hán tự/cụm từ -> tra DictionaryRepository -> hiện pinyin + nghĩa
└─ Video
   ├─ GET /content/videos
   ├─ fallback assets/data/video_lessons.json
   ├─ lọc chỉ video practice-ready
   └─ VideoLessonDetailScreen dùng YouTube IFrame + VideoLearningController
```

Quy tắc video user app đang áp dụng trong `VideoRepository._isPracticeReady`:

```text
Video phải:
- title không rỗng
- youtubeId không rỗng
- có timed subtitles
- youtubeId không nằm trong danh sách unavailable
- có ít nhất 8 phụ đề
- tổng span subtitle tối thiểu 20 giây
```

Vì vậy admin có thể thấy nhiều video hơn user app. Những video dài nhưng chỉ có 4-5 câu transcript sẽ bị loại hoặc không phù hợp học chủ động.

### Xem tiến độ và đăng xuất

```text
MainScreen > Tab Tài khoản
├─ ProfileRepository.load()
│  ├─ nếu user đăng nhập và có token -> GET /learning/summary
│  └─ fallback LearningProgressStore local
├─ đổi mục tiêu -> local SharedPreferences + PUT /learning/goal nếu có token
├─ đặt nhắc học -> SharedPreferences
└─ đăng xuất -> AuthService.logout() -> xóa session -> AuthScreen
```

## 5. Luồng hoạt động của admin

Admin là web riêng, không nằm trong app Flutter user.

```text
Mở admin qua scripts/serve-admin.js
└─ http://127.0.0.1:8080
   └─ Login form
      ├─ Online login -> POST /api/auth/login -> proxy tới backend /auth/login
      │  ├─ token hợp lệ + role admin -> load /admin/content, /admin/dashboard, /admin/users
      │  └─ role không phải admin -> chặn
      └─ Offline admin -> vào UI bằng localStorage, không publish DB thật nếu không gọi API
```

Tài khoản mặc định backend tạo trong `AuthService.ensureDefaultAdmin()`:

```text
Email: admin@vnchinese.local
Password mặc định: admin123456
```

Có phân quyền admin ở backend qua `AuthService.requireAdmin()` và `AdminAuthGuard`. User thường bị chặn khỏi endpoint admin nếu token không có `role = admin`.

Admin quản lý được:

| Nhóm dữ liệu | Thêm | Sửa | Xóa/lưu trữ | Publish sang user app | Ghi chú |
|---|---:|---:|---:|---:|---|
| Từ vựng | Có | Có | Có | Có | Upsert vào `vocabularies`. |
| Flashcard/topic | Có | Có | Có | Có | Topic vào `topics`, mapping từ vào `topic_vocabularies`. |
| Ảnh flashcard | Có | Có | Có | Có | File upload vào `/uploads/flashcards`, DB lưu URL/path. Existing mobile asset chỉ xem được qua admin server proxy. |
| Bài học | Có | Có | Có | Một phần | Lesson hiện là container nhưng DB/service vẫn pha trộn dữ liệu cũ/mới. |
| Video/transcript | Có | Có | Có | Có | App user chỉ hiện video đủ điều kiện practice-ready. |
| Bài đọc/RSS | Có | Có | Có | Có | Reading source + article. |
| Luyện nói | Có | Có | Có | Có | Pronunciation sentences. |
| Quiz/game | Có template | Có | Có | Một phần | Nhiều game được sinh tự động từ dữ liệu đã published. |
| Người dùng | Có | Có | Khóa | Không áp dụng | Qua `/admin/users`. |
| Kiểm duyệt | Duyệt/ẩn issue | Có | Có | Gián tiếp | Là QA queue trong admin state, không phải workflow review DB đầy đủ. |

Mức hoàn thiện admin: đã có nhiều chức năng thực và publish PostgreSQL, nhưng UI vẫn là web tĩnh monolithic; một số luồng giống công cụ nội bộ hơn là CMS chuyên nghiệp hoàn chỉnh.

## 6. Bảng kiểm tra chức năng hiện có

| Nhóm chức năng | Chức năng cụ thể | Có trong code không? | Có chạy được không? | Dữ liệu lấy từ đâu | Mức độ hoàn thiện | Ghi chú |
|---|---|---:|---|---|---|---|
| Đăng ký | User register | Có | Có logic, chưa test runtime trong lượt này | `/auth/register`, fallback local | Khá | Có validate email/password, fallback local. |
| Đăng nhập | User login | Có | Có logic, phụ thuộc API hoặc local users | `/auth/login`, SharedPreferences | Khá | Default localhost có thể lỗi trên máy thật/emulator. |
| Đăng xuất | Xóa session | Có | Có logic | SharedPreferences | Khá | Profile và AuthGate xử lý. |
| Phân quyền user/admin | Backend role admin | Có | Có logic backend | Token HMAC + users table | Trung bình | Mobile không route admin; admin web riêng. |
| Học từ vựng HSK | Danh sách/topic từ | Có | Có logic | Asset JSON + `/content/flashcards` | Khá | HSK 1-4 rõ nhất; HSK 5-6 chưa xác định đầy đủ. |
| Tra từ điển Trung-Việt | Search local/remote | Có | Có logic | Asset dictionary + `/dictionary/search` | Khá | Có cache local, fallback cứng. |
| Lưu từ vào sổ tay | Bookmark word | Có | Có logic | SharedPreferences | Trung bình | Chưa thấy sync notebook đầy đủ với backend. |
| Đánh dấu từ đã học | Record vocabulary | Có | Có logic | SharedPreferences + `/learning/words/:word` | Trung bình | Backend chỉ nhận nếu token không guest và word có trong DB. |
| Nghe phát âm | TTS | Có | Có logic | `flutter_tts` | Khá | Dùng `zh-CN`. |
| Luyện phát âm/chấm điểm | STT + scorer | Có | Có logic | `speech_to_text`, `/pronunciation/score`, local scorer | Trung bình khá | Scorer dựa text nhận dạng, không phải phoneme/audio engine chuyên sâu. |
| Học ngữ pháp | Lesson cards | Có | Có logic | `/content/grammar`, asset fallback | Khá | Data phụ thuộc DB/asset. |
| Kiểm tra ngữ pháp bằng AI | Gemini qua backend | Có | Phụ thuộc `GEMINI_API_KEY` | `/grammar/check` -> Gemini | Trung bình | Có fallback local nhưng score 0 khi AI lỗi. |
| Gia sư AI chat | Chat AI | Có | Phụ thuộc backend/Gemini | `/ai/chat` | Trung bình | Đã có retry localhost/127.0.0.1. |
| Đọc báo/RSS | Lấy RSS/news | Có | Phụ thuộc mạng backend | `/reading/news`, `/reading/article`, seed JSON | Trung bình | Parser RSS/HTML thủ công, có rủi ro encoding. |
| Tra từ trong bài đọc | Click từ | Có | Có logic | DictionaryRepository local | Khá | Chỉ hiện khi click, đúng hướng UX học đọc. |
| Thống kê tiến độ | Dashboard/profile | Có | Có logic | SharedPreferences + `/learning/summary` | Trung bình khá | Có merge local/remote. |
| Đặt mục tiêu hằng ngày | Goal words/minutes/HSK | Có | Có logic | SharedPreferences + `/learning/goal` | Khá | Reminder chỉ lưu local. |
| Mini game | Multiple game modes | Có | Có logic | Vocab list/local | Trung bình | Admin quản template, user sinh từ dữ liệu. |
| Quản lý nội dung admin | CMS admin | Có | Có logic | `/admin/content`, localStorage | Trung bình khá | UI/UX còn cần chuẩn hóa, app.js lớn. |

## 7. Dữ liệu và database

### Nguồn dữ liệu trong mobile

| Loại dữ liệu | Vị trí | Ghi chú |
|---|---|---|
| Từ điển seed | `apps/mobile/assets/data/dictionary_seed_clean.json` | Dùng bởi `DictionaryRepository`. |
| Từ điển HSK compact | `apps/mobile/assets/data/dictionary_hsk14_compact.json` | HSK 1-4. |
| Flashcard index | `apps/mobile/assets/images/flashcards/index.json` | Topic + image path trong asset. |
| Ảnh flashcard bundled | `apps/mobile/assets/images/flashcards/<topic>/...jpg` | Đóng gói cùng app Flutter. |
| Từ vựng đầy đủ | `apps/mobile/assets/data/hsk_complete.json` | Dùng bởi `VocabularyListScreen`/helper. |
| Ngữ pháp | `apps/mobile/assets/data/grammar_hsk14.json`, `grammar_hsk.json` | `GrammarRepository` fallback. |
| Đọc hiểu seed | `apps/mobile/assets/data/reading_news_seed.json` | Bài đọc demo/offline. |
| Câu luyện nói | `apps/mobile/assets/data/reading_hsk.json` | Fallback pronunciation. |
| Video seed | `apps/mobile/assets/data/video_lessons.json` | Fallback video lessons. |

### Dữ liệu local trên thiết bị

| Dữ liệu | Store | File/service |
|---|---|---|
| Session đăng nhập | SharedPreferences | `AuthService` |
| User local fallback | SharedPreferences | `AuthService` |
| Sổ tay từ | SharedPreferences key `vnchinese_notebook_words` | `NotebookStore` |
| Tiến độ ngày/streak/goal | SharedPreferences | `LearningProgressStore` |
| Lịch sử sửa ngữ pháp | SharedPreferences | `LearningProgressStore` |
| Reminder | SharedPreferences | `LearningProgressStore` |

Không thấy Firebase Auth/Firestore/Storage trong code đã quét.

### PostgreSQL/backend

Entities TypeORM chính trong `api/src/entities/`:

| Entity | Bảng | Ý nghĩa |
|---|---|---|
| `User` | `users` | Tài khoản, role, trạng thái, target HSK. |
| `CourseLevel` | `course_levels` | Cấp độ khóa học/HSK. |
| `Lesson` | `lessons` | Bài học/container. Entity hiện tại đơn giản hơn SQL thực tế trong service. |
| `Vocabulary` | `vocabularies` | Từ vựng, pinyin, nghĩa, HSK, ví dụ. |
| `Grammar` | `grammars` hoặc liên quan `grammar_lessons` | Ngữ pháp. Có dấu hiệu tồn tại schema mới/cũ song song. |
| `QuizQuestion` | `quiz_questions` | Câu hỏi quiz. |
| `UserProgress` | `user_progress` | Tiến độ theo lesson. |
| `Article` | `articles` | Bài đọc. |
| `ExampleSentence` | `example_sentences` | Câu ví dụ/corpus. |

`ContentService` còn query trực tiếp nhiều bảng không nằm trong danh sách entity TypeORM, ví dụ `topics`, `topic_vocabularies`, `video_transcript_lines`, `pronunciation_sentences`, `article_sources`, `content_versions`, `admin_audit_logs`, `daily_learning_stats`, `practice_attempts`, `user_word_progress`, `ai_interactions`. Điều này cho thấy schema thực tế được seed/migration bằng SQL/script, không chỉ dựa vào entities.

### Ảnh admin và ảnh app

Hiện có hai nguồn ảnh:

```text
1. Ảnh bundled trong app:
   apps/mobile/assets/images/flashcards/...
   -> có sẵn khi build app, admin chỉ xem được nếu chạy qua scripts/serve-admin.js proxy /mobile/assets.

2. Ảnh upload từ admin:
   api/uploads/flashcards/...
   -> backend serve qua /uploads/flashcards/<file>
   -> DB/content lưu URL hoặc path tĩnh.
```

Nếu admin thêm từ mới và upload ảnh online, file ảnh được lưu trong file system backend (`uploads/flashcards`), còn DB chỉ lưu đường dẫn/URL ảnh trong `topics.image_path` hoặc `topic_vocabularies.image_path`. Ảnh không được nhúng trực tiếp vào PostgreSQL.

Nếu admin dùng offline/localStorage hoặc chỉ sửa đường dẫn asset tương đối, user app sẽ không tự nhận ảnh mới cho đến khi publish DB hoặc cập nhật asset bundle/build lại.

## 8. API và dịch vụ ngoài

| API/dịch vụ | Dùng ở chức năng | File gọi | Key hardcode? | Xử lý lỗi |
|---|---|---|---|---|
| Backend VNChinese API | Auth, content, dictionary, learning, AI, upload | Nhiều repository/service Flutter, admin `app.js` | Không phải key; base URL mặc định hardcode localhost | Nhiều chỗ `catch` fallback local, đôi khi im lặng. |
| Google Gemini API | Grammar check, AI chat | Backend `api/src/app.service.ts` | Không thấy key hardcode trong source đọc được; lấy `GEMINI_API_KEY`/`GOOGLE_API_KEY` env | Có retry nhiều model, log lỗi, throw 503. |
| Google Translate endpoint | Dịch nhanh từ/câu | `api/src/dictionary.controller.ts`, `vocab_data_helper.dart` | Không dùng key | Catch trả rỗng. Đây là endpoint không chính thức. |
| Speech-to-Text | Luyện phát âm | `reading_practice_screen.dart`, `video_lesson_detail_screen.dart`, `speech_service.dart` | Không key | Có kiểm tra initialize, báo quyền mic trong UI. |
| Text-to-Speech | Nghe từ/câu/bài | Nhiều screen dùng `flutter_tts` | Không key | Có stop/dispose cơ bản. |
| YouTube IFrame API | Video shadowing | `video_lesson_detail_screen.dart`, `video_reading_screen.dart` | Không key | Controller poll currentTime, catch lỗi iframe tạm thời. |
| YouTube oEmbed | Admin check video | `apps/admin/app.js` | Không key | Đánh `ok/dead/error/missing`, nhưng check qua oEmbed không đảm bảo mọi tình huống embed/playback. |
| RSS News | Đọc báo live | `api/src/reading.controller.ts` | Không key | Timeout, fallback rỗng/seed. |
| Firebase | Chưa thấy | Chưa có | Không | Chưa xác định vì không thấy package/config Firebase. |

Endpoint backend chính:

```text
GET  /health
POST /auth/register
POST /auth/login
GET  /auth/me
POST /ai/chat
POST /grammar/check
POST /pronunciation/score
GET  /dictionary/search
GET  /dictionary/detail/:word
GET  /dictionary/examples
GET  /dictionary/translate
GET  /content/catalog
GET  /content/flashcards
GET  /content/videos
GET  /content/grammar
GET  /content/articles
GET  /content/pronunciation
GET  /content/games
GET  /reading/sources
GET  /reading/news
GET  /reading/article
GET  /learning/summary
PUT  /learning/goal
PUT  /learning/words/:word
POST /learning/attempts
POST /learning/reading
POST /learning/study-time
GET  /admin/dashboard
GET  /admin/content
PUT  /admin/content
GET  /admin/users
POST /admin/users
PATCH /admin/users/:id
PATCH /admin/users/:id/status
POST /admin/media/flashcard
```

## 9. Đánh giá trạng thái hoàn thiện

### Có thể demo tốt

| Phần | Lý do |
|---|---|
| Đăng nhập/đăng ký local hoặc online | Có AuthGate, session, fallback local. |
| Từ điển và flashcard HSK | Có dữ liệu asset, ảnh, TTS, sổ tay, topic. |
| Đọc hiểu seed và click từ | UX đúng hướng: chỉ click từ mới hiện nghĩa/pinyin. |
| Ngữ pháp bài học | Có card bài học và filter HSK. |
| Video shadowing với video đủ transcript | Có controller riêng, active/continuous mode, auto-pause. |
| Profile/progress local | Có dashboard, streak, goal, history. |
| Admin online cơ bản | Có login admin, load content, publish, upload ảnh, QA. |

### Có logic nhưng chưa ổn định hoặc phụ thuộc môi trường

| Phần | Rủi ro |
|---|---|
| AI chat và grammar AI | Phụ thuộc backend đang chạy, DB sẵn sàng, `GEMINI_API_KEY` hợp lệ, mạng ra Google. |
| RSS báo live | Phụ thuộc internet, RSS source, encoding HTML, publisher có chặn fetch hay không. |
| Chấm phát âm | Dựa speech-to-text text output + similarity, không phải chấm âm thanh/phoneme chuẩn. |
| Đồng bộ tiến độ backend | Best-effort, lỗi bị nuốt ở nhiều chỗ, local và remote có thể lệch. |
| Video admin -> user | User chỉ hiện video đủ rule practice-ready; admin có thể hiểu nhầm vì thấy nhiều video hơn. |
| Ảnh admin hiện tại | Existing mobile asset chỉ preview đúng khi chạy admin server proxy; mở file trực tiếp dễ không xem được ảnh. |

### Mới có giao diện hoặc chưa rõ hoàn thiện

| Phần | Nhận xét |
|---|---|
| Admin quiz/game | Admin quản template và source; user game sinh từ dữ liệu. Chưa thấy CMS nhập từng câu quiz đầy đủ cho mọi game. |
| Kiểm duyệt admin | Có QA queue trong `app.js`, nhưng chưa thấy workflow reviewer/published/draft đầy đủ ở DB như một CMS chuyên nghiệp. |
| Lesson-centric model | Admin đã có UI tree/workspace, backend vẫn còn query trực tiếp và schema pha trộn lesson/component. |
| HSK 5-6 user | Profile có HSK 5-6, nhưng các màn học chính hiện filter/data rõ nhất ở HSK 1-4. |

### Không nên demo nếu chưa chuẩn bị trước

| Phần | Lý do |
|---|---|
| Admin khi backend chưa chạy | Login online sẽ báo `ECONNREFUSED 127.0.0.1:3001`. |
| AI chat/grammar nếu chưa có key | Backend trả 503 hoặc app báo chưa kết nối. |
| Video thiếu transcript timing | Không auto-pause chuẩn, user có thể không thấy video trong app. |
| RSS live nếu mạng yếu | Có thể trả rỗng hoặc lỗi mã hóa. |
| Admin mở trực tiếp file thay vì qua server | Không proxy được `/mobile/assets`, ảnh asset hiện tại có thể không preview. |

## 10. Các vấn đề lớn phát hiện được

### Lỗi chức năng/luồng

| Vấn đề | File/liên quan | Tác động |
|---|---|---|
| API base URL mặc định `localhost:3001` | `AppConfig`, `DictionaryRepository`, admin `app.js` | Chạy trên Android/emulator/máy khác dễ không gọi được backend. |
| Adminer và admin web cùng port 8080 | `docker-compose.yml`, `scripts/serve-admin.js` | Có thể gây nhầm: 8080 vừa là Adminer vừa là VNChinese Admin nếu chạy cùng lúc. |
| Video user bị lọc mạnh | `VideoRepository._isPracticeReady` | Admin thấy nhiều video nhưng user thấy ít; cần giải thích rõ trong UI admin. |
| Một số transcript quá ít câu | Admin QA có check `< 8 câu` | Video dài nhưng chỉ 4-5 câu không phù hợp học chủ động. |
| Fallback local che lỗi API | Nhiều repository `catch (_) {}` | Demo mượt nhưng khó phát hiện backend không đồng bộ. |

### Lỗi giao diện/encoding

| Vấn đề | File/liên quan | Tác động |
|---|---|---|
| Dấu hiệu mojibake trong nhiều file | `apps/admin/index.html`, `api/src/app.service.ts`, nhiều file Flutter khi đọc | Có thể gây lỗi font/chữ Việt/Trung nếu file thật bị lưu sai encoding. |
| Admin UI còn giống công cụ nội bộ | `apps/admin/styles.css`, `apps/admin/app.js` | Trải nghiệm chưa bằng CMS chuyên nghiệp, modal/table có nguy cơ overflow. |
| Admin cần server proxy để xem ảnh mobile asset | `scripts/serve-admin.js` | Mở trực tiếp `index.html` sẽ hạn chế preview ảnh. |

### Lỗi dữ liệu

| Vấn đề | File/liên quan | Tác động |
|---|---|---|
| Dữ liệu static + DB + localStorage cùng tồn tại | Mobile assets, backend DB, admin state | Dễ hiểu nhầm nguồn sự thật. |
| Existing asset image không phải DB image | `assets/images/flashcards`, `topic_vocabularies.image_path` | Admin thêm ảnh mới online lưu vào uploads/DB, không tự copy vào Flutter assets. |
| Schema backend pha trộn entity và SQL trực tiếp | `entities/*`, `ContentService` | Khó bảo trì migration, dễ lệch schema. |
| Có nhiều màn hình/chức năng trùng lặp | `VideoReadingScreen` và `VideoLessonDetailScreen`, `GrammarCheckerScreen` và `GrammarScreen` | Dễ tạo hai logic khác nhau cho cùng module. |

### Bảo mật

| Vấn đề | File/liên quan | Tác động |
|---|---|---|
| Auth fallback local dùng password fingerprint đơn giản | `apps/mobile/lib/features/auth/auth_service.dart` | Chỉ nên dùng demo/offline, không phù hợp production. |
| Token backend là HMAC tự viết | `api/src/auth.service.ts` | Có hạn 7 ngày, nhưng nên chuẩn hóa JWT/session nếu production. |
| Admin offline mode | `apps/admin/app.js` | Dùng được UI không cần backend; không nên coi là quyền admin thật. |
| Secret mặc định dev | `AuthService.tokenSecret()` | Nếu không đổi env production sẽ yếu. |
| `.env` tồn tại trong backend | `api/.env` | Không mở/không công bố nội dung; cần đảm bảo không commit secret thật. |

### Hiệu năng/khả năng bảo trì

| Vấn đề | File/liên quan | Tác động |
|---|---|---|
| `apps/admin/app.js` rất lớn | `apps/admin/app.js` | Khó bảo trì, khó test, dễ regression UI. |
| Flutter dùng nhiều `part of main.dart` | `apps/mobile/lib/*` | Build được nhưng tổ chức module chưa sạch, khó tái sử dụng/test riêng. |
| Nhiều query SQL thủ công trong service | `ContentService`, `LearningService`, `AuthService` | Mạnh nhưng khó kiểm soát schema/migration. |
| Không thấy test coverage đáng kể | `test/widget_test.dart`, backend spec cơ bản | Rủi ro khi refactor. |

## 11. Tóm tắt cho người không đọc code

App hiện tại là một hệ thống học tiếng Trung khá đầy đủ tên VNChinese. Người dùng mở app sẽ đăng nhập/đăng ký hoặc vào khách, sau đó dùng 5 khu chính: Hôm nay, Từ vựng, Ngữ pháp, Đọc, Tài khoản. App có học flashcard theo chủ đề, tra từ Trung-Việt, lưu sổ tay, nghe phát âm, ghi âm/chấm điểm, học ngữ pháp, AI sửa câu, đọc bài tiếng Trung có click từ để xem pinyin/nghĩa, xem video shadowing và theo dõi tiến độ học tập.

Dữ liệu hiện nằm ở ba nơi: file asset/JSON trong app Flutter để chạy offline/demo, PostgreSQL qua backend NestJS để đồng bộ nội dung thật, và `SharedPreferences/localStorage` để lưu tạm tiến độ hoặc nội dung admin offline. Backend có các API cho auth, content, dictionary, reading, learning, AI và upload ảnh. Admin web đã có khả năng quản lý nhiều loại nội dung và publish vào PostgreSQL, nhưng vẫn là HTML/CSS/JS tĩnh với file `app.js` lớn, nên chưa phải một CMS hiện đại hoàn chỉnh.

Điểm mạnh của dự án là có nhiều module học tập thật, có fallback offline, có backend riêng và admin đã bắt đầu nối với DB. Điểm yếu lớn nhất là nguồn dữ liệu còn pha trộn, một số text có dấu hiệu lỗi encoding, admin UI/architecture còn monolithic, AI/RSS/video phụ thuộc môi trường, và user app chỉ hiện video đủ chuẩn transcript nên admin có thể thấy nhiều video hơn user.

Nếu đem bảo vệ đồ án, nên tập trung demo các phần ổn nhất: đăng nhập, học flashcard có ảnh/nghe/mic, tra từ và lưu sổ tay, đọc bài rồi click từ để hiện nghĩa, grammar AI khi backend và Gemini key đã sẵn sàng, video shadowing với một video có transcript timed đầy đủ, profile tiến độ, và admin publish content online. Không nên demo AI/RSS/admin online trước khi xác nhận API port 3001, DB và key Gemini hoạt động.

## Phụ lục: ghi chú vận hành local

Admin web chuẩn nên chạy qua script/server:

```powershell
cd "D:\Đồ án\app\Chinese app"
powershell -ExecutionPolicy Bypass -File scripts/start-vnchinese-dev.ps1
```

Script này dự kiến:

```text
1. Chạy Docker postgres/redis.
2. Start backend từ api/dist/src/main trên port 3001.
3. Chờ /health.
4. Start admin server tại http://127.0.0.1:8080.
5. Proxy /api sang backend và /mobile/assets sang Flutter assets.
```

Nếu chỉ mở `http://127.0.0.1:8080` mà server chưa chạy, Chrome sẽ báo connection refused. Nếu backend chưa sẵn sàng, admin login online sẽ báo không kết nối được API port 3001.

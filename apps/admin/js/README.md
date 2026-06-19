# VNChinese Admin JS Modules

Mục tiêu là tách dần `apps/admin/app.js` theo từng miền nghiệp vụ, không tách ồ ạt để tránh làm hỏng admin đang chạy.

## Cấu trúc đích

| Module | Vai trò |
| --- | --- |
| `core/state.js` | Load/save local state, normalize state, cache admin token. |
| `core/api.js` | `fetchApi`, auth headers, API base URL fallback, health check. |
| `core/dom.js` | `el`, `button`, `select`, `panel`, `tablePanel`, `toast`. |
| `features/media.js` | Upload ảnh, preview ảnh, resolve `assets/`, `/uploads/`, URL tuyệt đối. |
| `features/flashcards.js` | Topic editor, word grid, flashcard export/import. |
| `features/lessons.js` | Lesson-centric tree, lesson map export, component references. |
| `features/videos.js` | YouTube timing, transcript grid, dead-link checker. |
| `features/quality.js` | QA workflow: validate, preview, publish. |
| `utils/pinyin.js` | Convert pinyin số sang pinyin có dấu. |

## Nguyên tắc di chuyển

1. Mỗi lần chỉ tách một feature đang có test/check cú pháp.
2. Module mới phải expose qua một namespace rõ ràng trước khi chuyển sang ES module hoàn toàn.
3. Không đổi format state/export trong cùng commit với việc di chuyển file.
4. Sau mỗi lần tách chạy `node --check apps/admin/app.js` và smoke test admin trên `127.0.0.1:8080`.

# APP CHINESE - PRODUCT & BUSINESS CONSTITUTION (SOLO BUILDER)

Phiên bản: `v1.0`  
Cập nhật: `2026-05-22`  
Phạm vi: `Mobile Flutter + API NestJS`  

## 1) Mục tiêu tài liệu

Tài liệu này định hình rõ:

- App có những chức năng gì theo góc nhìn người dùng.
- Bên trong mỗi menu người dùng thao tác được gì.
- Chức năng nào đã chạy ổn, chức năng nào mới ở mức demo/chưa hoàn tất.
- Cần bổ sung gì để app đạt mức chuyên nghiệp và phù hợp người học tiếng Trung.

## 2) Định vị sản phẩm

## 2.1 Người dùng mục tiêu

- Sinh viên hoặc người đi làm Việt Nam học tiếng Trung từ HSK1 đến HSK4.
- Người cần học theo lộ trình ngắn mỗi ngày (10-30 phút).
- Người cần tra nhanh từ, sửa câu bằng AI, luyện phát âm, đọc báo thực tế.

## 2.2 Giá trị cốt lõi app phải mang lại

- Học nhanh: mở app là học ngay, không rối.
- Học đúng: có sửa lỗi ngữ pháp và phản hồi rõ ràng.
- Học đều: có streak, mục tiêu, nhắc tiến độ.
- Học thực tế: có đọc tin thật, tra từ trong ngữ cảnh.

## 2.3 North Star Metric (đề xuất)

- `Daily Active Learners hoàn thành >= 1 hoạt động học/ngày`.

## 3) Kiến trúc điều hướng sản phẩm

Bottom menu gồm 5 mục:

1. `Hôm nay`
2. `Từ vựng`
3. `Ngữ pháp`
4. `Đọc`
5. `Tài khoản`

Luồng học chuẩn đề xuất:

1. Vào `Hôm nay` xem lộ trình.
2. Sang `Từ vựng` học từ mới.
3. Sang `Ngữ pháp` học mẫu câu + AI sửa câu.
4. Sang `Đọc` áp dụng vào ngữ cảnh thật.
5. Vào `Tài khoản` xem tiến độ và điều chỉnh mục tiêu.

## 4) Đặc tả chi tiết theo từng menu

## 4.1 Menu `Hôm nay`

### Mục tiêu người dùng

- Biết hôm nay học gì.
- Biết còn thiếu bao nhiêu để đạt mục tiêu.
- Vào nhanh các bài học quan trọng.

### Người dùng có thể thao tác

- Xem card lộ trình ngày.
- Xem các chỉ số học trong ngày.
- Bấm vào các ô tính năng chính để chuyển tab nhanh.
- Xem roadmap HSK tổng quát.

### Chức năng nên có (chuẩn pro)

- Checklist học ngày (`Từ vựng`, `Ngữ pháp`, `Đọc`, `AI check`).
- CTA rõ ràng: `Tiếp tục bài dang dở`.
- Tự động ưu tiên “next best action”.
- Đồng bộ dữ liệu hôm nay theo tài khoản.

### Thiết kế UI/UX đề xuất

- Hero card trên cùng: mục tiêu ngày + tiến độ phần trăm.
- 4 KPI card bên dưới: streak, từ mới, phút học, số lần AI check.
- “Nhảy nhanh” 4 action chính.
- Thanh tiến độ theo từng kỹ năng, không chỉ tổng.

### Trạng thái hiện tại trong code

- Đã có giao diện và điều hướng tab.
- Chỉ số đang hard-code, chưa đọc từ dữ liệu thật.
- Chưa có checklist ngày và chưa có logic “next best action”.

## 4.2 Menu `Từ vựng`

### Mục tiêu người dùng

- Tra từ Trung-Việt nhanh.
- Học theo chủ đề HSK.
- Lưu từ vào sổ tay để ôn lại.

### Người dùng có thể thao tác

- Tab `Tra từ`: nhập chữ Hán/pinyin/tiếng Việt, xem gợi ý, xem chi tiết.
- Tab `Bài học`: học từ theo HSK/chủ đề, xem ví dụ.
- Tab `Sổ tay`: xem từ đã lưu, bỏ lưu.

### Chức năng nên có (chuẩn pro)

- Tìm kiếm realtime với autocomplete.
- Chi tiết từ gồm: giản thể, phồn thể, pinyin, nghĩa, loại từ, ví dụ.
- Nút nghe phát âm từ, lưu/bỏ lưu, đánh dấu đã học.
- Ôn tập theo SRS (spaced repetition) cho sổ tay.
- Bộ lọc sổ tay: mới lưu, khó nhớ, đã thuộc.

### Thiết kế UI/UX đề xuất

- Search bar cố định ở đầu.
- Kết quả tra từ dạng panel có tab con: nghĩa, ví dụ, từ liên quan.
- Trong `Bài học`, hiển thị tiến độ từng chủ đề và nút `Học tiếp`.
- Trong `Sổ tay`, có chế độ `Flashcard` và `Quiz nhanh 10 từ`.

### Trạng thái hiện tại trong code

- Đã có 3 tab và luồng sổ tay cục bộ (SharedPreferences).
- Đã có endpoint dictionary backend (`/search`, `/autocomplete`, `/detail`).
- Mobile đang gọi base URL cứng `http://localhost:3001`, dễ lỗi khi chạy trên máy thật.
- Có một số nút trong component cũ để trống action.
- Đồng bộ cloud cho sổ tay chưa có (tooltip đã ghi “sau khi có backend”).

## 4.3 Menu `Ngữ pháp`

### Mục tiêu người dùng

- Học mẫu ngữ pháp theo HSK.
- Tự nhập câu tiếng Trung và nhận góp ý AI.

### Người dùng có thể thao tác

- Tab `Bài học`: chọn HSK, đọc công thức, giải thích, ví dụ.
- Tab `AI kiểm tra`: nhập câu, bấm kiểm tra, xem điểm và gợi ý sửa.

### Chức năng nên có (chuẩn pro)

- Lưu lịch sử kiểm tra AI theo thời gian.
- So sánh câu cũ và câu đã sửa.
- Gợi ý bài ngữ pháp nên học tiếp dựa trên lỗi.
- Nút “Dùng câu sửa này” để copy/chèn vào bài luyện.

### Thiết kế UI/UX đề xuất

- Card bài học theo cụm: `Công thức -> Giải thích -> Ví dụ -> Lưu ý`.
- Kết quả AI hiển thị thành 4 block rõ: điểm, lỗi, câu chuẩn, gợi ý tự nhiên.
- History panel có bộ lọc theo HSK và ngày.

### Trạng thái hiện tại trong code

- Đã có lesson list và AI checker giao diện hoàn chỉnh.
- Dữ liệu bài học đang load từ local asset `grammar_hsk.json`.
- Có nút `Lịch sử kiểm tra` nhưng chưa gắn hành động.
- Luồng AI hoạt động nhưng đang để API key trực tiếp trong app mobile (rủi ro bảo mật).
- Khi lỗi key/mạng có fallback demo result.

## 4.4 Menu `Đọc`

### Mục tiêu người dùng

- Luyện phát âm câu mẫu theo HSK.
- Đọc tin tiếng Trung thật, chạm từ để tra nghĩa.

### Người dùng có thể thao tác

- Tab `Phát âm`: chọn HSK, nghe mẫu, ghi âm, nhận điểm.
- Tab `Đọc báo`: chọn nguồn RSS, mở bài, chạm từ để tra.

### Chức năng nên có (chuẩn pro)

- Lưu lịch sử điểm phát âm theo câu.
- Lưu bài báo yêu thích.
- TTS đọc toàn bài với highlight theo cụm.
- Lưu từ vừa tra vào sổ tay ngay trong màn đọc báo.

### Thiết kế UI/UX đề xuất

- Bài phát âm: câu mẫu lớn, nút nghe mẫu, nút ghi âm rõ trạng thái.
- Kết quả phát âm: điểm + nhận xét + nút luyện lại.
- Đọc báo: list card bài viết, detail có panel tra từ sticky phía dưới.

### Trạng thái hiện tại trong code

- Đã có luồng phát âm cơ bản (Speech-to-Text + TTS).
- Chấm điểm hiện tại là heuristic ký tự trùng khớp, chưa đủ chính xác cho production.
- RSS có fallback bài mẫu nếu tải nguồn thật lỗi.
- Nút `Nghe bài` và `Lưu bài` trong detail hiện chưa có action.
- Tra từ trong bài có fallback nghĩa từ điển cục bộ, có gọi dịch ngoài khi thiếu nghĩa.

## 4.5 Menu `Tài khoản`

### Mục tiêu người dùng

- Quản lý hồ sơ học tập.
- Theo dõi tiến độ.
- Đặt mục tiêu học mỗi ngày.

### Người dùng có thể thao tác

- Xem profile summary.
- Chỉnh tạm font scale và màu nhấn.
- Đặt mục tiêu từ/phút trong ngày.
- Xem các chỉ số học và tiến độ HSK.
- Đăng xuất.

### Chức năng nên có (chuẩn pro)

- Hồ sơ người dùng thật (avatar, tên, email, HSK target).
- Đồng bộ mục tiêu và tiến độ đa thiết bị.
- Chỉnh sửa hồ sơ có form validate.
- Export tiến độ học (PDF/CSV) hoặc chia sẻ thành tích.

### Thiết kế UI/UX đề xuất

- Header profile + badge cấp HSK hiện tại.
- Khối mục tiêu ngày có progress real-time.
- Khối thành tích tuần/tháng.
- Setting tách rõ: tài khoản, giao diện, dữ liệu, hỗ trợ.

### Trạng thái hiện tại trong code

- Đã có giao diện khá đầy đủ.
- Nhiều số liệu còn hard-code.
- Mục tiêu ngày đang giữ trong state local màn hình, chưa dùng `ProgressService.setDailyGoal`.
- Nút `Chỉnh sửa hồ sơ` chưa có action.
- Đăng nhập/đăng ký hiện là luồng local UI, chưa có auth backend thật.

## 5) Ma trận chức năng: chạy được vs chưa hoàn tất

| Nhóm chức năng | Trạng thái | Nhận xét |
| --- | --- | --- |
| Điều hướng 5 tab | Chạy tốt | Đã có `IndexedStack`, trải nghiệm chuyển tab ổn |
| Tra từ + autocomplete + detail | Chạy có điều kiện | Phụ thuộc API `localhost:3001`, cần cấu hình môi trường |
| Sổ tay từ vựng | Chạy tốt (local) | SharedPreferences ổn, chưa sync cloud |
| Học từ theo HSK/chủ đề | Chạy tốt (asset) | Dữ liệu local, chưa cá nhân hóa lộ trình |
| Ngữ pháp theo HSK | Chạy tốt (asset) | Chưa dùng backend grammar hiện có |
| AI kiểm tra câu | Chạy có điều kiện | Phụ thuộc API key và mạng, key đang để lộ trong app |
| Lịch sử AI check | Chưa chạy | Nút có nhưng chưa xử lý |
| Luyện phát âm câu | Chạy mức cơ bản | Scoring đơn giản, chưa lưu lịch sử |
| Đọc báo RSS | Chạy có fallback | Nguồn thật lỗi sẽ dùng bài mẫu |
| Nghe bài/Lưu bài đọc | Chưa chạy | Nút chưa gắn logic |
| Tài khoản/tiến độ | Chạy giao diện | Nhiều chỉ số hard-code, chưa sync backend |
| Auth đăng nhập/đăng ký | Chưa production | Mới là local state gate |

## 6) Khoảng trống sản phẩm cần bổ sung

## 6.1 Ưu tiên P0 (phải làm trước)

1. Tách toàn bộ API URL thành config theo môi trường (`dev/staging/prod`), bỏ `localhost` hard-code trong app.
2. Di chuyển gọi AI sang backend để ẩn API key, thêm rate limit và logging.
3. Hoàn thiện các nút đang trống action ở các màn chính.
4. Chuẩn hóa dữ liệu `Hôm nay` và `Tài khoản` bằng dữ liệu thật thay vì số cứng.

## 6.2 Ưu tiên P1 (nâng chất lượng trải nghiệm)

1. Lịch sử AI check + theo dõi lỗi ngữ pháp lặp lại.
2. Lưu bài đọc + lưu từ trong bài vào sổ tay 1 chạm.
3. Cải thiện thuật toán chấm phát âm (word-level scoring, confidence score).
4. Đồng bộ mục tiêu ngày, streak, sổ tay giữa nhiều thiết bị.

## 6.3 Ưu tiên P2 (mở rộng tăng trưởng)

1. Ôn tập SRS cho từ vựng và lỗi ngữ pháp.
2. Push notification học lại từ “sắp quên”.
3. Bảng xếp hạng mini hoặc challenge nhóm học.
4. Dashboard admin nội dung chính thức.

## 7) Yêu cầu phù hợp người dùng (Product Fit)

Để app phù hợp thật với người dùng Việt học tiếng Trung, cần giữ các nguyên tắc:

1. Mỗi phiên học phải hoàn thành được trong 10-15 phút.
2. Mọi bài học đều có `Hán tự + Pinyin + Nghĩa Việt`.
3. AI feedback luôn ngắn, rõ, dễ sửa theo ngay.
4. Luôn có trạng thái fallback khi mất mạng.
5. Giảm thao tác thừa, tăng nút “tiếp tục bài dở”.

## 8) KPI vận hành sản phẩm (đề xuất)

- `D1 retention`
- `Tỉ lệ hoàn thành mục tiêu ngày`
- `Số câu AI check/người dùng/tuần`
- `Số từ lưu sổ tay/người dùng/tuần`
- `Tỉ lệ người dùng quay lại tab Đọc sau 7 ngày`

## 9) Kế hoạch triển khai 3 giai đoạn

## Giai đoạn 1 - Ổn định nền tảng (2-3 tuần)

1. Config môi trường API.
2. Backend proxy cho AI.
3. Hoàn thành các nút chưa gắn action.
4. Chuẩn hóa tracking tiến độ ngày.

## Giai đoạn 2 - Tăng giá trị học tập (3-4 tuần)

1. Lịch sử AI check.
2. Lưu bài đọc + lưu từ từ ngữ cảnh.
3. Nâng cấp chấm phát âm.
4. Đồng bộ mục tiêu/streak/sổ tay.

## Giai đoạn 3 - Mở rộng và tối ưu (4+ tuần)

1. SRS + nhắc học.
2. Báo cáo tiến bộ cá nhân.
3. Admin content workflow hoàn chỉnh.
4. Tối ưu retention và A/B testing onboarding.

## 10) Ghi chú kiểm tra hiện trạng

Đánh giá trong tài liệu này được tổng hợp từ:

- `apps/mobile/lib/main.dart`
- `apps/mobile/lib/dictionary_search_tab.dart`
- `apps/mobile/lib/grammar_ai_service.dart`
- `apps/mobile/lib/progress_service.dart`
- `api/src/main.ts`
- `api/src/dictionary.controller.ts`
- `api/src/grammar.controller.ts`

Đây là bản đặc tả định hướng sản phẩm và nghiệp vụ để chốt roadmap. Khi triển khai từng hạng mục, cần tách thêm tài liệu kỹ thuật theo sprint (API contract, DB migration, test cases).

## 11) Nguon du lieu nap vao Database (bat buoc)

App can co nguon du lieu ro rang cho 3 phan he: Tu vung, Ngu phap, Bai doc.

### 11.1 Tu vung

- Nguon chinh:
1. `CC-CEDICT` (Han tu + pinyin + nghia goc)  
2. Du lieu HSK noi bo trong app (`assets/data/hsk_complete.json`)  
3. Bo cau vi du cuc bo (`example_sentences`) seed tu file JSONL

- File/script lien quan trong repo:
1. `api/src/seed-cedict.ts` (tai va seed CEDICT vao bang vocabularies)
2. `api/src/seed-example-corpus.ts` (seed cau vi du vao bang example_sentences)
3. `api/src/dictionary.service.ts` (search/autocomplete/detail + local examples)
4. `apps/mobile/assets/data/hsk_complete.json` (fallback du lieu hoc)

- Chien luoc nap:
1. Seed vocab tu CEDICT (uu tien 5k-20k tu pho bien).
2. Merge voi HSK curated list de chuan hoa hskLevel.
3. Seed cau vi du vao `example_sentences` de tra cuu nhanh offline-first.
4. Runtime: mobile goi `/dictionary/search`, `/autocomplete`, `/detail`, `/examples-local`.

- Ghi chu chat luong:
1. Nghia tieng Viet can duoc curate bo sung (khong chi rely on machine translation).
2. Co bo loc cho tu da trung, tu hiem, tu khong phu hop HSK1-4.

### 11.2 Ngu phap

- Nguon chinh:
1. Bo bai ngu phap HSK curated (`assets/data/grammar_hsk.json`)
2. SQL seed ngu phap (`data/grammar_pdfs/seed_grammar.sql`)
3. Nguon PDF HSK da parse (`data/grammar_pdfs/*.pdf`, `parse.py|js`)

- File/script lien quan:
1. `api/src/grammar.controller.ts` (`GET /grammar`, `GET /grammar/level/:level`)
2. `data/grammar_pdfs/generate_sql.py` (chuyen tu PDF sang SQL seed)
3. `apps/mobile/assets/data/grammar_hsk.json` (fallback local lessons)

- Chien luoc nap:
1. Curate lesson theo schema: title, pattern, explanation, examples, note, level.
2. Seed vao bang `grammar`.
3. Mobile uu tien goi API, fallback sang asset khi mat mang.
4. Versioning lesson theo `content_version` de co the update khong vo data cu.

### 11.3 Bai doc

- Nguon chinh:
1. RSS tieng Trung: BBC Chinese, VOA Chinese, RFI Chinese.
2. Fallback bai doc noi bo trong app.
3. Bo cau doc HSK local (`assets/data/reading_hsk.json`) cho phan luyen phat am.

- File/script lien quan:
1. `apps/mobile/lib/main.dart` (fetch RSS + parse + lookup panel)
2. `apps/mobile/assets/data/reading_hsk.json` (cau mau luyen doc/phat am)
3. `api/src/entities/article.entity.ts` (mo hinh bai doc backend, san cho cache)

- Chien luoc nap:
1. Backend dinh ky crawl RSS va cache vao DB (`articles`).
2. Mobile lay danh sach tu backend (khong parse truc tiep nhieu nguon tren client o production).
3. Neu RSS loi -> hien thi bai fallback de khong gian doan trai nghiem hoc.
4. Tap tu va tu da tra trong bai can duoc luu vao progress/history.

### 11.4 Compliance va licensing

1. Kiem tra license cua CEDICT, RSS source, hinh anh minh hoa truoc khi phat hanh.
2. Co metadata `source`, `license`, `updated_at` cho moi batch data.
3. Luu script ingestion trong repo de tai tao du lieu minh bach.

## 12) Ke hoach build ban MVP muot ma (de doc truoc khi build tiep)

### Sprint A (dang lam): On dinh nen tang + lesson flow co game

1. Chuan hoa config API theo environment, bo hard-code `localhost`.
2. Them fallback tra tu bang du lieu local de app van dung duoc khi API loi.
3. Nang giao dien danh sach bai hoc theo topic: ro tien do, ro game mode.
4. Giu flow hoc: Topic -> Flashcard -> Quiz game -> cap nhat progress.

### Sprint B: Hoan tat luong hoc theo mau ban gui

1. Lesson card style "co hinh + progress + quick enter" cho moi chu de.
2. Lesson step screen: image + hanzi + pinyin + nghia + nghe nhanh/cham.
3. Quiz/game mix:
- nghe chon tu dung
- chon nghia dung
- sap xep tu thanh cau ngan
4. Ket qua cuoi bai: score, sao, goi y on lai.

### Sprint C: Data + sync + production hardening

1. Dong bo progress/sotay/muc tieu len backend.
2. Lich su AI check + lich su bai doc + lich su phat am.
3. Cache bai doc backend, giam phu thuoc client fetch RSS truc tiep.
4. Tach AI key khoi mobile, mobile chi goi backend proxy AI.

### Tieu chi "chay muot" cho MVP

1. Mo topic -> vao bai hoc <= 500ms (data local).
2. Chuyen buoc flashcard/quiz animation on dinh, khong giat.
3. Tra tu khi mat API van hien thi fallback neu co trong bundle.
4. Khong co nut chinh bi "bam khong phan hoi" trong luong hoc topic.

## 13) Bo sung theo feedback moi (font, icon, grammar HSK1-4, reading chon chu de)

### 13.1 Xu ly loi font/mojibake

1. Nguyen nhan thuong gap: du lieu UTF-8 seed sai encoding (mojibake), gay hien thi chuoi kieu `Ã`, `ǎ€`.
2. Huong fix production-safe:
- Backend: sanitize string truoc khi tra API (`search`, `autocomplete`, `detail`, `examples`, `grammar`).
- Mobile: sanitize lan cuoi truoc khi render UI de tranh lot ca loi du lieu cu.
3. Neu co thoi gian: re-seed DB bang file UTF-8 sach de goc du lieu dung ngay tu dau.

### 13.2 Nguon icon/hinh minh hoa cho bai hoc

Muc tieu: them hinh de app sinh dong hon nhung khong vi pham ban quyen.

1. Nguon uu tien (de dung cho app thuong mai):
- OpenMoji (open source, co license ro rang).
- Twemoji (CC-BY 4.0).
- unDraw (mien phi voi dieu kien su dung ro rang).
2. Nguon Flaticon:
- Co the su dung, nhung can kiem tra goi ban quyen va attribution theo tung icon pack.
- Can luu metadata: `source_url`, `author`, `license`, `attribution_required`.
3. Rule trong repo:
- Luu icon theo nhom: `assets/images/topics`, `assets/images/words`.
- Them file map icon -> topic/word de fallback an toan khi thieu anh.

### 13.3 Nguon ngu phap HSK1-HSK4

1. Nguon fallback local: `apps/mobile/assets/data/grammar_hsk.json` (chu de + pattern + explanation + examples + note).
2. Nguon online/API: bang `grammar` qua endpoint `/grammar` va `/grammar/level/:level`.
3. Chien luoc dong bo:
- App load local truoc de hien thi ngay.
- Neu API co data moi thi merge/override theo `id`.
- Luu `content_version` de cap nhat an toan.

### 13.4 AI kiem tra ngu phap

1. Trang thai hien tai:
- Co fallback mock khi chua co API key.
- Co goi Gemini khi da set `GEMINI_API_KEY`.
2. Khuyen nghi production:
- Khong de API key trong mobile; route qua backend proxy.
- Backend them rate limit + log + cache ket qua check.

### 13.5 Thiet ke phan Doc theo chu de (theo huong Baolingo)

Muc tieu: user chu dong chon chu de va cap do, khong bi ep doc ngau nhien.

1. Cac mode doc de xuat:
- `Stories by Topic`: Gia dinh, Truong hoc, Cong viec, Du lich, Van hoa...
- `News by Topic`: Cong nghe, Kinh te, Giao duc, The thao...
- `Video Transcript`: doc theo transcript cua video hoc tieng Trung.
2. UX luong chinh:
- Chon `Nguon` -> Chon `Chu de` -> Chon `Level HSK` -> Vao bai doc.
- Trong bai: click tu de tra nghia, luu so tay, nghe TTS, shadowing tung cau.
3. Tracking can co:
- ti le doc xong
- so tu da tra trong bai
- so cau shadowing dat

### 13.6 Nguon doc bao va video

1. Bao/RSS Chinese de lay noi dung:
- BBC Chinese RSS
- VOA Chinese
- RFI Chinese
2. YouTube learning flow:
- Dung YouTube Data API de lay danh sach video theo channel/topic.
- Dung YouTube IFrame Player de phat video embed hop le.
- Transcript: uu tien nguon co ban quyen/cho phep su dung; neu khong co thi user-facing chi hien phan noi dung cho phep.
3. Luu y ban quyen voi Little Fox:
- Co the link/embed video theo chinh sach YouTube.
- Khong scrape/tai lai transcript noi dung co ban quyen neu chua duoc phep.

### 13.7 Backlog implementation uu tien

1. P0: fix mojibake + grammar HSK1-4 fallback + fast local examples.
2. P1: topic filter cho tab Doc + luu history theo topic.
3. P2: backend aggregator cho News/YouTube metadata + cache + retry.
4. P3: shadowing mode day du (segment transcript, record, score).

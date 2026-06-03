# CHƯƠNG 2: PHÂN TÍCH VÀ THIẾT KẾ HỆ THỐNG

## 2.1. Đặc tả yêu cầu hệ thống

### 2.1.1. Mô tả chung

Hệ thống App Tiếng Trung là một nền tảng hỗ trợ học tiếng Trung trên thiết bị di động, được xây dựng bằng Flutter và có khả năng kết nối với API nền NestJS/PostgreSQL. Trọng tâm của hệ thống là giúp người học luyện từ vựng, ngữ pháp, phát âm, đọc hiểu và theo dõi tiến độ học tập theo định hướng HSK.

Phiên bản mã nguồn hiện tại thể hiện rõ bốn nhóm chức năng chính:

- Phân hệ từ vựng: tra từ, học theo chủ đề HSK, lưu sổ tay, đánh dấu đã học, nghe phát âm và tự kiểm tra phát âm.
- Phân hệ ngữ pháp: xem bài học ngữ pháp theo cấp độ, kiểm tra câu bằng AI và nhận gợi ý sửa lỗi.
- Phân hệ luyện đọc và phát âm: luyện câu mẫu theo HSK, đọc báo tiếng Trung từ nguồn RSS, tra từ ngay trong bài báo.
- Phân hệ thống kê: theo dõi streak, số từ đã học, số từ đã lưu, mục tiêu hằng ngày và tiến độ tổng quan.

Ngoài ứng dụng di động, hệ thống còn có lớp dữ liệu và dịch vụ nền để hỗ trợ quản trị nội dung học tập như từ vựng, ngữ pháp, bài đọc, câu luyện phát âm và dữ liệu tiến độ. Một số chức năng quản trị chưa xuất hiện đầy đủ trên giao diện hiện tại nhưng rất cần thiết nếu triển khai hệ thống theo hướng hoàn chỉnh và đồng bộ nhiều thiết bị.

### 2.1.2. Thành phần hệ thống

| Thành phần | Vai trò |
| --- | --- |
| Ứng dụng di động Flutter | Giao diện chính cho người học, xử lý học từ vựng, ngữ pháp, phát âm, đọc báo, thống kê |
| API NestJS | Cung cấp dữ liệu ngữ pháp, dữ liệu từ vựng, bài đọc, tiến độ và lớp tích hợp CSDL |
| PostgreSQL | Lưu trữ dữ liệu nội dung học tập và dữ liệu học tập của người dùng |
| Gemini AI | Chấm và gợi ý sửa lỗi ngữ pháp cho câu tiếng Trung |
| MyMemory/Dictionary API | Hỗ trợ dịch từ khóa khi thiếu dữ liệu cục bộ |
| RSS/News Source | Cung cấp bài báo tiếng Trung từ các nguồn như BBC Chinese, VOA Chinese, RFI Chinese |
| Text-to-Speech và Speech-to-Text | Hỗ trợ nghe mẫu, ghi âm và chấm phát âm |

### 2.1.3. Tác nhân hệ thống

| Tác nhân | Mô tả |
| --- | --- |
| Người học | Tác nhân chính sử dụng mobile app để học từ vựng, ngữ pháp, phát âm, đọc báo và xem tiến độ |
| Quản trị viên nội dung | Quản lý nội dung học tập như từ vựng, bài ngữ pháp, câu luyện phát âm, nguồn tin RSS và bài đọc |
| Gemini AI | Hệ thống ngoài dùng để phân tích câu tiếng Trung và trả về kết quả kiểm tra ngữ pháp |
| Dịch vụ dịch/từ điển | Hệ thống ngoài dùng để dịch truy vấn khi dữ liệu cục bộ chưa đủ |
| Nguồn RSS | Hệ thống ngoài cung cấp dữ liệu bài báo tiếng Trung |
| Dịch vụ âm thanh | Hệ thống ngoài hỗ trợ phát âm mẫu và nhận dạng giọng nói |

### 2.1.4. Phạm vi hiện tại và phạm vi đề xuất

- Mã nguồn hiện tại đã có đầy đủ luồng học tập cho người học ở phía mobile.
- API backend hiện đã có nền TypeORM và các entity cơ bản cho `vocabularies`, `articles`, `grammar`, `user_progress`.
- Dữ liệu tiến độ ở mobile hiện chủ yếu lưu cục bộ bằng `SharedPreferences`.
- Thiết kế cơ sở dữ liệu trong tài liệu này được mở rộng theo hướng triển khai thực tế, cho phép đồng bộ người dùng, lưu lịch sử kiểm tra ngữ pháp, lưu kết quả phát âm, lưu bài đọc và thống kê hằng ngày.
- Chức năng quản trị nội dung được mô hình hóa để hoàn chỉnh hệ thống, dù giao diện quản trị chưa xuất hiện đầy đủ trong code hiện tại.

### 2.1.5. Yêu cầu chức năng

#### 2.1.5.1. Phân hệ từ vựng

- Hệ thống phải cho phép người học tra cứu từ bằng chữ Hán, tiếng Việt hoặc từ khóa gần nghĩa.
- Hệ thống phải hiển thị pinyin, nghĩa tiếng Việt và ví dụ minh họa cho từ vựng.
- Hệ thống phải cho phép người học học từ theo chủ đề và theo cấp HSK.
- Hệ thống phải cho phép người học đánh dấu từ đã học.
- Hệ thống phải cho phép người học lưu hoặc bỏ lưu từ trong sổ tay từ vựng.
- Hệ thống phải cho phép người học nghe phát âm mẫu của từ.
- Hệ thống phải cho phép người học tự kiểm tra phát âm và nhận điểm chấm.

#### 2.1.5.2. Phân hệ ngữ pháp

- Hệ thống phải cho phép người học xem danh sách bài học ngữ pháp theo từng cấp HSK.
- Hệ thống phải hiển thị mẫu câu, giải thích, ví dụ chữ Hán, pinyin và nghĩa tiếng Việt.
- Hệ thống phải cho phép người học nhập một câu tiếng Trung để kiểm tra ngữ pháp.
- Hệ thống phải gửi dữ liệu sang AI để nhận điểm số, lỗi sai, câu sửa, câu gợi ý và mẹo cải thiện.

#### 2.1.5.3. Phân hệ luyện phát âm

- Hệ thống phải cho phép người học chọn câu mẫu theo cấp HSK để luyện phát âm.
- Hệ thống phải phát âm mẫu câu chuẩn.
- Hệ thống phải thu âm hoặc nhận dạng giọng nói tiếng Trung của người học.
- Hệ thống phải chấm điểm mức độ tương đồng giữa câu mẫu và câu người học đọc.
- Hệ thống phải hiển thị phản hồi và cho phép người học luyện lại nhiều lần.

#### 2.1.5.4. Phân hệ đọc báo và tra từ trong ngữ cảnh

- Hệ thống phải cho phép người học chọn nguồn tin RSS tiếng Trung.
- Hệ thống phải tải và hiển thị danh sách bài báo mới nhất.
- Hệ thống phải cho phép người học mở nội dung bài báo và nghe toàn bài bằng TTS.
- Hệ thống phải cho phép người học chạm vào từ tiếng Trung trong bài để xem nghĩa.
- Hệ thống phải cho phép người học lưu từ vừa tra từ bài báo vào sổ tay.

#### 2.1.5.5. Phân hệ thống kê và mục tiêu

- Hệ thống phải theo dõi streak học tập theo ngày.
- Hệ thống phải hiển thị số từ đã học, số từ đã lưu và tiến độ trong ngày.
- Hệ thống phải cho phép người học đặt mục tiêu số từ và số phút học trong ngày.
- Hệ thống phải hiển thị tiến độ HSK dưới dạng tổng hợp.

#### 2.1.5.6. Phân hệ quản trị nội dung

- Hệ thống phải cho phép quản trị viên tạo, sửa, xóa từ vựng.
- Hệ thống phải cho phép quản trị viên quản lý chủ đề HSK và gắn từ vào chủ đề.
- Hệ thống phải cho phép quản trị viên quản lý bài học ngữ pháp và ví dụ.
- Hệ thống phải cho phép quản trị viên quản lý câu luyện phát âm.
- Hệ thống phải cho phép quản trị viên quản lý nguồn tin RSS và bài báo lưu cache.

### 2.1.6. Yêu cầu phi chức năng

#### 2.1.6.1. Hiệu năng

- Thời gian tải dữ liệu bài học từ vựng hoặc ngữ pháp phải ngắn hơn 2 giây trong điều kiện mạng bình thường.
- Thời gian phản hồi của chức năng kiểm tra ngữ pháp AI nên nhỏ hơn 5 giây.
- Chức năng tra từ trong bài báo phải phản hồi gần như tức thời khi đã có dữ liệu cục bộ.

#### 2.1.6.2. Khả dụng và trải nghiệm người dùng

- Ứng dụng phải dễ dùng trên màn hình điện thoại.
- Người học có thể sử dụng phần lớn nội dung cơ bản ngay cả khi chưa đăng nhập.
- Những dữ liệu học quan trọng như từ đã học, từ đã lưu, mục tiêu ngày nên được lưu an toàn và có khả năng đồng bộ.

#### 2.1.6.3. Bảo mật

- Không nên lưu trực tiếp API key AI ở phía mobile khi triển khai thực tế.
- Những yêu cầu kiểm tra ngữ pháp AI nên đi qua backend để kiểm soát khóa, logging và giới hạn sử dụng.
- Dữ liệu người dùng và lịch sử học tập phải được phân quyền rõ giữa người học và quản trị viên.

#### 2.1.6.4. Khả năng mở rộng

- Cấu trúc dữ liệu phải hỗ trợ mở rộng thêm HSK 6+, bài thi, flashcard, đồng bộ đa thiết bị.
- CSDL phải hỗ trợ lưu lịch sử phát âm, lịch sử kiểm tra ngữ pháp và thống kê hằng ngày.

## 2.2. Các biểu đồ hệ thống

### 2.2.1. Mô tả kịch bản các ca sử dụng

#### UC01. Tra cứu từ vựng

Người học nhập một từ khóa. Nếu từ khóa không phải chữ Hán, hệ thống chuyển ngữ sang tiếng Trung trước. Sau đó hệ thống tìm thông tin từ trong dữ liệu cục bộ, nếu thiếu thì gọi dịch vụ dịch để lấy nghĩa. Kết quả trả về gồm chữ Hán, pinyin, nghĩa, ví dụ và các thao tác nghe phát âm hoặc lưu sổ tay.

#### UC02. Học từ vựng theo chủ đề HSK

Người học chọn cấp HSK và chủ đề. Hệ thống mở danh sách từ theo luồng học tuần tự. Với mỗi từ, người học xem mặt trước, bấm xem nghĩa, nghe phát âm, tự kiểm tra phát âm, sau đó chọn tiếp tục để đánh dấu từ đã học. Cuối chủ đề, hệ thống cập nhật tiến độ học.

#### UC03. Kiểm tra phát âm từ

Người học mở chi tiết từ và bấm vào biểu tượng micro. Hệ thống ghi nhận giọng nói, chuyển sang văn bản, so sánh với từ mục tiêu và trả về điểm phát âm. Kết quả được hiển thị ngay và có thể dùng để cập nhật điểm cao nhất của từ đó.

#### UC04. Xem bài học ngữ pháp

Người học chọn tab ngữ pháp và một cấp HSK. Hệ thống tải danh sách bài học từ API hoặc nguồn dự phòng cục bộ. Mỗi bài học hiển thị tiêu đề, mẫu câu, giải thích và ví dụ minh họa. Người học có thể xem tuần tự từng bài theo cấp độ.

#### UC05. Kiểm tra ngữ pháp bằng AI

Người học nhập một câu tiếng Trung cần kiểm tra. Hệ thống gửi nội dung đến dịch vụ AI, nhận về điểm số, lỗi sai, câu sửa và gợi ý cách diễn đạt tự nhiên hơn. Kết quả được trình bày trực quan để người học có thể sửa câu ngay.

#### UC06. Luyện phát âm câu theo HSK

Người học chọn một câu mẫu trong danh sách câu luyện phát âm. Hệ thống phát âm mẫu, sau đó mở microphone để người học đọc lại. Dựa trên văn bản nhận dạng được, hệ thống tính độ tương đồng với câu gốc và đưa ra điểm số cùng nhận xét.

#### UC07. Đọc báo tiếng Trung và tra từ trong bài

Người học chọn nguồn tin và tải danh sách bài báo mới. Khi mở một bài báo, nội dung được tách thành từng từ hoặc cụm từ tiếng Trung. Người học chạm vào từ bất kỳ để tra nghĩa, nghe lại phát âm và lưu vào sổ tay nếu cần.

#### UC08. Xem thống kê và đặt mục tiêu

Người học mở màn hình thống kê để xem streak, số từ đã học, số từ đã lưu và mức hoàn thành mục tiêu trong ngày. Nếu muốn điều chỉnh kế hoạch học tập, người học mở hộp thoại thiết lập và đặt lại số từ hoặc số phút mục tiêu.

#### UC09. Quản lý học liệu

Quản trị viên đăng nhập vào hệ thống quản trị, thêm hoặc chỉnh sửa từ vựng, bài ngữ pháp, câu luyện phát âm hoặc nguồn bài đọc. Sau khi lưu, dữ liệu mới được xuất bản để mobile app có thể tải xuống.

### 2.2.2. Bảng đặc tả use case

#### 2.2.2.1. Use case Tra cứu từ vựng

| Thuộc tính | Nội dung |
| --- | --- |
| Tên use case | Tra cứu từ vựng |
| Mã use case | UC01_SearchVocabulary |
| Tác nhân | Người học |
| Mục tiêu | Tìm nhanh nghĩa, pinyin và ví dụ của một từ tiếng Trung |
| Tiền điều kiện | Ứng dụng đã mở; người dùng có thể có hoặc không có mạng |
| Hậu điều kiện | Từ được hiển thị chi tiết; người dùng có thể lưu sổ tay hoặc nghe phát âm |
| Luồng chính | 1. Người học nhập từ khóa. 2. Hệ thống kiểm tra kiểu truy vấn. 3. Hệ thống chuẩn hóa từ khóa và tra dữ liệu. 4. Hệ thống hiển thị chi tiết từ. |
| Luồng thay thế | Nếu từ khóa là tiếng Việt thì hệ thống dịch sang tiếng Trung trước khi tra. |
| Ngoại lệ | Không có kết quả phù hợp hoặc dịch vụ dịch không phản hồi. |

#### 2.2.2.2. Use case Học từ vựng theo chủ đề HSK

| Thuộc tính | Nội dung |
| --- | --- |
| Tên use case | Học từ vựng theo chủ đề HSK |
| Mã use case | UC02_LearnVocabularyByTopic |
| Tác nhân | Người học |
| Mục tiêu | Học từ vựng theo luồng chủ đề, tăng số từ đã học và tiến độ HSK |
| Tiền điều kiện | Dữ liệu từ vựng đã được nạp vào ứng dụng |
| Hậu điều kiện | Từ được đánh dấu đã học; thống kê ngày được cập nhật |
| Luồng chính | 1. Người học chọn HSK và chủ đề. 2. Hệ thống hiển thị từng từ theo thứ tự. 3. Người học bấm xem nghĩa. 4. Người học bấm tiếp tục. 5. Hệ thống đánh dấu từ đã học và chuyển sang từ tiếp theo. |
| Luồng thay thế | Người học có thể bật hoặc tắt hiển thị pinyin trong quá trình học. |
| Ngoại lệ | Dữ liệu asset lỗi hoặc danh sách chủ đề rỗng. |

#### 2.2.2.3. Use case Kiểm tra phát âm từ

| Thuộc tính | Nội dung |
| --- | --- |
| Tên use case | Kiểm tra phát âm từ |
| Mã use case | UC03_CheckWordPronunciation |
| Tác nhân | Người học |
| Mục tiêu | Đọc thử một từ và nhận điểm phát âm |
| Tiền điều kiện | Thiết bị có micro và hỗ trợ nhận dạng giọng nói |
| Hậu điều kiện | Điểm phát âm được hiển thị; có thể lưu điểm cao nhất |
| Luồng chính | 1. Người học mở chi tiết từ. 2. Người học bấm micro. 3. Hệ thống ghi âm và nhận dạng giọng nói. 4. Hệ thống so sánh kết quả với từ mục tiêu. 5. Hệ thống hiển thị điểm phát âm. |
| Luồng thay thế | Người học có thể nghe lại bản ghi và thử lại. |
| Ngoại lệ | Trình duyệt hoặc thiết bị không hỗ trợ Speech Recognition. |

#### 2.2.2.4. Use case Xem bài học ngữ pháp

| Thuộc tính | Nội dung |
| --- | --- |
| Tên use case | Xem bài học ngữ pháp |
| Mã use case | UC04_ViewGrammarLessons |
| Tác nhân | Người học |
| Mục tiêu | Xem quy tắc ngữ pháp theo cấp độ HSK |
| Tiền điều kiện | Hệ thống có dữ liệu ngữ pháp từ API hoặc dữ liệu dự phòng |
| Hậu điều kiện | Danh sách bài học và nội dung chi tiết được hiển thị |
| Luồng chính | 1. Người học chọn tab Bài học. 2. Hệ thống tải danh sách bài học theo cấp độ. 3. Người học chọn một bài học. 4. Hệ thống hiển thị mẫu câu, giải thích và ví dụ. |
| Luồng thay thế | Nếu API lỗi, hệ thống dùng dữ liệu fallback có sẵn trong app. |
| Ngoại lệ | API ngữ pháp không phản hồi và không có dữ liệu fallback. |

#### 2.2.2.5. Use case Kiểm tra ngữ pháp bằng AI

| Thuộc tính | Nội dung |
| --- | --- |
| Tên use case | Kiểm tra ngữ pháp bằng AI |
| Mã use case | UC05_CheckGrammarWithAI |
| Tác nhân | Người học, Gemini AI |
| Mục tiêu | Phân tích câu tiếng Trung và nhận phản hồi sửa lỗi |
| Tiền điều kiện | Thiết bị có kết nối mạng và AI service sẵn sàng |
| Hậu điều kiện | Điểm số, lỗi sai, câu sửa và gợi ý được hiển thị cho người học |
| Luồng chính | 1. Người học nhập câu. 2. Người học bấm kiểm tra. 3. Hệ thống gửi nội dung tới AI. 4. AI trả về JSON kết quả. 5. Hệ thống phân tích và hiển thị kết quả. |
| Luồng thay thế | Khi không có AI thật, hệ thống dùng luồng mock để trả về kết quả mô phỏng. |
| Ngoại lệ | Hết mạng, lỗi API key hoặc phản hồi AI không đúng định dạng JSON. |

#### 2.2.2.6. Use case Luyện phát âm câu theo HSK

| Thuộc tính | Nội dung |
| --- | --- |
| Tên use case | Luyện phát âm câu theo HSK |
| Mã use case | UC06_PracticeSentencePronunciation |
| Tác nhân | Người học |
| Mục tiêu | Luyện đọc câu mẫu và cải thiện phát âm theo cấp độ |
| Tiền điều kiện | Thiết bị có micro; dữ liệu câu mẫu đã sẵn sàng |
| Hậu điều kiện | Kết quả luyện tập được hiển thị; thời lượng học có thể được cộng vào thống kê |
| Luồng chính | 1. Người học chọn cấp HSK. 2. Hệ thống hiển thị câu mẫu. 3. Người học nghe mẫu. 4. Người học đọc lại. 5. Hệ thống nhận dạng giọng nói và tính điểm. 6. Hệ thống hiển thị nhận xét. |
| Luồng thay thế | Người học đổi sang câu khác hoặc bấm đọc lại câu hiện tại. |
| Ngoại lệ | Speech-to-Text không khả dụng hoặc không nhận ra âm thanh. |

#### 2.2.2.7. Use case Đọc báo và tra từ trong bài

| Thuộc tính | Nội dung |
| --- | --- |
| Tên use case | Đọc báo và tra từ trong bài |
| Mã use case | UC07_ReadNewsAndLookupWords |
| Tác nhân | Người học, Nguồn RSS |
| Mục tiêu | Đọc bài báo tiếng Trung thực tế và tra nghĩa từ trong ngữ cảnh |
| Tiền điều kiện | Có kết nối mạng hoặc đã có bài báo cache |
| Hậu điều kiện | Bài báo được tải; từ được tra có thể được lưu sổ tay |
| Luồng chính | 1. Người học chọn nguồn tin. 2. Hệ thống tải danh sách bài báo. 3. Người học mở bài báo. 4. Người học chạm vào từ cần tra. 5. Hệ thống tra nghĩa và hiển thị panel chi tiết. |
| Luồng thay thế | Nếu không tra được dữ liệu cục bộ, hệ thống gọi dịch vụ dịch trực tuyến. |
| Ngoại lệ | RSS lỗi, proxy CORS lỗi hoặc bài báo không có nội dung chữ Hán phù hợp. |

#### 2.2.2.8. Use case Xem thống kê và đặt mục tiêu

| Thuộc tính | Nội dung |
| --- | --- |
| Tên use case | Xem thống kê và đặt mục tiêu |
| Mã use case | UC08_ViewStatsAndSetGoals |
| Tác nhân | Người học |
| Mục tiêu | Theo dõi tiến độ học và điều chỉnh mục tiêu hằng ngày |
| Tiền điều kiện | Đã có dữ liệu học tập được ghi nhận trong bộ nhớ cục bộ hoặc CSDL |
| Hậu điều kiện | Mục tiêu mới được lưu; màn hình thống kê được cập nhật |
| Luồng chính | 1. Người học mở màn hình thống kê. 2. Hệ thống nạp số liệu hiện có. 3. Người học mở hộp thoại đặt mục tiêu. 4. Người học chỉnh số từ và số phút. 5. Hệ thống lưu mục tiêu và tải lại thống kê. |
| Luồng thay thế | Người học chỉ xem thống kê mà không chỉnh sửa mục tiêu. |
| Ngoại lệ | Dữ liệu lưu cục bộ bị lỗi hoặc không thể ghi SharedPreferences. |

#### 2.2.2.9. Use case Quản lý học liệu

| Thuộc tính | Nội dung |
| --- | --- |
| Tên use case | Quản lý học liệu |
| Mã use case | UC09_ManageLearningContent |
| Tác nhân | Quản trị viên nội dung |
| Mục tiêu | Tạo và cập nhật dữ liệu từ vựng, ngữ pháp, phát âm, bài đọc |
| Tiền điều kiện | Quản trị viên đã đăng nhập vào hệ thống quản trị |
| Hậu điều kiện | Nội dung mới được lưu vào CSDL và sẵn sàng xuất bản |
| Luồng chính | 1. Quản trị viên chọn loại học liệu. 2. Quản trị viên tạo mới hoặc chỉnh sửa dữ liệu. 3. Hệ thống kiểm tra ràng buộc. 4. Hệ thống lưu CSDL. 5. Hệ thống thông báo thành công. |
| Luồng thay thế | Quản trị viên vô hiệu hóa học liệu thay vì xóa cứng. |
| Ngoại lệ | Dữ liệu trùng khóa, thiếu trường bắt buộc hoặc lỗi ghi CSDL. |

### 2.2.3. Mã PlantUML đã chuẩn bị

Các biểu đồ đã được tách thành file riêng để có thể mở trực tiếp bằng PlantUML:

| Nhóm biểu đồ | Tệp |
| --- | --- |
| Use case tổng quát | [01-usecase-overview.puml](plantuml/01-usecase-overview.puml) |
| Use case người học | [02-usecase-learner.puml](plantuml/02-usecase-learner.puml) |
| Use case quản trị | [03-usecase-admin.puml](plantuml/03-usecase-admin.puml) |
| Sequence tra cứu từ vựng | [04-sequence-vocabulary-search.puml](plantuml/04-sequence-vocabulary-search.puml) |
| Sequence học từ vựng theo chủ đề | [05-sequence-learning-flow.puml](plantuml/05-sequence-learning-flow.puml) |
| Sequence kiểm tra ngữ pháp AI | [06-sequence-grammar-check.puml](plantuml/06-sequence-grammar-check.puml) |
| Sequence luyện phát âm câu | [07-sequence-pronunciation-practice.puml](plantuml/07-sequence-pronunciation-practice.puml) |
| Sequence đọc báo và tra từ | [08-sequence-news-reading.puml](plantuml/08-sequence-news-reading.puml) |
| Activity học từ vựng | [09-activity-vocabulary-learning.puml](plantuml/09-activity-vocabulary-learning.puml) |
| Activity kiểm tra ngữ pháp | [10-activity-grammar-check.puml](plantuml/10-activity-grammar-check.puml) |
| Activity đọc báo và tra từ | [11-activity-news-reading.puml](plantuml/11-activity-news-reading.puml) |
| Activity quản lý học liệu | [12-activity-content-management.puml](plantuml/12-activity-content-management.puml) |
| Class diagram tổng quát | [13-class-domain-overview.puml](plantuml/13-class-domain-overview.puml) |
| ERD cơ sở dữ liệu | [14-erd-database.puml](plantuml/14-erd-database.puml) |

### 2.2.4. Bộ biểu đồ hoạt động hoàn chỉnh

Các biểu đồ hoạt động dưới đây được tách riêng theo từng chức năng chính để đưa trực tiếp vào Word:

| Biểu đồ hoạt động | Tệp |
| --- | --- |
| Hoạt động tra cứu từ vựng | [activity-01-vocabulary-search.puml](plantuml/activity-01-vocabulary-search.puml) |
| Hoạt động học từ vựng theo chủ đề | [activity-02-vocabulary-learning.puml](plantuml/activity-02-vocabulary-learning.puml) |
| Hoạt động xem bài học ngữ pháp | [activity-03-grammar-lessons.puml](plantuml/activity-03-grammar-lessons.puml) |
| Hoạt động kiểm tra ngữ pháp bằng AI | [activity-04-grammar-check-ai.puml](plantuml/activity-04-grammar-check-ai.puml) |
| Hoạt động luyện phát âm | [activity-05-pronunciation-practice.puml](plantuml/activity-05-pronunciation-practice.puml) |
| Hoạt động đọc báo và tra từ trong bài | [activity-06-news-reading-lookup.puml](plantuml/activity-06-news-reading-lookup.puml) |
| Hoạt động xem thống kê và đặt mục tiêu | [activity-07-stats-goals.puml](plantuml/activity-07-stats-goals.puml) |
| Hoạt động quản lý học liệu | [activity-08-admin-content-management.puml](plantuml/activity-08-admin-content-management.puml) |

### 2.2.5. Bộ biểu đồ lớp hoàn chỉnh

Các biểu đồ lớp được chia theo module giống cách trình bày trong mẫu PDF:

| Biểu đồ lớp | Tệp |
| --- | --- |
| Biểu đồ lớp module từ vựng | [class-01-vocabulary-module.puml](plantuml/class-01-vocabulary-module.puml) |
| Biểu đồ lớp module ngữ pháp | [class-02-grammar-module.puml](plantuml/class-02-grammar-module.puml) |
| Biểu đồ lớp module luyện phát âm | [class-03-pronunciation-module.puml](plantuml/class-03-pronunciation-module.puml) |
| Biểu đồ lớp module đọc báo và tra từ | [class-04-reading-module.puml](plantuml/class-04-reading-module.puml) |
| Biểu đồ lớp module thống kê và tiến độ | [class-05-progress-module.puml](plantuml/class-05-progress-module.puml) |
| Biểu đồ lớp module quản trị nội dung | [class-06-admin-content-module.puml](plantuml/class-06-admin-content-module.puml) |
| Biểu đồ lớp tổng quát toàn hệ thống | [13-class-domain-overview.puml](plantuml/13-class-domain-overview.puml) |

## 2.3. Thiết kế cơ sở dữ liệu

### 2.3.1. Định hướng thiết kế

Thiết kế CSDL được xây theo hướng triển khai thực tế và đồng bộ nhiều thiết bị, thay vì chỉ lưu cục bộ. Mục tiêu của mô hình dữ liệu là:

- Tách rõ dữ liệu nội dung học tập và dữ liệu tiến độ cá nhân.
- Dễ mở rộng khi thêm tính năng thi thử, flashcard, đồng bộ tài khoản.
- Phù hợp với các entity backend hiện có như `vocabularies`, `grammar`, `articles`, `user_progress`.
- Hỗ trợ lưu lịch sử kiểm tra ngữ pháp, lịch sử phát âm, bài đọc và thống kê ngày.

### 2.3.2. Danh sách bảng chính

| Nhóm | Bảng | Mục đích |
| --- | --- | --- |
| Tài khoản | `users` | Lưu người học và quản trị viên |
| Nội dung từ vựng | `topics`, `vocabularies`, `topic_vocabularies`, `vocabulary_examples` | Quản lý từ vựng, chủ đề và ví dụ |
| Nội dung ngữ pháp | `grammar_lessons`, `grammar_examples` | Quản lý bài học ngữ pháp theo HSK |
| Nội dung phát âm | `pronunciation_lessons`, `pronunciation_sentences` | Quản lý câu luyện phát âm |
| Nội dung bài đọc | `article_sources`, `articles` | Quản lý nguồn RSS và bài báo |
| Tiến độ từ vựng | `user_word_progress` | Lưu trạng thái đã học, đã lưu và điểm phát âm tốt nhất |
| Kiểm tra ngữ pháp | `grammar_check_sessions`, `grammar_check_issues`, `grammar_check_suggestions` | Lưu lịch sử chấm ngữ pháp bằng AI |
| Phát âm | `pronunciation_attempts` | Lưu các lần đọc thử và điểm phát âm |
| Đọc hiểu | `reading_sessions`, `reading_word_lookups` | Lưu phiên đọc báo và từ đã tra trong bài |
| Mục tiêu và thống kê | `daily_goals`, `daily_learning_stats` | Lưu mục tiêu ngày và thống kê học tập theo ngày |

### 2.3.3. Mô tả các bảng trọng tâm

#### 2.3.3.1. Bảng `users`

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
| --- | --- | --- | --- |
| `id` | `bigserial` | PK | Khóa chính |
| `email` | `varchar(150)` | Unique, null | Email đăng nhập nếu dùng tài khoản cục bộ |
| `password_hash` | `varchar(255)` | Null | Mật khẩu đã băm |
| `display_name` | `varchar(100)` | Not null | Tên hiển thị |
| `avatar_url` | `varchar(255)` | Null | Ảnh đại diện |
| `role` | `user_role` | Not null | Vai trò `LEARNER` hoặc `ADMIN` |
| `login_mode` | `login_mode` | Not null | `GUEST` hoặc `LOCAL` |
| `target_hsk_level` | `hsk_level` | Null | Cấp độ HSK mục tiêu |
| `preferred_language` | `varchar(10)` | Default `'vi'` | Ngôn ngữ ưu tiên |
| `is_active` | `boolean` | Default `true` | Trạng thái hoạt động |
| `created_at` | `timestamptz` | Not null | Thời điểm tạo |
| `updated_at` | `timestamptz` | Not null | Thời điểm cập nhật |

#### 2.3.3.2. Bảng `vocabularies`

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
| --- | --- | --- | --- |
| `id` | `bigserial` | PK | Khóa chính |
| `simplified` | `varchar(50)` | Unique, not null | Chữ Hán giản thể |
| `traditional` | `varchar(50)` | Null | Chữ Hán phồn thể |
| `pinyin` | `varchar(255)` | Null | Phiên âm pinyin |
| `meaning_vi` | `text` | Null | Nghĩa tiếng Việt |
| `meaning_en` | `text` | Null | Nghĩa tiếng Anh |
| `part_of_speech` | `varchar(50)` | Null | Từ loại |
| `radical` | `varchar(20)` | Null | Bộ thủ |
| `hsk_level` | `hsk_level` | Not null | Cấp HSK |
| `frequency` | `int` | Null | Tần suất |
| `stroke_count` | `int` | Null | Số nét |
| `metadata` | `jsonb` | Default `'{}'` | Thuộc tính mở rộng |
| `active` | `boolean` | Default `true` | Trạng thái sử dụng |

#### 2.3.3.3. Bảng `grammar_lessons`

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
| --- | --- | --- | --- |
| `id` | `bigserial` | PK | Khóa chính |
| `hsk_level` | `hsk_level` | Not null | Cấp HSK của bài học |
| `title` | `varchar(255)` | Not null | Tên bài học |
| `pattern_text` | `varchar(255)` | Null | Mẫu câu tóm tắt |
| `explanation` | `text` | Not null | Giải thích quy tắc |
| `source` | `varchar(100)` | Default `'manual'` | Nguồn nội dung |
| `active` | `boolean` | Default `true` | Trạng thái hiển thị |

#### 2.3.3.4. Bảng `articles`

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
| --- | --- | --- | --- |
| `id` | `bigserial` | PK | Khóa chính |
| `source_id` | `bigint` | FK | Nguồn bài báo |
| `title` | `text` | Not null | Tiêu đề gốc |
| `title_vi` | `text` | Null | Tiêu đề dịch |
| `content` | `text` | Not null | Nội dung bài báo |
| `link` | `text` | Null | Link bài gốc |
| `hsk_level` | `hsk_level` | Null | Cấp độ gợi ý |
| `published_at` | `timestamptz` | Null | Thời điểm xuất bản |
| `cached_at` | `timestamptz` | Null | Thời điểm hệ thống lưu cache |
| `active` | `boolean` | Default `true` | Trạng thái sử dụng |

#### 2.3.3.5. Bảng `user_word_progress`

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
| --- | --- | --- | --- |
| `id` | `bigserial` | PK | Khóa chính |
| `user_id` | `bigint` | FK, not null | Người học |
| `vocabulary_id` | `bigint` | FK, not null | Từ vựng được theo dõi |
| `is_favorite` | `boolean` | Default `false` | Có lưu vào sổ tay hay không |
| `is_learned` | `boolean` | Default `false` | Đã học hay chưa |
| `reveal_count` | `int` | Default `0` | Số lần xem nghĩa |
| `review_count` | `int` | Default `0` | Số lần ôn tập |
| `best_pronunciation_score` | `numeric(5,2)` | Default `0` | Điểm phát âm tốt nhất |
| `last_reviewed_at` | `timestamptz` | Null | Lần học gần nhất |
| `updated_at` | `timestamptz` | Not null | Lần cập nhật gần nhất |

#### 2.3.3.6. Bảng `grammar_check_sessions`

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
| --- | --- | --- | --- |
| `id` | `bigserial` | PK | Khóa chính |
| `user_id` | `bigint` | FK, not null | Người học thực hiện kiểm tra |
| `input_text` | `text` | Not null | Câu gốc người học nhập |
| `score` | `numeric(5,2)` | Not null | Điểm chấm từ AI |
| `correction_cn` | `text` | Null | Câu sửa tiếng Trung |
| `correction_pinyin` | `text` | Null | Pinyin của câu sửa |
| `correction_vi` | `text` | Null | Nghĩa tiếng Việt của câu sửa |
| `style_tips` | `text` | Null | Gợi ý học tập |
| `engine` | `grammar_engine` | Not null | Nguồn chấm như `GEMINI`, `MOCK` |
| `created_at` | `timestamptz` | Not null | Thời điểm kiểm tra |

#### 2.3.3.7. Bảng `pronunciation_attempts`

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
| --- | --- | --- | --- |
| `id` | `bigserial` | PK | Khóa chính |
| `user_id` | `bigint` | FK, not null | Người học |
| `target_type` | `pronunciation_target_type` | Not null | `WORD` hoặc `SENTENCE` |
| `vocabulary_id` | `bigint` | FK, null | Từ mục tiêu nếu là đọc từ |
| `sentence_id` | `bigint` | FK, null | Câu mục tiêu nếu là đọc câu |
| `target_text` | `text` | Not null | Nội dung chuẩn cần đọc |
| `recognized_text` | `text` | Null | Nội dung máy nhận dạng được |
| `score` | `numeric(5,2)` | Default `0` | Điểm phát âm |
| `audio_url` | `text` | Null | Đường dẫn file âm thanh nếu có |
| `created_at` | `timestamptz` | Not null | Thời điểm luyện tập |

#### 2.3.3.8. Bảng `daily_learning_stats`

| Tên cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
| --- | --- | --- | --- |
| `id` | `bigserial` | PK | Khóa chính |
| `user_id` | `bigint` | FK, not null | Người học |
| `study_date` | `date` | Unique theo user/date | Ngày thống kê |
| `learned_words_count` | `int` | Default `0` | Số từ học trong ngày |
| `review_count` | `int` | Default `0` | Số lượt ôn tập |
| `study_minutes` | `int` | Default `0` | Số phút học |
| `grammar_checks_count` | `int` | Default `0` | Số lần kiểm tra ngữ pháp |
| `pronunciation_attempts_count` | `int` | Default `0` | Số lần luyện phát âm |
| `streak_snapshot` | `int` | Default `0` | Giá trị streak tại ngày đó |

### 2.3.4. Quan hệ dữ liệu chính

- Một `user` có nhiều bản ghi trong `user_word_progress`.
- Một `vocabulary` có nhiều `vocabulary_examples`.
- Một `topic` liên kết nhiều `vocabulary` thông qua `topic_vocabularies`.
- Một `grammar_lesson` có nhiều `grammar_examples`.
- Một `pronunciation_lesson` có nhiều `pronunciation_sentences`.
- Một `article_source` có nhiều `articles`.
- Một `grammar_check_session` có nhiều `grammar_check_issues` và `grammar_check_suggestions`.
- Một `reading_session` có nhiều `reading_word_lookups`.
- Một `user` có nhiều `pronunciation_attempts`, `grammar_check_sessions`, `reading_sessions`, `daily_learning_stats`.

### 2.3.5. Tệp thiết kế vật lý

- Tệp DDL PostgreSQL: [chinese_learning_app.sql](schema/chinese_learning_app.sql)
- Tệp PlantUML ERD: [14-erd-database.puml](plantuml/14-erd-database.puml)

### 2.3.6. Gợi ý triển khai thực tế

- Nên đưa toàn bộ luồng gọi AI ngữ pháp từ mobile sang backend để bảo vệ API key.
- Nên chuyển `SharedPreferences` sang cơ chế đồng bộ với bảng `user_word_progress`, `daily_goals`, `daily_learning_stats`.
- Nên bổ sung API CRUD cho `vocabularies`, `grammar_lessons`, `articles`, `pronunciation_sentences`.
- Nên có chiến lược cache bài báo để người dùng vẫn đọc được khi RSS thay đổi hoặc tạm lỗi.

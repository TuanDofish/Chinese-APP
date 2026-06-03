# Toàn bộ code biểu đồ hoạt động

## 1. Tra cứu từ vựng

```plantuml
@startuml
skinparam backgroundColor white
skinparam shadowing false
skinparam ArrowColor #4A4A4A
skinparam defaultTextAlignment center
skinparam activity {
  BackgroundColor #F7F7F7
  BorderColor #8F8F8F
  FontColor #222222
  DiamondBackgroundColor white
  DiamondBorderColor #8F8F8F
  DiamondFontColor #222222
  StartColor black
  EndColor black
  BarColor #8F8F8F
}
title Biểu đồ hoạt động chức năng Tra cứu từ vựng

start
:Người học mở chức năng tra cứu từ;
:Nhập từ khóa cần tra;
:Kiểm tra dữ liệu đầu vào;

if (Từ khóa rỗng?) then (Có)
  :Hiển thị thông báo\nvui lòng nhập từ khóa;
  stop
else (Không)
endif

if (Từ khóa là chữ Hán?) then (Có)
  :Giữ nguyên truy vấn;
else (Không)
  :Dịch từ khóa Việt -> Trung;
  if (Dịch thành công?) then (Có)
    :Chuẩn hóa truy vấn;
  else (Không)
    :Hiển thị thông báo\nkhông tìm thấy từ phù hợp;
    stop
  endif
endif

:Tra cứu dữ liệu từ vựng;
if (Có dữ liệu cục bộ?) then (Có)
  :Lấy pinyin, nghĩa, ví dụ;
else (Không)
  :Yêu cầu dịch nghĩa Trung -> Việt;
  if (Có kết quả?) then (Có)
    :Tạo dữ liệu hiển thị tạm thời;
  else (Không)
    :Hiển thị thông báo\nkhông tra được nghĩa;
    stop
  endif
endif

:Hiển thị màn hình chi tiết từ;
if (Lưu vào sổ tay?) then (Có)
  :Cập nhật trạng thái yêu thích;
endif

:Trả kết quả cho người học;
stop
@enduml
```

## 2. Học từ vựng theo chủ đề HSK

```plantuml
@startuml
skinparam backgroundColor white
skinparam shadowing false
skinparam ArrowColor #4A4A4A
skinparam defaultTextAlignment center
skinparam activity {
  BackgroundColor #F7F7F7
  BorderColor #8F8F8F
  FontColor #222222
  DiamondBackgroundColor white
  DiamondBorderColor #8F8F8F
  DiamondFontColor #222222
  StartColor black
  EndColor black
  BarColor #8F8F8F
}
title Biểu đồ hoạt động chức năng Học từ vựng theo chủ đề HSK

start
:Người học mở mục học từ vựng HSK;
:Chọn cấp độ và chủ đề;
:Tải danh sách từ vựng theo bộ lọc;

if (Danh sách có dữ liệu?) then (Có)
  :Hiển thị từ đầu tiên;
else (Không)
  :Thông báo chưa có học liệu phù hợp;
  stop
endif

while (Còn từ cần học?) is (Có)
  :Hiển thị mặt trước của thẻ từ;
  :Người học nhấn xem đáp án;
  :Hiển thị pinyin, nghĩa, ví dụ;

  if (Đánh dấu đã học?) then (Có)
    :Lưu tiến độ học từ vựng;
  endif

  if (Nghe phát âm mẫu?) then (Có)
    :Phát âm từ bằng TTS;
  endif

  :Chuyển sang từ tiếp theo;
endwhile (Không)

:Hiển thị tổng kết buổi học;
stop
@enduml
```

## 3. Xem bài học ngữ pháp

```plantuml
@startuml
skinparam backgroundColor white
skinparam shadowing false
skinparam ArrowColor #4A4A4A
skinparam defaultTextAlignment center
skinparam activity {
  BackgroundColor #F7F7F7
  BorderColor #8F8F8F
  FontColor #222222
  DiamondBackgroundColor white
  DiamondBorderColor #8F8F8F
  DiamondFontColor #222222
  StartColor black
  EndColor black
  BarColor #8F8F8F
}
title Biểu đồ hoạt động chức năng Xem bài học ngữ pháp

start
:Người học mở mục ngữ pháp;
:Chọn cấp độ HSK hoặc bài học cụ thể;
:Tải danh sách bài học ngữ pháp;

if (Tải dữ liệu thành công?) then (Có)
  :Hiển thị danh sách bài học;
else (Không)
  :Hiển thị thông báo lỗi tải dữ liệu;
  stop
endif

:Người học chọn một bài học;
:Hiển thị cấu trúc, giải thích và ví dụ;

if (Xem ví dụ chi tiết?) then (Có)
  :Mở phần ví dụ minh họa;
endif

:Kết thúc thao tác xem bài học;
stop
@enduml
```

## 4. Kiểm tra ngữ pháp bằng AI

```plantuml
@startuml
skinparam backgroundColor white
skinparam shadowing false
skinparam ArrowColor #4A4A4A
skinparam defaultTextAlignment center
skinparam activity {
  BackgroundColor #F7F7F7
  BorderColor #8F8F8F
  FontColor #222222
  DiamondBackgroundColor white
  DiamondBorderColor #8F8F8F
  DiamondFontColor #222222
  StartColor black
  EndColor black
  BarColor #8F8F8F
}
title Biểu đồ hoạt động chức năng Kiểm tra ngữ pháp bằng AI

start
:Người học mở chức năng kiểm tra ngữ pháp;
:Nhập câu tiếng Trung cần phân tích;
:Kiểm tra dữ liệu đầu vào;

if (Câu nhập hợp lệ?) then (Có)
  :Gửi yêu cầu đến dịch vụ AI;
else (Không)
  :Hiển thị lỗi validation;
  stop
endif

:AI phân tích lỗi,\nđề xuất câu sửa và giải thích;
if (Nhận được kết quả?) then (Có)
  :Hiển thị câu sửa,\nlỗi và gợi ý diễn đạt;
else (Không)
  :Thông báo không thể phân tích lúc này;
  stop
endif

:Người học xem và đối chiếu kết quả;
stop
@enduml
```

## 5. Luyện phát âm

```plantuml
@startuml
skinparam backgroundColor white
skinparam shadowing false
skinparam ArrowColor #4A4A4A
skinparam defaultTextAlignment center
skinparam activity {
  BackgroundColor #F7F7F7
  BorderColor #8F8F8F
  FontColor #222222
  DiamondBackgroundColor white
  DiamondBorderColor #8F8F8F
  DiamondFontColor #222222
  StartColor black
  EndColor black
  BarColor #8F8F8F
}
title Biểu đồ hoạt động chức năng Luyện phát âm

start
:Người học mở chức năng luyện phát âm;
:Chọn câu mẫu cần luyện;
:Hiển thị chữ Hán, pinyin và nghĩa;

if (Nghe phát âm mẫu?) then (Có)
  :Phát âm mẫu bằng TTS;
endif

:Người học bắt đầu ghi âm;
:Thu âm và nhận diện giọng nói;

if (Nhận diện thành công?) then (Có)
  :So khớp với câu mẫu;
  :Tính điểm phát âm;
  :Hiển thị câu nhận diện và điểm số;
else (Không)
  :Thông báo chưa nhận diện được giọng nói;
  stop
endif

if (Luyện lại?) then (Có)
  :Quay lại bước ghi âm;
endif

:Lưu kết quả gần nhất;
stop
@enduml
```

## 6. Đọc báo và tra từ trong bài

```plantuml
@startuml
skinparam backgroundColor white
skinparam shadowing false
skinparam ArrowColor #4A4A4A
skinparam defaultTextAlignment center
skinparam activity {
  BackgroundColor #F7F7F7
  BorderColor #8F8F8F
  FontColor #222222
  DiamondBackgroundColor white
  DiamondBorderColor #8F8F8F
  DiamondFontColor #222222
  StartColor black
  EndColor black
  BarColor #8F8F8F
}
title Biểu đồ hoạt động chức năng Đọc báo và tra từ trong bài

start
:Người học mở chức năng đọc báo tiếng Trung;
:Tải danh sách bài báo từ RSS;

if (Có bài báo?) then (Có)
  :Hiển thị danh sách bài viết;
else (Không)
  :Thông báo không tải được dữ liệu;
  stop
endif

:Người học chọn bài báo;
:Hiển thị nội dung bài viết;

if (Người học nhấn vào từ cần tra?) then (Có)
  :Gửi yêu cầu tra cứu từ vựng;
  if (Có dữ liệu nghĩa?) then (Có)
    :Hiển thị popup nghĩa,\npinyin và ví dụ;
  else (Không)
    :Hiển thị thông báo\nkhông tra được từ này;
  endif
endif

if (Lưu bài báo yêu thích?) then (Có)
  :Cập nhật trạng thái bài báo;
endif

:Kết thúc phiên đọc báo;
stop
@enduml
```

## 7. Xem thống kê và đặt mục tiêu

```plantuml
@startuml
skinparam backgroundColor white
skinparam shadowing false
skinparam ArrowColor #4A4A4A
skinparam defaultTextAlignment center
skinparam activity {
  BackgroundColor #F7F7F7
  BorderColor #8F8F8F
  FontColor #222222
  DiamondBackgroundColor white
  DiamondBorderColor #8F8F8F
  DiamondFontColor #222222
  StartColor black
  EndColor black
  BarColor #8F8F8F
}
title Biểu đồ hoạt động chức năng Xem thống kê và đặt mục tiêu

start
:Người học mở màn hình thống kê;
:Tải dữ liệu tiến độ học tập;

if (Có dữ liệu thống kê?) then (Có)
  :Hiển thị số từ đã học,\nstreak và thời gian học;
else (Không)
  :Hiển thị trạng thái khởi tạo ban đầu;
endif

if (Người học cập nhật mục tiêu?) then (Có)
  :Nhập số từ hoặc số phút mục tiêu;
  :Kiểm tra dữ liệu mục tiêu;
  if (Dữ liệu hợp lệ?) then (Có)
    :Lưu mục tiêu mới;
    :Thông báo cập nhật thành công;
  else (Không)
    :Hiển thị lỗi validation;
    stop
  endif
endif

:Kết thúc thao tác theo dõi tiến độ;
stop
@enduml
```

## 8. Quản lý học liệu

```plantuml
@startuml
skinparam backgroundColor white
skinparam shadowing false
skinparam ArrowColor #4A4A4A
skinparam defaultTextAlignment center
skinparam activity {
  BackgroundColor #F7F7F7
  BorderColor #8F8F8F
  FontColor #222222
  DiamondBackgroundColor white
  DiamondBorderColor #8F8F8F
  DiamondFontColor #222222
  StartColor black
  EndColor black
  BarColor #8F8F8F
}
title Biểu đồ hoạt động chức năng Quản lý học liệu

start
:Quản trị viên chọn loại học liệu;
:Nhập mới hoặc chỉnh sửa dữ liệu;
:Kiểm tra trường bắt buộc;

if (Dữ liệu hợp lệ?) then (Có)
  :Lưu vào cơ sở dữ liệu;
  if (Ẩn nội dung?) then (Có)
    :Đặt active = false;
  endif
  :Thông báo thành công;
else (Không)
  :Hiển thị lỗi validation;
endif

stop
@enduml
```

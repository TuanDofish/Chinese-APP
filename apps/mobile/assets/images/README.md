# 📁 Hướng Dẫn Cấu Trúc Thư Mục Ảnh (Assets)

Để App tự động nhận diện và hiển thị ảnh đúng chỗ, bạn chỉ cần thả ảnh vào 2 thư mục con dưới đây theo đúng nguyên tắc:

## 1. 📂 Mục `topics` (Ảnh các chủ đề HSK)
- **Công dụng:** Chứa các hình vuông nhỏ hiển thị ở bảng danh sách các bài học (Ví dụ: cái giỏ hàng cho mua sắm, con chó cho thú cưng).
- **Cách đặt tên:** Bắt buộc phải khớp với tên `imageFile` trong code.
  - Ví dụ: `hsk1_country.png`, `hsk1_pet.png`, `hsk1_shopping.png`
- **Định dạng:** `.png` (khuyên dùng nền trong suốt).

## 2. 📂 Mục `words` (Ảnh cho từng từ vựng)
- **Công dụng:** Chứa ảnh minh họa to, rõ ràng cho từng từ vựng cụ thể. Sẽ hiển thị ở nửa trên của thẻ Flashcard (thay cho nền màu trơn).
- **Cách đặt tên:** CỰC KỲ ĐƠN GIẢN! Lấy đúng **chữ Hán (Giản thể)** của từ đó làm tên file.
  - Từ "Chó": thả file `狗.png` vào thư mục này.
  - Từ "Bắc Kinh": thả file `北京.png` vào thư mục này.
  - Từ "Mua": thả file `买.png` vào thư mục này.
- **Định dạng:** `.png` hoặc `.jpg`.
- **Lưu ý:** Không cần chia thư mục con HSK1, HSK2 ở trong này đâu nhé! Thả phẳng (flat) tất cả vào mục `words` luôn. Code sẽ tự động tìm kiếm dựa trên chữ Hán. Nếu từ nào chưa có ảnh, app vẫn không lỗi mà sẽ hiện khung màu sắc rất đẹp.

---
*Lưu ý cho lập trình viên/người dùng: Mỗi khi thêm/sửa/xóa file trong này, bạn hãy mở terminal và lưu file code hoặc bấm `r` (Hot reload) trên terminal Flutter để app nhận diện file mới nhé!*

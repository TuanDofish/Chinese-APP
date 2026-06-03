class VocabDataHelper {
  // ... HSK 1 Data (Keep existing)

  // HSK 2 Data (New Expansion)
  static final Map<String, Map<String, dynamic>> _hsk2Map = {
     // Colors
    "颜色": {"meaning": "Màu sắc", "examples": [{"cn": "你喜欢什么颜色？", "py": "Nǐ xǐhuān shénme yánsè?", "vi": "Bạn thích màu gì?"}]},
    "红": {"meaning": "Màu đỏ", "examples": [{"cn": "红色的苹果。", "py": "Hóngsè de píngguǒ.", "vi": "Quả táo màu đỏ."}]},
    "白": {"meaning": "Màu trắng", "examples": [{"cn": "白色的衣服。", "py": "Báisè de yīfu.", "vi": "Quần áo màu trắng."}]},
    "黑": {"meaning": "Màu đen", "examples": [{"cn": "黑色的车。", "py": "Hēisè de chē.", "vi": "Chiếc xe màu đen."}]},
    
    // Time & Frequency
    "早上": {"meaning": "Buổi sáng", "examples": [{"cn": "早上好。", "py": "Zǎoshang hǎo.", "vi": "Chào buổi sáng."}]},
    "晚上": {"meaning": "Buổi tối", "examples": [{"cn": "晚上我不出门。", "py": "Wǎnshang wǒ bù chūmén.", "vi": "Buổi tối tôi không ra ngoài."}]},
    "每天": {"meaning": "Mỗi ngày", "examples": [{"cn": "我每天都学汉语。", "py": "Wǒ měitiān dōu xué Hànyǔ.", "vi": "Tôi học tiếng Trung mỗi ngày."}]},
    "虽然": {"meaning": "Tuy, mặc dù", "examples": [{"cn": "虽然...", "py": "Suīrán...", "vi": "Tuy rằng..."}]},
    "但是": {"meaning": "Nhưng", "examples": [{"cn": "但是...", "py": "Dànshì...", "vi": "Nhưng mà..."}]},

    // Common Verbs HSK 2
    "帮助": {"meaning": "Giúp đỡ", "examples": [{"cn": "谢谢你的帮助。", "py": "Xièxie nǐ de bāngzhù.", "vi": "Cảm ơn sự giúp đỡ của bạn."}]},
    "开始": {"meaning": "Bắt đầu", "examples": [{"cn": "我们开始吧。", "py": "Wǒmen kāishǐ ba.", "vi": "Chúng ta bắt đầu thôi."}]},
    "介绍": {"meaning": "Giới thiệu", "examples": [{"cn": "我来介绍一下。", "py": "Wǒ lái jièshào yíxià.", "vi": "Để tôi giới thiệu một chút."}]},
    "准备": {"meaning": "Chuẩn bị", "examples": [{"cn": "你准备好了吗？", "py": "Nǐ zhǔnbèi hǎo le ma?", "vi": "Bạn chuẩn bị xong chưa?"}]},
    "可以": {"meaning": "Có thể", "examples": [{"cn": "我可以进来吗？", "py": "Wǒ kěyǐ jìnlái ma?", "vi": "Tôi có thể vào không?"}]},
    
    // ... Add ~50 more common HSK 2 words
  };

  // Automated Dictionary for higher levels (Keyword matching)
  static final Map<String, String> _dictionary = {
    "work": "Làm việc",
    "study": "Học tập",
    "love": "Yêu",
    "like": "Thích",
    "book": "Sách",
    "person": "Người",
    "man": "Đàn ông",
    "woman": "Phụ nữ",
    "child": "Trẻ em",
    "water": "Nước",
    "fire": "Lửa",
    "big": "To lớn",
    "small": "Nhỏ bé",
    "good": "Tốt",
    "bad": "Xấu",
    "beautiful": "Xinh đẹp",
    "happy": "Vui vẻ",
    "sad": "Buồn",
    "fast": "Nhanh",
    "slow": "Chậm",
    // ...
  };

  // Logic:
  // 1. Check HSK 1 Map
  // 2. Check HSK 2 Map
  // 3. Fallback: Translate English Meaning using _dictionary keywords
  // 4. Fallback: Show English meaning (Cleaned)
}

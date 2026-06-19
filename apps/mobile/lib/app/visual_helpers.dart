part of '../main.dart';

List<Color> _visualPalette(String key) {
  const palettes = [
    [Color(0xFFE85045), Color(0xFFF4B942)],
    [Color(0xFF1B7F79), Color(0xFF61C3A5)],
    [Color(0xFF2364AA), Color(0xFF73A5E8)],
    [Color(0xFF7A4EAB), Color(0xFFD782BA)],
    [Color(0xFF2F7D4F), Color(0xFF9CCC65)],
    [Color(0xFFB45F06), Color(0xFFFFB74D)],
    [Color(0xFF455A64), Color(0xFF90A4AE)],
    [Color(0xFFAD1457), Color(0xFFF06292)],
  ];
  final index =
      key.codeUnits.fold<int>(0, (sum, code) => sum + code) % palettes.length;
  return palettes[index];
}

Color _pairedVisualColor(Color color) {
  if (color == AppColors.amber) return AppColors.cinnabar;
  if (color == AppColors.blue) return AppColors.jade;
  if (color == AppColors.jade) return AppColors.amber;
  if (color == AppColors.plum) return AppColors.blue;
  return AppColors.amber;
}

IconData _visualIconFor(VocabEntry entry) {
  final text = '${entry.simplified}${entry.meaning}${entry.wordType}';
  if (RegExp(r'吃|喝|饭|菜|水果|苹果|茶|food|cơm|ăn|uống').hasMatch(text)) {
    return Icons.restaurant_outlined;
  }
  if (RegExp(r'飞机|汽车|车|地铁|路|机场|旅游|đi|bay|giao thông').hasMatch(text)) {
    return Icons.travel_explore_outlined;
  }
  if (RegExp(r'学习|学校|老师|学生|书|考试|học|trường').hasMatch(text)) {
    return Icons.school_outlined;
  }
  if (RegExp(r'爸爸|妈妈|家|朋友|同学|bạn|gia đình').hasMatch(text)) {
    return Icons.groups_outlined;
  }
  if (RegExp(r'公司|工作|经理|会议|市场|经济|công việc|kinh tế').hasMatch(text)) {
    return Icons.business_center_outlined;
  }
  if (RegExp(r'天气|热|冷|雨|雪|风|mưa|nóng|lạnh').hasMatch(text)) {
    return Icons.wb_sunny_outlined;
  }
  if (RegExp(r'手机|电脑|网络|信息|ảnh|máy|internet').hasMatch(text)) {
    return Icons.devices_outlined;
  }
  if (RegExp(r'眼睛|手|脚|身体|医院|医生|sức khỏe').hasMatch(text)) {
    return Icons.health_and_safety_outlined;
  }
  return Icons.auto_awesome_outlined;
}

Color _levelColor(String level) {
  switch (level) {
    case 'HSK 1':
      return AppColors.amber;
    case 'HSK 2':
      return AppColors.blue;
    case 'HSK 3':
      return AppColors.jade;
    case 'HSK 4':
      return AppColors.plum;
    default:
      return AppColors.cinnabar;
  }
}

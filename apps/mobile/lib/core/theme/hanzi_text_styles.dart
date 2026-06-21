import 'package:flutter/material.dart';

/// Shared high-contrast typography for Chinese learning content.
abstract final class HanziTextStyles {
  static const _fallbacks = <String>[
    'Noto Sans SC',
    'Microsoft YaHei',
    'PingFang SC',
    'Hiragino Sans GB',
    'SimHei',
    'sans-serif',
  ];

  static const display = TextStyle(
    fontFamily: 'NotoSansSC',
    fontFamilyFallback: _fallbacks,
    fontSize: 72,
    height: 1.12,
    fontWeight: FontWeight.w800,
    color: Color(0xFF151922),
  );

  static const reading = TextStyle(
    fontFamily: 'NotoSansSC',
    fontFamilyFallback: _fallbacks,
    fontSize: 22,
    height: 1.58,
    fontWeight: FontWeight.w800,
    color: Color(0xFF151922),
  );

  static const pinyin = TextStyle(
    fontSize: 15,
    height: 1.42,
    fontWeight: FontWeight.w700,
    color: Color(0xFFB33B32),
  );

  static const translation = TextStyle(
    fontSize: 14.5,
    height: 1.45,
    fontWeight: FontWeight.w600,
    color: Color(0xFF374151),
  );

  static const gameAnswer = TextStyle(
    fontFamily: 'NotoSansSC',
    fontFamilyFallback: _fallbacks,
    fontSize: 30,
    height: 1.18,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}

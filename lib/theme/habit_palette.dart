import 'package:flutter/material.dart';

/// 习惯可选的 ARGB 调色板。每个习惯只能从这套固定颜色里选，
/// 避免用户随便选出来的颜色破坏 Material 3 整体感。
class HabitPalette {
  HabitPalette._();

  static const List<Color> colors = <Color>[
    Color(0xFFEF5350), // 红
    Color(0xFFFF9800), // 橙
    Color(0xFFFFC107), // 琥珀
    Color(0xFF66BB6A), // 绿
    Color(0xFF26A69A), // 青
    Color(0xFF42A5F5), // 蓝
    Color(0xFF7E57C2), // 紫
    Color(0xFFEC407A), // 粉
    Color(0xFF8D6E63), // 棕
    Color(0xFF78909C), // 蓝灰
  ];

  static Color byValue(int argb) => Color(argb);

  static int toValue(Color color) =>
      (((color.a * 255.0).round() & 0xff) << 24) |
      (((color.r * 255.0).round() & 0xff) << 16) |
      (((color.g * 255.0).round() & 0xff) << 8) |
      ((color.b * 255.0).round() & 0xff);

  static int get defaultIndex => 3; // 绿
}
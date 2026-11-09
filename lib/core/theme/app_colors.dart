import 'package:flutter/painting.dart';

/// Color tokens of the design system.
abstract final class AppColors {
  static const seed = Color(0xFF6D4C41);

  static const boardLight = Color(0xFFF0D9B5);
  static const boardDark = Color(0xFF8B5A3C);
  static const boardFrame = Color(0xFF4E342E);

  static const pieceWhite = Color(0xFFFAF7F0);
  static const pieceWhiteEdge = Color(0xFFBDB5A6);
  static const pieceBlack = Color(0xFF2B2B2B);
  static const pieceBlackEdge = Color(0xFF000000);
  static const crown = Color(0xFFFFC107);

  static const selected = Color(0xFF42A5F5);
  static const target = Color(0xC066BB6A);
  static const movable = Color(0x80FFEB3B);
  static const lastMove = Color(0x6629B6F6);
}

// Renders the app icon and the splash logo with the app's own colours.
// Run: flutter test tool/render_icon.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:checkers_app/core/theme/app_colors.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _render(String path, {required bool background}) async {
  const size = 1024.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (background) {
    const cell = size / 4;
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        final dark = (r + c).isOdd;
        canvas.drawRect(
          Rect.fromLTWH(c * cell, r * cell, cell, cell),
          Paint()..color = dark ? AppColors.boardDark : AppColors.boardLight,
        );
      }
    }
  }
  const center = Offset(size / 2, size / 2);
  const radius = size * 0.3;
  canvas
    ..drawCircle(
      center.translate(0, size * 0.025),
      radius,
      Paint()..color = const Color(0x55000000),
    )
    ..drawCircle(center, radius, Paint()..color = AppColors.pieceWhite)
    ..drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.pieceWhiteEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.03,
    )
    ..drawCircle(
      center,
      radius * 0.68,
      Paint()
        ..color = AppColors.pieceWhiteEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.02,
    );
  const r = radius * 0.42;
  final crown = Path()
    ..moveTo(center.dx - r, center.dy + r * 0.6)
    ..lineTo(center.dx - r, center.dy - r * 0.4)
    ..lineTo(center.dx - r * 0.5, center.dy)
    ..lineTo(center.dx, center.dy - r * 0.8)
    ..lineTo(center.dx + r * 0.5, center.dy)
    ..lineTo(center.dx + r, center.dy - r * 0.4)
    ..lineTo(center.dx + r, center.dy + r * 0.6)
    ..close();
  canvas.drawPath(crown, Paint()..color = AppColors.crown);
  final image = await recorder.endRecording().toImage(
    size.toInt(),
    size.toInt(),
  );
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(png!.buffer.asUint8List());
}

void main() {
  test('render branding', () async {
    await _render('assets/branding/icon.png', background: true);
    await _render('assets/branding/splash.png', background: false);
  });
}

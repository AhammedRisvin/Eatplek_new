// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final barTop = size.height * 0.03;
    final bumpWidth = size.width * 0.34;
    final bumpHeight = size.height * 0.55;
    final cornerRadius = size.width * 0.04;
    final left = (size.width / 2) - (bumpWidth / 2);
    final right = (size.width / 2) + (bumpWidth / 2);
    final center = size.width / 2;
    final bumpPeak = -bumpHeight;

    final topEdgePath =
        Path()
          ..moveTo(0, barTop + cornerRadius)
          ..quadraticBezierTo(0, barTop, cornerRadius, barTop)
          ..lineTo(left, barTop)
          ..cubicTo(
            left + (bumpWidth * 0.24),
            barTop,
            center - (bumpWidth * 0.28),
            bumpPeak,
            center,
            bumpPeak,
          )
          ..cubicTo(
            center + (bumpWidth * 0.28),
            bumpPeak,
            right - (bumpWidth * 0.24),
            barTop,
            right,
            barTop,
          )
          ..lineTo(size.width - cornerRadius, barTop)
          ..quadraticBezierTo(
            size.width,
            barTop,
            size.width,
            barTop + cornerRadius,
          );

    final path =
        Path()
          ..moveTo(0, barTop + cornerRadius)
          ..quadraticBezierTo(0, barTop, cornerRadius, barTop)
          ..lineTo(left, barTop)
          ..cubicTo(
            left + (bumpWidth * 0.24),
            barTop,
            center - (bumpWidth * 0.28),
            bumpPeak,
            center,
            bumpPeak,
          )
          ..cubicTo(
            center + (bumpWidth * 0.28),
            bumpPeak,
            right - (bumpWidth * 0.24),
            barTop,
            right,
            barTop,
          )
          ..lineTo(size.width - cornerRadius, barTop)
          ..quadraticBezierTo(
            size.width,
            barTop,
            size.width,
            barTop + cornerRadius,
          )
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();

    canvas.drawPath(
      topEdgePath,
      Paint()
        ..color = Colors.black.withOpacity(0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawShadow(path, Colors.black.withOpacity(0.16), 18, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

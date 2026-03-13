// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    // Flat bar — no bump (marketplace FAB coming soon)
    // ── Previous bump painter code kept below for future use ──
    // double bumpWidth = size.width * 0.25;
    // double bumpHeight = size.height * 0.5;
    // double cornerRadius = size.width * 0.04;
    // double left = (size.width / 2) - (bumpWidth / 2);
    // double right = (size.width / 2) + (bumpWidth / 2);
    // Path path = Path();
    // path.moveTo(0, cornerRadius);
    // path.quadraticBezierTo(0, 0, cornerRadius, 0);
    // path.lineTo(left, 0);
    // path.quadraticBezierTo(left + (bumpWidth * 0.16), 0, left + (bumpWidth * 0.24), -bumpHeight * 0.4);
    // path.quadraticBezierTo(size.width / 2, -bumpHeight, right - (bumpWidth * 0.24), -bumpHeight * 0.4);
    // path.quadraticBezierTo(right - (bumpWidth * 0.16), 0, right, 0);
    // path.lineTo(size.width - cornerRadius, 0);
    // path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    // path.lineTo(size.width, size.height);
    // path.lineTo(0, size.height);
    // path.close();
    // canvas.drawShadow(path, shadowColor, 8, false);
    // canvas.drawPath(path, paint);

    final Path path =
        Path()
          ..moveTo(0, 0)
          ..lineTo(size.width, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

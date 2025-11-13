// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    // Subtle shadow
    final shadowColor = Colors.black.withOpacity(0.1);

    // Compact bump controls - reduced by ~50%
    double bumpWidth = size.width * 0.25; // Responsive width
    double bumpHeight = size.height * 0.5; // Compact height
    double cornerRadius = size.width * 0.04; // Responsive corner radius

    double left = (size.width / 2) - (bumpWidth / 2);
    double right = (size.width / 2) + (bumpWidth / 2);

    Path path = Path();

    /// LEFT ROUNDED CORNER
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    /// STRAIGHT LINE BEFORE BUMP
    path.lineTo(left, 0);

    /// ENTER BUMP – SMOOTH
    path.quadraticBezierTo(left + (bumpWidth * 0.16), 0, left + (bumpWidth * 0.24), -bumpHeight * 0.4);

    /// CENTER BUMP – GENTLE WAVE
    path.quadraticBezierTo(size.width / 2, -bumpHeight, right - (bumpWidth * 0.24), -bumpHeight * 0.4);

    /// EXIT BUMP – SMOOTH
    path.quadraticBezierTo(right - (bumpWidth * 0.16), 0, right, 0);

    /// RIGHT ROUNDED CORNER
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    /// BOTTOM AREA
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    /// SHADOW
    canvas.drawShadow(path, shadowColor, 8, false);

    /// FILL
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

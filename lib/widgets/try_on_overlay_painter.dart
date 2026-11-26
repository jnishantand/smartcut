import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../models/try_on_style.dart';

class TryOnOverlayPainter extends CustomPainter {
  final Face? face;
  final Size imageSize;
  final TryOnStyle? hairStyle;
  final TryOnStyle? beardStyle;
  final ui.Image? hairImage;
  final ui.Image? beardImage;
  final double userScale;
  final double userOffsetY;
  final double userRotation;
  final bool isMirrored;

  TryOnOverlayPainter({
    required this.face,
    required this.imageSize,
    this.hairStyle,
    this.beardStyle,
    this.hairImage,
    this.beardImage,
    this.userScale = 1.0,
    this.userOffsetY = 0.0,
    this.userRotation = 0.0,
    this.isMirrored = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (face == null || imageSize.width == 0 || imageSize.height == 0) return;

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    // Center of face bounding box
    final Rect rect = face!.boundingBox;
    final double faceCenterX = (rect.left + rect.width / 2) * scaleX;
    final double faceCenterY = (rect.top + rect.height / 2) * scaleY;
    final double faceWidth = rect.width * scaleX;
    final double faceHeight = rect.height * scaleY;

    final double rollAngle = ((face!.headEulerAngleZ ?? 0) * math.pi / 180) + (userRotation * math.pi / 180);

    // 1. Draw Hairstyle Overlay
    if (hairStyle != null) {
      canvas.save();

      // Hair Anchor Point: Forehead / Top of face
      final double hairX = faceCenterX;
      final double hairY = faceCenterY + (hairStyle!.verticalOffset * faceHeight) + (userOffsetY * faceHeight);

      canvas.translate(hairX, hairY);
      canvas.rotate(rollAngle);

      final double hairWidth = faceWidth * hairStyle!.scaleFactor * userScale * 1.35;
      final double hairHeight = hairWidth * 0.9;

      if (hairImage != null) {
        // Draw loaded PNG asset
        final Rect dstRect = Rect.fromCenter(
          center: Offset.zero,
          width: hairWidth,
          height: hairHeight,
        );
        final Rect srcRect = Rect.fromLTWH(0, 0, hairImage!.width.toDouble(), hairImage!.height.toDouble());
        canvas.drawImageRect(hairImage!, srcRect, dstRect, Paint()..filterQuality = FilterQuality.high);
      } else {
        // Vector fallback preview for hairstyle
        _drawHairVector(canvas, hairWidth, hairHeight, hairStyle!.primaryColor);
      }

      canvas.restore();
    }

    // 2. Draw Beard Style Overlay
    if (beardStyle != null && beardStyle!.id != 'b_clean_shave') {
      canvas.save();

      // Beard Anchor Point: Lower face / Chin
      final double beardX = faceCenterX;
      final double beardY = faceCenterY + (beardStyle!.verticalOffset * faceHeight) + (userOffsetY * faceHeight * 0.5);

      canvas.translate(beardX, beardY);
      canvas.rotate(rollAngle);

      final double beardWidth = faceWidth * beardStyle!.scaleFactor * userScale * 1.15;
      final double beardHeight = beardWidth * 0.85;

      if (beardImage != null) {
        // Draw loaded PNG asset
        final Rect dstRect = Rect.fromCenter(
          center: Offset.zero,
          width: beardWidth,
          height: beardHeight,
        );
        final Rect srcRect = Rect.fromLTWH(0, 0, beardImage!.width.toDouble(), beardImage!.height.toDouble());
        canvas.drawImageRect(beardImage!, srcRect, dstRect, Paint()..filterQuality = FilterQuality.high);
      } else {
        // Vector fallback preview for beard style
        _drawBeardVector(canvas, beardWidth, beardHeight, beardStyle!.primaryColor, beardStyle!.id);
      }

      canvas.restore();
    }
  }

  void _drawHairVector(Canvas canvas, double width, double height, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    // Dome/cap shape for hairstyle
    path.moveTo(-width * 0.5, height * 0.1);
    path.cubicTo(
      -width * 0.55, -height * 0.6,
      width * 0.55, -height * 0.6,
      width * 0.5, height * 0.1,
    );
    path.cubicTo(
      width * 0.3, height * 0.3,
      -width * 0.3, height * 0.3,
      -width * 0.5, height * 0.1,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawBeardVector(Canvas canvas, double width, double height, Color color, String styleId) {
    final paint = Paint()
      ..color = color
      ..style = styleId.contains('stubble') ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = styleId.contains('stubble') ? 4.0 : 1.0
      ..isAntiAlias = true;

    final path = Path();

    if (styleId.contains('goatee') || styleId.contains('van_dyke')) {
      // Goatee / Chin loop
      path.addOval(Rect.fromCenter(center: Offset(0, height * 0.2), width: width * 0.4, height: height * 0.5));
    } else if (styleId.contains('moustache')) {
      // Mustache loop
      path.addOval(Rect.fromCenter(center: Offset(0, -height * 0.15), width: width * 0.6, height: height * 0.25));
    } else {
      // Full beard jawline U-shape
      path.moveTo(-width * 0.45, -height * 0.2);
      path.quadraticBezierTo(0, height * 0.6, width * 0.45, -height * 0.2);
      path.quadraticBezierTo(0, height * 0.2, -width * 0.45, -height * 0.2);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TryOnOverlayPainter oldDelegate) {
    return oldDelegate.face != face ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.hairStyle != hairStyle ||
        oldDelegate.beardStyle != beardStyle ||
        oldDelegate.hairImage != hairImage ||
        oldDelegate.beardImage != beardImage ||
        oldDelegate.userScale != userScale ||
        oldDelegate.userOffsetY != userOffsetY ||
        oldDelegate.userRotation != userRotation;
  }
}

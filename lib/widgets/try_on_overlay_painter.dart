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
  final Color hairColor;

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
    this.hairColor = const Color(0xFF2B1D19),
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

    // 1. SKIN CLEARING & BLENDING LAYER (Erases/blends existing hair & beard with natural skin mask)
    if (hairStyle != null || beardStyle != null) {
      _drawSkinClearingMask(canvas, faceCenterX, faceCenterY, faceWidth, faceHeight, rollAngle);
    }

    // 2. Draw Realistic Hairstyle Overlay
    if (hairStyle != null) {
      canvas.save();

      final double hairX = faceCenterX;
      final double hairY = faceCenterY + (hairStyle!.verticalOffset * faceHeight) + (userOffsetY * faceHeight);

      canvas.translate(hairX, hairY);
      canvas.rotate(rollAngle);

      final double hairWidth = faceWidth * hairStyle!.scaleFactor * userScale * 1.35;
      final double hairHeight = hairWidth * 0.95;

      if (hairImage != null) {
        final Rect dstRect = Rect.fromCenter(center: Offset.zero, width: hairWidth, height: hairHeight);
        final Rect srcRect = Rect.fromLTWH(0, 0, hairImage!.width.toDouble(), hairImage!.height.toDouble());
        final Paint p = Paint()
          ..filterQuality = FilterQuality.high
          ..colorFilter = ColorFilter.mode(hairColor, BlendMode.modulate);
        canvas.drawImageRect(hairImage!, srcRect, dstRect, p);
      } else {
        _drawRealisticHair(canvas, hairWidth, hairHeight, hairStyle!.id, hairColor);
      }

      canvas.restore();
    }

    // 3. Draw Realistic Beard Style Overlay
    if (beardStyle != null && beardStyle!.id != 'b_clean_shave') {
      canvas.save();

      final double beardX = faceCenterX;
      final double beardY = faceCenterY + (beardStyle!.verticalOffset * faceHeight) + (userOffsetY * faceHeight * 0.5);

      canvas.translate(beardX, beardY);
      canvas.rotate(rollAngle);

      final double beardWidth = faceWidth * beardStyle!.scaleFactor * userScale * 1.15;
      final double beardHeight = beardWidth * 0.85;

      if (beardImage != null) {
        final Rect dstRect = Rect.fromCenter(center: Offset.zero, width: beardWidth, height: beardHeight);
        final Rect srcRect = Rect.fromLTWH(0, 0, beardImage!.width.toDouble(), beardImage!.height.toDouble());
        final Paint p = Paint()
          ..filterQuality = FilterQuality.high
          ..colorFilter = ColorFilter.mode(hairColor, BlendMode.modulate);
        canvas.drawImageRect(beardImage!, srcRect, dstRect, p);
      } else {
        _drawRealisticBeard(canvas, beardWidth, beardHeight, beardStyle!.id, hairColor);
      }

      canvas.restore();
    }
  }

  // Soft Skin Concealer Mask to erase existing hair/beard boundaries like Snapchat
  void _drawSkinClearingMask(Canvas canvas, double cx, double cy, double w, double h, double angle) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    // Natural skin blending gradient
    final maskPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(0, -h * 0.1),
        w * 0.65,
        [
          const Color(0x33E5B899), // Subtle skin tone center
          const Color(0x22D4A37E),
          Colors.transparent,
        ],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawOval(Rect.fromCenter(center: Offset(0, -h * 0.25), width: w * 1.1, height: h * 0.5), maskPaint);

    if (beardStyle != null) {
      final beardMaskPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(0, h * 0.35),
          w * 0.6,
          [
            const Color(0x44E5B899),
            const Color(0x22D4A37E),
            Colors.transparent,
          ],
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

      canvas.drawOval(Rect.fromCenter(center: Offset(0, h * 0.35), width: w * 0.95, height: h * 0.45), beardMaskPaint);
    }

    canvas.restore();
  }

  // Realistic Multi-Tonal Hair Rendering with Gradient Volume & Hair Strands
  void _drawRealisticHair(Canvas canvas, double w, double h, String styleId, Color baseColor) {
    final Color highlightColor = Color.alphaBlend(Colors.white.withOpacity(0.25), baseColor);
    final Color shadowColor = Color.alphaBlend(Colors.black.withOpacity(0.4), baseColor);

    // Base Hair Volume Gradient
    final Paint volumePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, -h * 0.5),
        Offset(0, h * 0.4),
        [highlightColor, baseColor, shadowColor],
      )
      ..isAntiAlias = true;

    final Path mainHairPath = Path();

    if (styleId.contains('fade') || styleId.contains('crew') || styleId.contains('buzz')) {
      // Crop / Fade Volumetric Shape
      mainHairPath.moveTo(-w * 0.48, h * 0.15);
      mainHairPath.cubicTo(
        -w * 0.52, -h * 0.55,
        w * 0.52, -h * 0.55,
        w * 0.48, h * 0.15,
      );
      mainHairPath.cubicTo(
        w * 0.35, h * 0.05,
        -w * 0.35, h * 0.05,
        -w * 0.48, h * 0.15,
      );
    } else if (styleId.contains('pompadour') || styleId.contains('quiff')) {
      // High Swept Pompadour Volume
      mainHairPath.moveTo(-w * 0.45, h * 0.1);
      mainHairPath.cubicTo(
        -w * 0.55, -h * 0.85,
        w * 0.3, -h * 0.80,
        w * 0.48, h * 0.1,
      );
      mainHairPath.cubicTo(
        w * 0.25, h * 0.05,
        -w * 0.25, h * 0.05,
        -w * 0.45, h * 0.1,
      );
    } else {
      // Standard Flowing Hair Volume
      mainHairPath.moveTo(-w * 0.5, h * 0.2);
      mainHairPath.cubicTo(
        -w * 0.58, -h * 0.65,
        w * 0.58, -h * 0.65,
        w * 0.5, h * 0.2,
      );
      mainHairPath.cubicTo(
        w * 0.3, h * 0.08,
        -w * 0.3, h * 0.08,
        -w * 0.5, h * 0.2,
      );
    }
    mainHairPath.close();

    // 1. Draw base volumetric hair mass
    canvas.drawPath(mainHairPath, volumePaint);

    // 2. Draw Realistic Individual Hair Strands & Texture Lines
    final Paint strandPaint = Paint()
      ..color = highlightColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..isAntiAlias = true;

    final rand = math.Random(styleId.hashCode);
    for (int i = 0; i < 24; i++) {
      final double startX = (rand.nextDouble() - 0.5) * w * 0.7;
      final double startY = -h * 0.1 - (rand.nextDouble() * h * 0.35);
      final double endX = startX + (rand.nextDouble() - 0.5) * 30;
      final double endY = startY + 25 + rand.nextDouble() * 20;

      final strandPath = Path();
      strandPath.moveTo(startX, startY);
      strandPath.quadraticBezierTo(
        startX + (rand.nextDouble() - 0.5) * 15,
        startY + (endY - startY) / 2,
        endX,
        endY,
      );
      canvas.drawPath(strandPath, strandPaint);
    }

    // 3. Natural Hairline Soft Skin Fade Edge
    final Paint fadeEdgePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, h * 0.02),
        Offset(0, h * 0.18),
        [
          baseColor.withOpacity(0.9),
          baseColor.withOpacity(0.0),
        ],
      );
    canvas.drawRect(Rect.fromLTWH(-w * 0.45, h * 0.02, w * 0.9, h * 0.16), fadeEdgePaint);
  }

  // Realistic Beard Texture & Follicle Rendering
  void _drawRealisticBeard(Canvas canvas, double w, double h, String styleId, Color baseColor) {
    final Color highlightColor = Color.alphaBlend(Colors.white.withOpacity(0.2), baseColor);
    final Color shadowColor = Color.alphaBlend(Colors.black.withOpacity(0.5), baseColor);

    final Paint beardVolumePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, -h * 0.2),
        Offset(0, h * 0.5),
        [baseColor.withOpacity(0.95), shadowColor],
      )
      ..isAntiAlias = true;

    final Path beardPath = Path();

    if (styleId.contains('goatee') || styleId.contains('van_dyke')) {
      // Goatee / Chin Beard Curve
      beardPath.addOval(Rect.fromCenter(center: Offset(0, h * 0.22), width: w * 0.42, height: h * 0.48));
    } else if (styleId.contains('moustache')) {
      // Mustache Wing Shape
      beardPath.moveTo(-w * 0.32, -h * 0.08);
      beardPath.quadraticBezierTo(0, -h * 0.25, w * 0.32, -h * 0.08);
      beardPath.quadraticBezierTo(0, -h * 0.02, -w * 0.32, -h * 0.08);
      beardPath.close();
    } else {
      // Full Beard / Stubble Jaw Outline
      beardPath.moveTo(-w * 0.46, -h * 0.2);
      beardPath.cubicTo(
        -w * 0.48, h * 0.55,
        w * 0.48, h * 0.55,
        w * 0.46, -h * 0.2,
      );
      beardPath.cubicTo(
        w * 0.25, h * 0.15,
        -w * 0.25, h * 0.15,
        -w * 0.46, -h * 0.2,
      );
      beardPath.close();
    }

    if (styleId.contains('stubble')) {
      // Light / Heavy Stubble Follicles Effect
      final Paint stubblePaint = Paint()
        ..color = baseColor.withOpacity(styleId.contains('heavy') ? 0.75 : 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = styleId.contains('heavy') ? 2.5 : 1.5;

      canvas.drawPath(beardPath, stubblePaint);
    } else {
      // Volumetric Beard Fill
      canvas.drawPath(beardPath, beardVolumePaint);

      // Realistic Beard Hair Texture Lines
      final Paint hairStrandPaint = Paint()
        ..color = highlightColor.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..isAntiAlias = true;

      final rand = math.Random(styleId.hashCode);
      for (int i = 0; i < 20; i++) {
        final double bx = (rand.nextDouble() - 0.5) * w * 0.6;
        final double by = (rand.nextDouble() * h * 0.4);
        canvas.drawLine(
          Offset(bx, by),
          Offset(bx + (rand.nextDouble() - 0.5) * 8, by + 10 + rand.nextDouble() * 10),
          hairStrandPaint,
        );
      }
    }
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
        oldDelegate.userRotation != userRotation ||
        oldDelegate.hairColor != hairColor;
  }
}

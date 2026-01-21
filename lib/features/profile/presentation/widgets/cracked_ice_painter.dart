import 'dart:math';
import 'package:flutter/material.dart';

/// Custom painter that creates a cracked ice effect overlay
class CrackedIcePainter extends CustomPainter {
  final Random _random = Random(42); // Fixed seed for consistent pattern
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final thickPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.08)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Create multiple crack origins
    final crackOrigins = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.15),
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.85, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.8),
    ];

    for (final origin in crackOrigins) {
      _drawCrackCluster(canvas, origin, size, paint, thickPaint, glowPaint);
    }

    // Add edge cracks for irregular borders
    _drawEdgeCracks(canvas, size, paint, thickPaint, glowPaint);
  }

  void _drawEdgeCracks(Canvas canvas, Size size, Paint paint, Paint thickPaint, Paint glowPaint) {
    // Top edge cracks
    for (int i = 0; i < 3; i++) {
      final x = size.width * (0.2 + i * 0.3);
      final origin = Offset(x, 0);
      final angle = pi / 2 + (_random.nextDouble() - 0.5) * 0.5;
      _drawCrack(canvas, origin, angle, 40 + _random.nextDouble() * 30, paint, thickPaint, glowPaint);
    }

    // Right edge cracks
    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.15 + i * 0.25);
      final origin = Offset(size.width, y);
      final angle = pi + (_random.nextDouble() - 0.5) * 0.5;
      _drawCrack(canvas, origin, angle, 35 + _random.nextDouble() * 25, paint, thickPaint, glowPaint);
    }

    // Bottom edge cracks
    for (int i = 0; i < 3; i++) {
      final x = size.width * (0.25 + i * 0.3);
      final origin = Offset(x, size.height);
      final angle = -pi / 2 + (_random.nextDouble() - 0.5) * 0.5;
      _drawCrack(canvas, origin, angle, 40 + _random.nextDouble() * 30, paint, thickPaint, glowPaint);
    }

    // Left edge cracks
    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.2 + i * 0.25);
      final origin = Offset(0, y);
      final angle = (_random.nextDouble() - 0.5) * 0.5;
      _drawCrack(canvas, origin, angle, 35 + _random.nextDouble() * 25, paint, thickPaint, glowPaint);
    }
  }

  void _drawCrackCluster(Canvas canvas, Offset origin, Size size, Paint paint, Paint thickPaint, Paint glowPaint) {
    final numCracks = 4 + _random.nextInt(3); // 4-6 cracks per cluster
    
    for (int i = 0; i < numCracks; i++) {
      final angle = (i / numCracks) * 2 * pi + _random.nextDouble() * 0.5;
      final length = 30 + _random.nextDouble() * 60;
      
      _drawCrack(canvas, origin, angle, length, paint, thickPaint, glowPaint);
    }
  }

  void _drawCrack(Canvas canvas, Offset start, double angle, double length, Paint paint, Paint thickPaint, Paint glowPaint) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    var currentPos = start;
    var currentAngle = angle;
    var remainingLength = length;
    
    while (remainingLength > 0) {
      final segmentLength = 8 + _random.nextDouble() * 12;
      final actualLength = min(segmentLength, remainingLength);
      
      // Add some randomness to angle
      currentAngle += (_random.nextDouble() - 0.5) * 0.4;
      
      final endX = currentPos.dx + cos(currentAngle) * actualLength;
      final endY = currentPos.dy + sin(currentAngle) * actualLength;
      
      path.lineTo(endX, endY);
      
      // Occasionally branch
      if (_random.nextDouble() > 0.7 && remainingLength > 20) {
        final branchAngle = currentAngle + (_random.nextBool() ? 0.6 : -0.6);
        final branchLength = remainingLength * 0.4;
        _drawCrack(canvas, Offset(endX, endY), branchAngle, branchLength, paint, thickPaint, glowPaint);
      }
      
      currentPos = Offset(endX, endY);
      remainingLength -= actualLength;
    }
    
    // Draw with glow first (background)
    canvas.drawPath(path, glowPaint);
    
    // Then main crack
    final usePaint = _random.nextDouble() > 0.7 ? thickPaint : paint;
    canvas.drawPath(path, usePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

/// Radial-burst background painter — 20 semi-transparent white rays radiating
/// from the upper-centre of the screen. Used on the battle landing screen and
/// Join Room screen.
class BattleRadialRaysPainter extends CustomPainter {
  const BattleRadialRaysPainter({this.centerYFraction = 0.38});

  final double centerYFraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * centerYFraction);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    const rayCount = 20;
    const halfAngle = 0.055; // radians — half-width of each ray
    final radius = size.longestSide * 1.2;

    for (var i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 3.14159265 * 2;
      final p = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + radius * Offset.fromDirection(angle - halfAngle).dx,
          center.dy + radius * Offset.fromDirection(angle - halfAngle).dy,
        )
        ..lineTo(
          center.dx + radius * Offset.fromDirection(angle + halfAngle).dx,
          center.dy + radius * Offset.fromDirection(angle + halfAngle).dy,
        )
        ..close();
      canvas.drawPath(p, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wave-fog clipper — creates a subtle wave path used to mask the bottom fog
/// overlay on the battle landing screen.
class BattleWaveFogClipper extends CustomClipper<Path> {
  const BattleWaveFogClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.5,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.6,
        size.width,
        size.height * 0.35,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

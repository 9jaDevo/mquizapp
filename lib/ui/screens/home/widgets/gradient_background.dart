import 'package:flutter/material.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/ui/styles/glass_theme.dart';

/// Gradient background with parallax effect for home screen
class GradientBackground extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;

  const GradientBackground({
    required this.child,
    super.key,
    this.scrollController,
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground> {
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (mounted) {
      setState(() {
        _scrollOffset = widget.scrollController?.offset ?? 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    // Only use parallax on high-performance devices
    final useParallax = GlassThemeConfig.performanceTier ==
        DevicePerformanceTier.high;

    // Parallax factor (0.3x of scroll)
    final parallaxOffset = useParallax ? _scrollOffset * 0.3 : 0.0;

    return Stack(
      children: [
        // Base gradient background
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: _buildBaseGradient(isDark, size),
            ),
          ),
        ),

        // Geometric shapes layer with parallax
        if (GlassThemeConfig.performanceTier != DevicePerformanceTier.low)
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(0, -parallaxOffset),
              child: CustomPaint(
                painter: _GeometricShapesPainter(
                  isDark: isDark,
                  size: size,
                ),
              ),
            ),
          ),

        // Content
        widget.child,
      ],
    );
  }

  /// Build base radial gradient mesh
  LinearGradient _buildBaseGradient(bool isDark, Size size) {
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1F1B3D), // Deep purple
          Color(0xFF0F1115), // Near black
          Color(0xFF151922), // Deep navy
        ],
        stops: [0.0, 0.5, 1.0],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE0E9FF), // Light blue
          Color(0xFFF4F7FD), // Off white
          Color(0xFFFFFFFF), // Pure white
        ],
        stops: [0.0, 0.4, 1.0],
      );
    }
  }
}

/// Custom painter for geometric blob overlays
class _GeometricShapesPainter extends CustomPainter {
  final bool isDark;
  final Size size;

  _GeometricShapesPainter({
    required this.isDark,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    // Color with low opacity for subtle effect
    final blobColor = isDark
        ? const Color(0xFF3B82F6).withValues(alpha: 0.08) // Blue
        : const Color(0xFF1F4ED8).withValues(alpha: 0.05); // Darker blue

    final accentColor = isDark
        ? const Color(0xFF8B5CF6).withValues(alpha: 0.06) // Purple
        : const Color(0xFF60A5FA).withValues(alpha: 0.04); // Light blue

    // Draw circular blobs at strategic positions
    // Top right blob
    paint.color = blobColor;
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      size.width * 0.4,
      paint,
    );

    // Middle left blob
    paint.color = accentColor;
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.45),
      size.width * 0.35,
      paint,
    );

    // Bottom center blob
    paint.color = blobColor;
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.85),
      size.width * 0.45,
      paint,
    );

    // Additional accent blob (top left, smaller)
    paint.color = accentColor;
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.1),
      size.width * 0.25,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GeometricShapesPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.size != size;
  }
}

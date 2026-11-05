import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Claymorphic container with 3D tactile depth, dual shadows (ambient highlight + drop shadow),
/// and soft pillowy rounded corners.
/// Implements Apple Design principles: instant down-state compression (scale 0.98),
/// tactile haptic feedback, and smooth spring settle.
class ClayContainer extends StatefulWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? surfaceColor;
  final VoidCallback? onTap;

  const ClayContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.surfaceColor,
    this.onTap,
  });

  @override
  State<ClayContainer> createState() => _ClayContainerState();
}

class _ClayContainerState extends State<ClayContainer> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      HapticFeedback.selectionClick();
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = widget.surfaceColor ?? (isDark ? const Color(0xFF1E212A) : Colors.white);

    // Dual shadows: Top-Left Glow + Bottom-Right Depth
    final List<BoxShadow> shadows = isDark
        ? [
            BoxShadow(
              color: Colors.black.withAlpha(_isPressed ? 120 : 160),
              offset: _isPressed ? const Offset(2, 2) : const Offset(6, 8),
              blurRadius: _isPressed ? 6 : 18,
              spreadRadius: -1,
            ),
            BoxShadow(
              color: const Color(0xFF2D3240).withAlpha(_isPressed ? 60 : 130),
              offset: _isPressed ? const Offset(-1, -1) : const Offset(-4, -4),
              blurRadius: _isPressed ? 4 : 14,
              spreadRadius: 0,
            ),
          ]
        : [
            BoxShadow(
              color: const Color(0xFFB0B7C6).withAlpha(_isPressed ? 60 : 115),
              offset: _isPressed ? const Offset(2, 2) : const Offset(6, 8),
              blurRadius: _isPressed ? 6 : 20,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.white.withAlpha(_isPressed ? 200 : 255),
              offset: _isPressed ? const Offset(-2, -2) : const Offset(-6, -6),
              blurRadius: _isPressed ? 6 : 18,
              spreadRadius: 2,
            ),
          ];

    Widget box = AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? const EdgeInsets.all(16.0),
        margin: widget.margin,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: shadows,
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: box,
      );
    }

    return box;
  }
}

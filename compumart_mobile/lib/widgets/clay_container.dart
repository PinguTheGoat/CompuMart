import 'package:flutter/material.dart';

/// Claymorphic container with 3D tactile depth, dual shadows (ambient highlight + drop shadow),
/// and soft pillowy rounded corners. Dynamically adapts between Light & Dark modes.
class ClayContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? surfaceColor;
  final bool isPressed;
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
    this.isPressed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default clay surface colors
    final bg = surfaceColor ?? (isDark ? const Color(0xFF1E212A) : Colors.white);

    // Clay dual shadows (Bottom-Right Depth + Top-Left Glow)
    final List<BoxShadow> shadows = isDark
        ? [
            // Dark mode depth shadow
            BoxShadow(
              color: Colors.black.withAlpha(isPressed ? 120 : 160),
              offset: isPressed ? const Offset(2, 2) : const Offset(6, 8),
              blurRadius: isPressed ? 8 : 18,
              spreadRadius: -1,
            ),
            // Dark mode subtle edge highlight
            BoxShadow(
              color: const Color(0xFF2D3240).withAlpha(isPressed ? 60 : 130),
              offset: isPressed ? const Offset(-2, -2) : const Offset(-4, -4),
              blurRadius: isPressed ? 6 : 14,
              spreadRadius: 0,
            ),
          ]
        : [
            // Light mode soft clay depth shadow
            BoxShadow(
              color: const Color(0xFFB0B7C6).withAlpha(isPressed ? 70 : 115),
              offset: isPressed ? const Offset(2, 3) : const Offset(6, 8),
              blurRadius: isPressed ? 8 : 20,
              spreadRadius: -2,
            ),
            // Light mode pure-white puff glow
            BoxShadow(
              color: Colors.white.withAlpha(isPressed ? 200 : 255),
              offset: isPressed ? const Offset(-2, -2) : const Offset(-6, -6),
              blurRadius: isPressed ? 8 : 18,
              spreadRadius: 2,
            ),
          ];

    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16.0),
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }
    return content;
  }
}

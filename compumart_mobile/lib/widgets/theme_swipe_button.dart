import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Minimalist Apple-inspired swipe toggle button for Light/Dark mode.
/// Supports both tapping and swiping with subtle tactile haptics.
class ThemeSwipeButton extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggle;

  const ThemeSwipeButton({
    super.key,
    required this.isDark,
    required this.onToggle,
  });

  void _triggerToggle(bool targetDark) {
    HapticFeedback.mediumImpact();
    onToggle(targetDark);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _triggerToggle(!isDark),
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0 && !isDark) {
            _triggerToggle(true); // swiped right -> dark
          } else if (details.primaryVelocity! < 0 && isDark) {
            _triggerToggle(false); // swiped left -> light
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), // 44px min tap area
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 54,
          height: 32,
          padding: const EdgeInsets.all(3.5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF282C38) : const Color(0xFFE2E6EE),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 60 : 25),
                offset: const Offset(1, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 80 : 35),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                size: 14,
                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFF59E0B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

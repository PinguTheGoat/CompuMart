import 'package:flutter/material.dart';
import '../models/order_record.dart';
import '../widgets/clay_container.dart';
import '../widgets/theme_swipe_button.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onToggleTheme;
  final List<OrderRecord> orders;

  const SettingsScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    this.orders = const [],
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1E212A) : Colors.white;

    // 1. SCAFFOLD WIDGET
    // Properties: appBar, body, backgroundColor
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111318) : const Color(0xFFF0F2F5),
      // 2. APPBAR WIDGET
      // Properties: title, backgroundColor, elevation, centerTitle
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.6,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
        // 3. COLUMN WIDGET
        // Properties: crossAxisAlignment, mainAxisAlignment, children
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // USER CLAY PROFILE CARD
            // 4. CONTAINER WIDGET
            ClayContainer(
              borderRadius: 24,
              surfaceColor: cardBg,
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    // 5. ICONS WIDGET
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 6. TEXT WIDGET
                        Text(
                          'Enthusiast Builder',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'builder@compumart.tech',
                          style: TextStyle(color: mutedColor, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E)).withAlpha(isDark ? 40 : 25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Warehouse Verified Account',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // APPEARANCE SWIPE TOGGLE SECTION
            Text(
              'Appearance',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            ClayContainer(
              borderRadius: 22,
              surfaceColor: cardBg,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              // 7. ROW WIDGET
              // Properties: mainAxisAlignment, crossAxisAlignment, children
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: textColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDark ? 'Dark Mode' : 'Light Mode',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textColor),
                          ),
                          Text(
                            'Swipe or tap to toggle theme',
                            style: TextStyle(color: mutedColor, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // SWIPE BUTTON
                  ThemeSwipeButton(
                    isDark: isDark,
                    onToggle: onToggleTheme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ACTIVE DISPATCH TRACKING
            Text(
              'Active Direct Dispatch',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            if (orders.isEmpty)
              ClayContainer(
                borderRadius: 22,
                surfaceColor: cardBg,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dispatch Order #CM-7419',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textColor),
                        ),
                        Text(
                          'In Transit',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Direct courier delivery from Central Warehouse facility with foam-cushioned packaging.',
                      style: TextStyle(color: mutedColor, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    // 8. PLACEHOLDER WIDGET
                    // Properties: fallbackHeight, fallbackWidth, color, strokeWidth
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: Placeholder(
                          fallbackHeight: 40,
                          fallbackWidth: double.infinity,
                          color: isDark ? const Color(0xFF282C38) : const Color(0xFFE2E8F0),
                          strokeWidth: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: orders.map((order) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ClayContainer(
                      borderRadius: 22,
                      surfaceColor: cardBg,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Order #${order.orderId}',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: textColor),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16A34A).withAlpha(isDark ? 50 : 25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order.status,
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Recipient: ${order.recipient} (${order.phone})',
                            style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Address: ${order.address}',
                            style: TextStyle(color: mutedColor, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Method: ${order.paymentMethod}',
                                style: TextStyle(color: mutedColor, fontSize: 11),
                              ),
                              Text(
                                '\$${order.total.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // 8. PLACEHOLDER WIDGET
                          // Properties: fallbackHeight, fallbackWidth, color, strokeWidth
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: Placeholder(
                                fallbackHeight: 36,
                                fallbackWidth: double.infinity,
                                color: isDark ? const Color(0xFF282C38) : const Color(0xFFE2E8F0),
                                strokeWidth: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            // PREFERENCES
            Text(
              'Preferences',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            ClayContainer(
              borderRadius: 22,
              surfaceColor: cardBg,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _buildSettingRow(
                    isDark: isDark,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    icon: Icons.notifications_active_outlined,
                    title: 'Restock Drop Alerts',
                    subtitle: 'Notify when warehouse pallets arrive',
                    trailingText: 'On',
                  ),
                  Divider(color: isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9), height: 1),
                  _buildSettingRow(
                    isDark: isDark,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    icon: Icons.verified_user_outlined,
                    title: 'Warranty Lookup',
                    subtitle: 'Direct serial number lookup',
                    trailingText: 'Verify',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ABOUT COMPUMART CARD
            ClayContainer(
              borderRadius: 22,
              surfaceColor: cardBg,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 9. IMAGE WIDGET
                      Image.asset(
                        'assets/images/Logo.png',
                        height: 20,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.memory, size: 18, color: textColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'About CompuMart',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0 • Built with Apple-inspired Claymorphism for direct warehouse hardware distribution.',
                    style: TextStyle(color: mutedColor, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  // 10. ELEVATEDBUTTON WIDGET
                  // Properties: onPressed, style, child
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 2),
                            backgroundColor: isDark ? const Color(0xFF282C38) : const Color(0xFF0F172A),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            content: Row(
                              children: [
                                Icon(
                                  Icons.cloud_done_rounded,
                                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF4ADE80),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'CompuMart Direct Warehouse Cloud v1.0 connected',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF282C38) : const Color(0xFFF8FAFC),
                        foregroundColor: textColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Check for Warehouse Updates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required bool isDark,
    required Color textColor,
    required Color mutedColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailingText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF282C38) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: textColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textColor),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: mutedColor, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trailingText,
              style: TextStyle(
                color: mutedColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

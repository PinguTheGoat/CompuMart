import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/clay_container.dart';
import '../widgets/theme_swipe_button.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(Product) onAddToCart;
  final VoidCallback onNavigateToWarehouse;
  final bool isDark;
  final ValueChanged<bool> onToggleTheme;

  const HomeScreen({
    super.key,
    required this.onAddToCart,
    required this.onNavigateToWarehouse,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1E212A) : Colors.white;
    final featuredProducts = ProductService.defaultProducts.take(3).toList();

    // 1. SCAFFOLD WIDGET
    // Properties: appBar, body, backgroundColor
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111318) : const Color(0xFFF0F2F5),
      // 2. APPBAR WIDGET
      // Properties: title, backgroundColor, elevation, centerTitle, actions
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3. IMAGE WIDGET
            Image.asset(
              'assets/images/Logo.png',
              height: 22,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.memory, color: textColor, size: 22),
            ),
            const SizedBox(width: 8),
            // 4. TEXT WIDGET
            Text(
              'CompuMart',
              style: TextStyle(
                fontFamily: 'SF-Pro',
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          // SWIPE BUTTON FOR LIGHT/DARK MODE
          Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: Center(
              child: ThemeSwipeButton(
                isDark: isDark,
                onToggle: onToggleTheme,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        // 5. COLUMN WIDGET
        // Properties: crossAxisAlignment, mainAxisAlignment, children
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // HERO MANIFESTO CLAY CONTAINER
            // 6. CONTAINER WIDGET
            ClayContainer(
              borderRadius: 28,
              surfaceColor: cardBg,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ORIGINAL HARDWARE • ZERO SCALPERS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: mutedColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Direct from the\nwarehouse floor.',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      height: 1.15,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Named from "Computer" and "Mart" (inspired by the simple everyday access of Walmart), CompuMart delivers sealed PC components straight to enthusiasts with transparent pricing.',
                    style: TextStyle(
                      fontSize: 13,
                      color: mutedColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // 7. ROW WIDGET
                  // Properties: mainAxisAlignment, crossAxisAlignment, children
                  Row(
                    children: [
                      // 8. ELEVATEDBUTTON WIDGET
                      // Properties: onPressed, style, child
                      ElevatedButton(
                        onPressed: onNavigateToWarehouse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
                          foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Browse Warehouse',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            SizedBox(width: 6),
                            // 9. ICONS WIDGET
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF282C38) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '100% Sealed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // LIVE SHIPMENT STATUS
            Text(
              'Warehouse Dispatch Updates',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),
            _buildUpdateTile(
              isDark: isDark,
              textColor: textColor,
              mutedColor: mutedColor,
              icon: Icons.flight_land_rounded,
              title: 'RTX 50-Series Airfreight Cleared',
              description: 'Fresh pallets of RTX 5090 & 5080 GPUs inventoried and verified.',
              time: 'Just now',
            ),
            _buildUpdateTile(
              isDark: isDark,
              textColor: textColor,
              mutedColor: mutedColor,
              icon: Icons.price_check_rounded,
              title: 'Direct Factory Allocation Applied',
              description: 'Ryzen 9 9950X3D processors restocked at direct MSRP allocations.',
              time: '2h ago',
            ),

            const SizedBox(height: 24),

            // FEATURED HARDWARE SPOTLIGHT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Allocations',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.4,
                  ),
                ),
                GestureDetector(
                  onTap: onNavigateToWarehouse,
                  child: Text(
                    'See All →',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F766E),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...featuredProducts.map((product) => _buildFeaturedCard(context, product, isDark, textColor, mutedColor)),

            const SizedBox(height: 24),

            // NEXT FREIGHT ARRIVAL SECTION (WITH PLACEHOLDER WIDGET)
            Text(
              'Next-Gen Freight Staging',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),
            ClayContainer(
              borderRadius: 22,
              surfaceColor: cardBg,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, color: mutedColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Incoming Freight Batch #CM-9082',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Custom chassis & Gen-5 PCIe power supplies arriving for packaging.',
                    style: TextStyle(color: mutedColor, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  // 10. PLACEHOLDER WIDGET
                  // Properties: fallbackHeight, fallbackWidth, color, strokeWidth
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: Placeholder(
                        fallbackHeight: 65,
                        fallbackWidth: double.infinity,
                        color: isDark ? const Color(0xFF2D3240) : const Color(0xFFCBD5E1),
                        strokeWidth: 1.5,
                      ),
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

  Widget _buildUpdateTile({
    required bool isDark,
    required Color textColor,
    required Color mutedColor,
    required IconData icon,
    required String title,
    required String description,
    required String time,
  }) {
    return ClayContainer(
      borderRadius: 20,
      surfaceColor: isDark ? const Color(0xFF1E212A) : Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: textColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(color: mutedColor, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(color: mutedColor, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(
    BuildContext context,
    Product product,
    bool isDark,
    Color textColor,
    Color mutedColor,
  ) {
    return ClayContainer(
      borderRadius: 22,
      surfaceColor: isDark ? const Color(0xFF1E212A) : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
              onAddToCart: () => onAddToCart(product),
            ),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF282C38) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              product.image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: mutedColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: mutedColor),
        ],
      ),
    );
  }
}

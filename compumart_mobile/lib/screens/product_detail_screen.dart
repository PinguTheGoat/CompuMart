import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/clay_container.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1E212A) : Colors.white;

    // 1. SCAFFOLD WIDGET
    // Properties: appBar, body, bottomNavigationBar, backgroundColor
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111318) : const Color(0xFFF0F2F5),
      // 2. APPBAR WIDGET
      // Properties: title, backgroundColor, elevation, centerTitle
      appBar: AppBar(
        title: Text(
          product.category,
          // 3. TEXT WIDGET
          // Properties: data, style
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.4,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
        // 4. COLUMN WIDGET
        // Properties: crossAxisAlignment, mainAxisAlignment, children
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CLAY PHOTO VESSEL
            // 5. CONTAINER WIDGET
            ClayContainer(
              borderRadius: 30,
              surfaceColor: cardBg,
              padding: const EdgeInsets.all(22),
              child: Center(
                // 6. IMAGE WIDGET
                // Properties: image, fit, width, height
                child: Image.asset(
                  product.image,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      // 7. PLACEHOLDER WIDGET
                      // Properties: fallbackHeight, fallbackWidth, color, strokeWidth
                      Placeholder(
                    fallbackHeight: 180,
                    fallbackWidth: 180,
                    color: mutedColor,
                    strokeWidth: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // SPECS / BADGE ROW
            // 8. ROW WIDGET
            // Properties: mainAxisAlignment, crossAxisAlignment, children
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withAlpha(isDark ? 50 : 25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: const [
                      // 9. ICONS WIDGET
                      Icon(Icons.verified_outlined, size: 15, color: Color(0xFF0F766E)),
                      SizedBox(width: 5),
                      Text(
                        'Direct Warehouse Deal',
                        style: TextStyle(
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        '${product.rating}',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: textColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // PRODUCT TITLE
            Text(
              product.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: -0.8,
                height: 1.2,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // PRICE & STOCK STATUS
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'In Stock • Ready to Dispatch',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // SPECIFICATIONS CARD
            ClayContainer(
              borderRadius: 22,
              surfaceColor: cardBg,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hardware Overview & Specifications',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: mutedColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Divider(color: isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: textColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Direct Factory Packaging: Includes anti-static packaging & manufacturer seal.',
                          style: TextStyle(color: mutedColor, fontSize: 11, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),
      // FLOATING ACTION BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withAlpha(120) : const Color(0xFF94A3B8).withAlpha(45),
              offset: const Offset(0, -6),
              blurRadius: 18,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                // 10. ELEVATEDBUTTON WIDGET
                // Properties: onPressed, style, child
                child: ElevatedButton(
                  onPressed: () {
                    onAddToCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added "${product.name}" to cart'),
                        backgroundColor: isDark ? const Color(0xFF1E212A) : const Color(0xFF0F172A),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
                    foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shopping_bag_outlined, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

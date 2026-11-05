import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../widgets/clay_container.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  void _increment() {
    if (_quantity < widget.product.stock) {
      HapticFeedback.selectionClick();
      setState(() => _quantity++);
    }
  }

  void _decrement() {
    if (_quantity > 1) {
      HapticFeedback.selectionClick();
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1E212A) : Colors.white;
    final product = widget.product;
    final totalPrice = product.price * _quantity;

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
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, size: 20, color: textColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing link for ${product.name}'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: isDark ? const Color(0xFF1E212A) : const Color(0xFF0F172A),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
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
                    color: (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E)).withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // 9. ICONS WIDGET
                      Icon(Icons.verified_outlined, size: 15, color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E)),
                      const SizedBox(width: 5),
                      Text(
                        'Direct Warehouse Deal',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
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
                Text(
                  '${product.stock} units in warehouse',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
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

            const SizedBox(height: 110),
          ],
        ),
      ),
      // FLOATING ACTION BAR WITH STEPPER & ADD TO CART
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
              // QUANTITY STEPPER
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: 18, color: textColor),
                      onPressed: _decrement,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$_quantity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, size: 18, color: textColor),
                      onPressed: _increment,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // 10. ELEVATEDBUTTON WIDGET
              // Properties: onPressed, style, child
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    for (int i = 0; i < _quantity; i++) {
                      widget.onAddToCart();
                    }
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
                              Icons.check_circle_rounded,
                              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF4ADE80),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Added $_quantity × "${product.name}" to cart',
                                style: const TextStyle(
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
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Add to Cart • \$${totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

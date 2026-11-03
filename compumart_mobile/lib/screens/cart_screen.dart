import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../widgets/clay_container.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final Function(CartItem) onIncrement;
  final Function(CartItem) onDecrement;
  final Function(CartItem) onRemove;
  final VoidCallback onClearCart;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onClearCart,
  });

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

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
      // Properties: title, backgroundColor, elevation, centerTitle, actions
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.6,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: onClearCart,
              child: const Text(
                'Clear',
                style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              // 3. COLUMN WIDGET
              // Properties: mainAxisAlignment, crossAxisAlignment, children
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 4. CONTAINER WIDGET
                  ClayContainer(
                    borderRadius: 30,
                    surfaceColor: cardBg,
                    padding: const EdgeInsets.all(26),
                    child: Icon(
                      // 5. ICONS WIDGET
                      Icons.shopping_bag_outlined,
                      size: 56,
                      color: mutedColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // 6. TEXT WIDGET
                  // Properties: data, style
                  Text(
                    'Your Cart is Empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Browse warehouse inventory and add components to order.',
                    style: TextStyle(color: mutedColor, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  // 7. PLACEHOLDER WIDGET
                  // Properties: fallbackHeight, fallbackWidth, color, strokeWidth
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 120,
                      height: 45,
                      child: Placeholder(
                        fallbackHeight: 45,
                        fallbackWidth: 120,
                        color: isDark ? const Color(0xFF282C38) : const Color(0xFFE2E8F0),
                        strokeWidth: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ClayContainer(
                  borderRadius: 22,
                  surfaceColor: cardBg,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  // 8. ROW WIDGET
                  // Properties: mainAxisAlignment, crossAxisAlignment, children
                  child: Row(
                    children: [
                      // 9. IMAGE WIDGET
                      // Properties: image, fit, width, height
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF282C38) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          item.product.image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '\$${item.product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stepper Controls
                      Row(
                        children: [
                          _buildStepperButton(
                            icon: Icons.remove,
                            isDark: isDark,
                            textColor: textColor,
                            onTap: () => onDecrement(item),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: textColor,
                              ),
                            ),
                          ),
                          _buildStepperButton(
                            icon: Icons.add,
                            isDark: isDark,
                            textColor: textColor,
                            onTap: () => onIncrement(item),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, size: 18, color: mutedColor),
                            onPressed: () => onRemove(item),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      // BOTTOM CHECKOUT BAR
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Payable',
                          style: TextStyle(color: mutedColor, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '\$${subtotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // 10. ELEVATEDBUTTON WIDGET
                    // Properties: onPressed, style, child
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              cartItems: cartItems,
                              totalAmount: subtotal,
                              onOrderCompleted: onClearCart,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
                        foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required bool isDark,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: textColor),
      ),
    );
  }
}

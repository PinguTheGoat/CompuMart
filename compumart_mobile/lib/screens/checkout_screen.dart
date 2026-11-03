import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../widgets/clay_container.dart';

class CheckoutScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final double totalAmount;
  final VoidCallback onOrderCompleted;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.onOrderCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          'Checkout',
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        // 3. COLUMN WIDGET
        // Properties: crossAxisAlignment, children
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ORDER ITEMS CLAY CARD
            // 4. CONTAINER WIDGET
            ClayContainer(
              borderRadius: 24,
              surfaceColor: cardBg,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 5. ROW WIDGET
                  // Properties: mainAxisAlignment, children
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Items',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      // 6. ICONS WIDGET
                      Icon(Icons.inventory_2_outlined, color: textColor, size: 18),
                    ],
                  ),
                  Divider(color: isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9), height: 20),
                  ...cartItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          // 7. IMAGE WIDGET
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF282C38) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Image.asset(
                              item.product.image,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  // 8. PLACEHOLDER WIDGET
                                  const Placeholder(fallbackHeight: 36, fallbackWidth: 36),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 9. TEXT WIDGET
                                Text(
                                  item.product.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Qty: ${item.quantity} × \$${item.product.price.toStringAsFixed(2)}',
                                  style: TextStyle(color: mutedColor, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${item.totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // DISPATCH METHOD
            ClayContainer(
              borderRadius: 22,
              surfaceColor: cardBg,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.local_shipping_outlined, color: Color(0xFF0F766E), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Direct Warehouse Courier',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Direct express transit (1-2 business days). Insured hardware packaging with tamper-proof seal.',
                    style: TextStyle(color: mutedColor, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // PRICE BREAKDOWN
            ClayContainer(
              borderRadius: 22,
              surfaceColor: cardBg,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPriceItem('Subtotal', '\$${totalAmount.toStringAsFixed(2)}', textColor, mutedColor),
                  const SizedBox(height: 6),
                  _buildPriceItem('Warehouse Packaging', 'FREE', textColor, mutedColor),
                  const SizedBox(height: 6),
                  _buildPriceItem('Insured Transit', 'FREE', textColor, mutedColor),
                  Divider(color: isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9), height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 10. ELEVATEDBUTTON WIDGET
            // Properties: onPressed, style, child
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: cardBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      title: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 26),
                          const SizedBox(width: 8),
                          Text(
                            'Order Dispatched',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        'Thank you for trusting CompuMart!\nTotal: \$${totalAmount.toStringAsFixed(2)}\n\nYour sealed components have been queued for warehouse staging.',
                        style: TextStyle(color: mutedColor, height: 1.5, fontSize: 13),
                      ),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
                            foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                            onOrderCompleted();
                          },
                          child: const Text('Back to Warehouse'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
                  foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Confirm & Authorize Dispatch',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(String label, String value, Color textColor, Color mutedColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: mutedColor, fontSize: 12)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, color: textColor, fontSize: 12)),
      ],
    );
  }
}

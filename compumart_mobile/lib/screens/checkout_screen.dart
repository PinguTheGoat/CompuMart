import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/cart_item.dart';
import '../models/order_record.dart';
import '../widgets/clay_container.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;
  final Function(OrderRecord) onOrderPlaced;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.onOrderPlaced,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Enthusiast Builder');
  final TextEditingController _phoneController = TextEditingController(text: '+63 917 888 2490');
  final TextEditingController _addressController = TextEditingController(text: 'Unit 402, Warehouse Logistics Park, Metro Tech Hub');

  String _selectedPaymentMethod = 'Cash on Delivery';
  String? _errorMessage;

  final List<Map<String, dynamic>> _paymentOptions = [
    {
      'title': 'Cash on Delivery',
      'subtitle': 'Pay courier upon hardware inspection',
      'icon': Icons.payments_outlined,
    },
    {
      'title': 'GCash / E-Wallet',
      'subtitle': 'Direct warehouse merchant verification',
      'icon': Icons.account_balance_wallet_outlined,
    },
    {
      'title': 'Credit / Debit Card',
      'subtitle': 'Insured encrypted checkout',
      'icon': Icons.credit_card_outlined,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleConfirmOrder() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    // FORM VALIDATION
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please provide recipient name.');
      HapticFeedback.vibrate();
      return;
    }
    if (phone.isEmpty || phone.length < 7) {
      setState(() => _errorMessage = 'Please provide a valid contact number.');
      HapticFeedback.vibrate();
      return;
    }
    if (address.isEmpty || address.length < 5) {
      setState(() => _errorMessage = 'Please provide a complete shipping address.');
      HapticFeedback.vibrate();
      return;
    }

    setState(() => _errorMessage = null);
    HapticFeedback.mediumImpact();

    final orderId = 'CM-${1000 + Random().nextInt(9000)}';
    final newOrder = OrderRecord(
      orderId: orderId,
      items: List.from(widget.cartItems),
      total: widget.totalAmount,
      recipient: name,
      phone: phone,
      address: address,
      paymentMethod: _selectedPaymentMethod,
      status: 'Staged for Dispatch',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1E212A) : Colors.white;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 26),
            const SizedBox(width: 8),
            Text(
              'Order #$orderId',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thank you, $name!\nTotal: \$${widget.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Payment: $_selectedPaymentMethod\nShipping to: $address\n\nYour sealed components have been queued for warehouse staging.',
              style: TextStyle(color: mutedColor, height: 1.4, fontSize: 12),
            ),
          ],
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
              widget.onOrderPlaced(newOrder);
            },
            child: const Text('Back to Warehouse'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1E212A) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111318) : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(
          'Checkout & Delivery',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ORDER ITEMS SUMMARY CARD
            ClayContainer(
              borderRadius: 24,
              surfaceColor: cardBg,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order Items (${widget.cartItems.length})',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Icon(Icons.inventory_2_outlined, color: textColor, size: 18),
                    ],
                  ),
                  Divider(color: isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9), height: 20),
                  ...widget.cartItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF282C38) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Image.asset(
                              item.product.image,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Placeholder(fallbackHeight: 36, fallbackWidth: 36),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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

            const SizedBox(height: 18),

            // DELIVERY ADDRESS DETAILS
            Text(
              'Delivery Destination',
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
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    style: TextStyle(fontSize: 13, color: textColor),
                    decoration: InputDecoration(
                      labelText: 'Recipient Full Name *',
                      labelStyle: TextStyle(color: mutedColor, fontSize: 12),
                      prefixIcon: Icon(Icons.person_outline, size: 18, color: mutedColor),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Divider(color: isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9), height: 16),
                  TextField(
                    controller: _phoneController,
                    style: TextStyle(fontSize: 13, color: textColor),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Contact Phone Number *',
                      labelStyle: TextStyle(color: mutedColor, fontSize: 12),
                      prefixIcon: Icon(Icons.phone_outlined, size: 18, color: mutedColor),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Divider(color: isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9), height: 16),
                  TextField(
                    controller: _addressController,
                    style: TextStyle(fontSize: 13, color: textColor),
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Shipping Address *',
                      labelStyle: TextStyle(color: mutedColor, fontSize: 12),
                      prefixIcon: Icon(Icons.location_on_outlined, size: 18, color: mutedColor),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            // ERROR VALIDATION BANNER
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),

            // PAYMENT METHOD CHOICES
            Text(
              'Payment Selection',
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
              padding: const EdgeInsets.all(12),
              child: Column(
                children: _paymentOptions.map((opt) {
                  final isSelected = _selectedPaymentMethod == opt['title'];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedPaymentMethod = opt['title'] as String;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF282C38) : const Color(0xFFF1F5F9))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected
                            ? Border.all(color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A), width: 1.2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            opt['icon'] as IconData,
                            size: 20,
                            color: isSelected
                                ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A))
                                : mutedColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opt['title'] as String,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 13,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  opt['subtitle'] as String,
                                  style: TextStyle(color: mutedColor, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 18),

            // PRICE BREAKDOWN
            ClayContainer(
              borderRadius: 22,
              surfaceColor: cardBg,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPriceItem('Subtotal', '\$${widget.totalAmount.toStringAsFixed(2)}', textColor, mutedColor),
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
                        '\$${widget.totalAmount.toStringAsFixed(2)}',
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

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handleConfirmOrder,
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
            const SizedBox(height: 30),
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

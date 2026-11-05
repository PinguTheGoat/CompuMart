import 'cart_item.dart';

class OrderRecord {
  final String orderId;
  final List<CartItem> items;
  final double total;
  final String recipient;
  final String phone;
  final String address;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  OrderRecord({
    required this.orderId,
    required this.items,
    required this.total,
    required this.recipient,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

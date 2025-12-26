import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double discount,
    required double total,
    required String paymentMethod,
    required String deliveryMethod,
    String? voucherCodeUsed,
    double? voucherDiscountAmount,
    required int earnedPoints,
  }) async {
    await _firestore.collection('orders').add({
      'userId': userId,
      'items': items,
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'deliveryMethod': deliveryMethod,
      'voucherCodeUsed': voucherCodeUsed,
      'voucherDiscountAmount': voucherDiscountAmount,
      'earnedPoints': earnedPoints,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending', // e.g., pending, completed, cancelled
    });
  }
}

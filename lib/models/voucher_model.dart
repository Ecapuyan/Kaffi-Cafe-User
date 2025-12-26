import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher {
  final String id;
  final String code;
  final String name;
  final double discountValue; // Can be a fixed amount or percentage base value
  final String discountType; // 'percentage' or 'fixed'
  final DateTime? expiryDate;
  final bool isActive;
  final double? minimumOrderAmount;
  final int costInPoints; // New field: Cost to claim this voucher

  Voucher({
    required this.id,
    required this.code,
    required this.name,
    required this.discountValue,
    required this.discountType,
    this.expiryDate,
    this.isActive = true,
    this.minimumOrderAmount,
    this.costInPoints = 0,
  });

  // Factory constructor to create a Voucher from a Firestore Document
  factory Voucher.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Voucher(
      id: doc.id,
      code: data['code'] ?? '',
      name: data['name'] ?? 'Unnamed Voucher',
      discountValue: (data['discountValue'] as num?)?.toDouble() ?? 0.0,
      discountType: data['discountType'] ?? 'fixed',
      expiryDate: (data['expiryDate'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
      minimumOrderAmount: (data['minimumOrderAmount'] as num?)?.toDouble(),
      costInPoints: (data['costInPoints'] as num?)?.toInt() ?? 0,
    );
  }

  // Convert a Voucher object to a Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'name': name,
      'discountValue': discountValue,
      'discountType': discountType,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'isActive': isActive,
      'minimumOrderAmount': minimumOrderAmount,
      'costInPoints': costInPoints,
    };
  }
}

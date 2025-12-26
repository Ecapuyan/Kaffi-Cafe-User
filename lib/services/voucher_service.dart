import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaffi_cafe/models/voucher_model.dart';

class VoucherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Voucher>> getActiveVouchers() {
    return _firestore
        .collection('voucher')
        .where('isActive', isEqualTo: true) // Re-added filter
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Voucher.fromFirestore(doc)).toList();
    });
  }

  // Fetch vouchers claimed by a specific user (from voucher_redemptions)
  Stream<List<Voucher>> getUserClaimedVouchers(String userEmail) {
    return _firestore
        .collection('voucher_redemptions')
        .where('userId', isEqualTo: userEmail)
        .where('isUsed', isEqualTo: false)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Map voucher_redemptions fields to Voucher model
        return Voucher(
          id: doc.id, // The Firestore Document ID (unique for this redemption)
          code: data['voucherId'] ?? '', // The code (e.g. VOUCHER7220)
          name: data['voucherName'] ?? 'Unnamed Voucher',
          discountValue: (data['voucherValue'] as num?)?.toDouble() ?? 0.0,
          discountType: 'fixed', // Assuming these are fixed value vouchers
          expiryDate: (data['expirationDate'] as Timestamp?)?.toDate(),
          isActive: true,
          costInPoints: (data['pointsSpent'] as num?)?.toInt() ?? 0,
        );
      }).where((v) => v.expiryDate == null || v.expiryDate!.isAfter(now)).toList();
    });
  }

  // Claim a voucher (Add to voucher_redemptions)
  // Note: reward_tab.dart might already be doing this manually. 
  // We'll update this method just in case, or we can use it to standardize.
  Future<void> claimVoucher(String userEmail, Voucher voucher) async {
    // Find user to deduct points (assuming user doc ID is email)
    final userRef = _firestore.collection('users').doc(userEmail);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw Exception('User does not exist!');
      }

      final currentPoints = (userDoc.data()?['points'] ?? 0) as int;
      if (currentPoints < voucher.costInPoints) {
        throw Exception('Insufficient points!');
      }

      // Deduct points
      transaction.update(userRef, {'points': currentPoints - voucher.costInPoints});

      // Add to voucher_redemptions
      final newRedemptionRef = _firestore.collection('voucher_redemptions').doc();
      
      transaction.set(newRedemptionRef, {
        'userId': userEmail,
        'voucherName': voucher.name,
        'voucherId': voucher.code, // Storing code in voucherId field per your schema
        'voucherValue': voucher.discountValue,
        'pointsSpent': voucher.costInPoints,
        'status': 'active',
        'isUsed': false,
        'timestamp': FieldValue.serverTimestamp(),
        'expirationDate': voucher.expiryDate != null ? Timestamp.fromDate(voucher.expiryDate!) : null,
      });
    });
  }

  // Mark a claimed voucher as used (in voucher_redemptions)
  Future<void> markVoucherAsUsed(String userEmail, String redemptionDocId) async {
    print("Attempting to mark redemption $redemptionDocId as used for $userEmail");
    await _firestore
        .collection('voucher_redemptions')
        .doc(redemptionDocId)
        .update({
          'isUsed': true, 
          'status': 'used', 
          'usedAt': FieldValue.serverTimestamp(),
          'usedInOrder': 'Order Placed' // Context
        });
  }

  Future<Voucher?> getVoucherByCode(String code) async {
    final querySnapshot = await _firestore
        .collection('vouchers')
        .where('code', isEqualTo: code)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return Voucher.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  // Future<void> addVoucher(Voucher voucher) async {
  //   await _firestore.collection('voucher').add(voucher.toFirestore());
  // }

  // Future<void> updateVoucher(Voucher voucher) async {
  //   await _firestore.collection('voucher').doc(voucher.id).update(voucher.toFirestore());
  // }

  // Future<void> deleteVoucher(String voucherId) async {
  //   await _firestore.collection('voucher').doc(voucherId).delete();
  // }
}

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/touchable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaffi_cafe/screens/voucher_confirmation_screen.dart';
import 'dart:math';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Vouchers will be generated based on points conversion: 100 points = 10 PHP
  final box = GetStorage();

  // Define voucher options
  final List<Map<String, dynamic>> voucherOptions = [
    {'points': 100, 'value': 10, 'description': '₱10 Voucher'},
    {'points': 200, 'value': 20, 'description': '₱20 Voucher'},
    {'points': 500, 'value': 50, 'description': '₱50 Voucher'},
    {'points': 1000, 'value': 100, 'description': '₱100 Voucher'},
  ];
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('users')
          .doc(box.read('userData')?['email'] ?? box.read('user')?['email'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final userPoints = userData?['points'] ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              TextWidget(
                text: 'Rewards',
                fontSize: 28,
                color: textBlack,
                fontFamily: 'Bold',
              ),

              const SizedBox(height: 20),

              // Points Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bayanihanBlue, bayanihanBlue.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: bayanihanBlue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.stars, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        TextWidget(
                          text: 'Your Points Balance',
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Regular',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextWidget(
                      text: '$userPoints',
                      fontSize: 36,
                      color: Colors.white,
                      fontFamily: 'Bold',
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      text: 'Points Available',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontFamily: 'Regular',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Voucher Options Section
              TextWidget(
                text: 'Voucher Options',
                fontSize: 22,
                color: textBlack,
                fontFamily: 'Bold',
              ),

              const SizedBox(height: 4),

              TextWidget(
                text: 'Redeem your points for vouchers (100 points = ₱10)',
                fontSize: 14,
                color: charcoalGray,
                fontFamily: 'Regular',
              ),

              const SizedBox(height: 16),

              // Voucher Options
              Column(
                children: voucherOptions.map((voucher) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildVoucherCard(
                      description: voucher['description'],
                      pointsCost: voucher['points'],
                      value: voucher['value'],
                      userPoints: userPoints,
                      user: box.read('userData')?['email'] ??
                          box.read('user')?['email'],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Redemption History
              TextWidget(
                text: 'Voucher Redemption History',
                fontSize: 22,
                color: textBlack,
                fontFamily: 'Bold',
              ),

              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('voucher_redemptions')
                    .where('userId',
                        isEqualTo: box.read('userData')?['email'] ??
                            box.read('user')?['email'])
                    .orderBy('timestamp', descending: true)
                    .limit(10)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final redemptions = snapshot.data?.docs ?? [];
                  if (redemptions.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ashGray.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: TextWidget(
                          text: 'No voucher redemptions yet.',
                          fontSize: 14,
                          color: charcoalGray,
                          fontFamily: 'Regular',
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: redemptions.length,
                    itemBuilder: (context, index) {
                      final data =
                          redemptions[index].data() as Map<String, dynamic>;
                      final voucherName = data['voucherName'] ?? 'Voucher';
                      final voucherId =
                          data['voucherId'] ?? data['voucherCode'] ?? '';
                      final pointsSpent = data['pointsSpent'] ?? 0;
                      final timestamp = data['timestamp'] as Timestamp?;
                      final isUsed = data['isUsed'] ?? false;
                      final status = data['status'] ?? 'active';
                      final usedAt = data['usedAt'] as Timestamp?;
                      final usedInOrder = data['usedInOrder'] ?? '';
                      final expirationDate =
                          data['expirationDate'] as Timestamp?;

                      final dateStr = timestamp != null
                          ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
                          : 'Unknown date';
                      final usedDateStr = usedAt != null
                          ? '${usedAt.toDate().day}/${usedAt.toDate().month}/${usedAt.toDate().year}'
                          : '';
                      final expirationDateStr = expirationDate != null
                          ? '${expirationDate.toDate().day}/${expirationDate.toDate().month}/${expirationDate.toDate().year}'
                          : '';

                      // Check if voucher is expired
                      final isExpired = expirationDate != null &&
                          DateTime.now().isAfter(expirationDate.toDate());
                      final canUse =
                          !isUsed && !isExpired && status == 'active';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUsed || status == 'used' || isExpired
                                ? festiveRed.withOpacity(0.3)
                                : bayanihanBlue.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isUsed || status == 'used' || isExpired
                                    ? festiveRed.withOpacity(0.1)
                                    : bayanihanBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isUsed || status == 'used' || isExpired
                                    ? isExpired
                                        ? Icons.access_time
                                        : Icons.check_circle
                                    : Icons.card_giftcard,
                                color: isUsed || status == 'used' || isExpired
                                    ? festiveRed
                                    : bayanihanBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      TextWidget(
                                        text: voucherName,
                                        fontSize: 14,
                                        color: textBlack,
                                        fontFamily: 'Bold',
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isUsed ||
                                                  status == 'used' ||
                                                  isExpired
                                              ? festiveRed.withOpacity(0.1)
                                              : palmGreen.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: TextWidget(
                                          text: isUsed || status == 'used'
                                              ? 'USED'
                                              : isExpired
                                                  ? 'EXPIRED'
                                                  : 'ACTIVE',
                                          fontSize: 10,
                                          color: isUsed ||
                                                  status == 'used' ||
                                                  isExpired
                                              ? festiveRed
                                              : palmGreen,
                                          fontFamily: 'Bold',
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextWidget(
                                    text: 'Voucher Ticket',
                                    fontSize: 12,
                                    color: bayanihanBlue,
                                    fontFamily: 'Bold',
                                  ),
                                  TextWidget(
                                    text:
                                        '$pointsSpent points redeemed on $dateStr',
                                    fontSize: 12,
                                    color: charcoalGray,
                                    fontFamily: 'Regular',
                                  ),
                                  if (expirationDateStr.isNotEmpty)
                                    TextWidget(
                                      text: 'Expires on: $expirationDateStr',
                                      fontSize: 11,
                                      color:
                                          isExpired ? festiveRed : charcoalGray,
                                      fontFamily: 'Regular',
                                    ),
                                  if (isUsed || status == 'used') ...[
                                    TextWidget(
                                      text: 'Used in order: $usedInOrder',
                                      fontSize: 11,
                                      color: festiveRed,
                                      fontFamily: 'Bold',
                                    ),
                                    if (usedDateStr.isNotEmpty)
                                      TextWidget(
                                        text: 'Used on: $usedDateStr',
                                        fontSize: 11,
                                        color: charcoalGray,
                                        fontFamily: 'Regular',
                                      ),
                                  ],
                                ],
                              ),
                            ),
                            if (canUse)
                              TouchableWidget(
                                onTap: () => _showUseVoucherConfirmation(
                                  redemptions[index].id,
                                  voucherName,
                                  voucherId,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: bayanihanBlue,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: TextWidget(
                                    text: 'Use',
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontFamily: 'Bold',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoucherCard({
    required String description,
    required int pointsCost,
    required int value,
    required int userPoints,
    required String user,
  }) {
    final canRedeem = userPoints >= pointsCost;

    return TouchableWidget(
      onTap: canRedeem
          ? () => _redeemVoucher(pointsCost, description, value, user)
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canRedeem
                ? bayanihanBlue.withOpacity(0.3)
                : ashGray.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: canRedeem
                  ? bayanihanBlue.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Voucher Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: canRedeem
                    ? bayanihanBlue.withOpacity(0.1)
                    : ashGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.card_giftcard,
                color: canRedeem ? bayanihanBlue : ashGray,
                size: 40,
              ),
            ),

            const SizedBox(width: 16),

            // Voucher Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: description,
                    fontSize: 18,
                    color: canRedeem ? textBlack : ashGray,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(height: 4),
                  TextWidget(
                    text: 'Voucher can be used on any purchase',
                    fontSize: 14,
                    color: canRedeem ? charcoalGray : ashGray,
                    fontFamily: 'Regular',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextWidget(
                        text: '₱$value',
                        fontSize: 16,
                        color: canRedeem ? bayanihanBlue : ashGray,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.star,
                        color: canRedeem ? Colors.amber : ashGray,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: '$pointsCost points',
                        fontSize: 14,
                        color: canRedeem ? Colors.amber : ashGray,
                        fontFamily: 'Bold',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Redeem Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: canRedeem ? bayanihanBlue : ashGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextWidget(
                text: canRedeem ? 'Redeem' : 'Locked',
                fontSize: 12,
                color: Colors.white,
                fontFamily: 'Bold',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _redeemVoucher(
      int pointsCost, String voucherName, int value, String user) async {
    try {
      // Generate a unique voucher ID (not displayed to user)
      final random = Random();
      final voucherId =
          'VOUCHER${random.nextInt(10000).toString().padLeft(4, '0')}';

      // Set expiration date (30 days from now)
      final expirationDate = DateTime.now().add(const Duration(days: 30));

      // Deduct points from user account
      final userDoc = _firestore.collection('users').doc(user);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final currentPoints = (snapshot.data()?['points'] ?? 0) as int;

        if (currentPoints >= pointsCost) {
          final newPoints = currentPoints - pointsCost;
          transaction.update(userDoc, {
            'points': newPoints,
          });

          // Also update local storage to keep points in sync
          final localUserData = box.read('userData') ?? {};
          localUserData['points'] = newPoints;
          box.write('userData', localUserData);
        } else {
          throw Exception('Insufficient points');
        }
      });

      // Add voucher redemption record
      await _firestore.collection('voucher_redemptions').add({
        'userId': user,
        'voucherName': voucherName,
        'voucherId': voucherId, // Internal ID, not shown to user
        'voucherValue': value,
        'pointsSpent': pointsCost,
        'timestamp': FieldValue.serverTimestamp(),
        'expirationDate': expirationDate,
        'status': 'active',
        'isUsed': false,
      });

      // Get user name for the confirmation screen
      final userSnapshot = await userDoc.get();
      final userData = userSnapshot.data() as Map<String, dynamic>?;
      final userName = userData?['name'] ?? 'User';

      // Navigate to voucher confirmation screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VoucherConfirmationScreen(
            voucherName: voucherName,
            voucherCode:
                voucherId, // Using voucherCode parameter but passing voucherId
            voucherValue: value,
            pointsSpent: pointsCost,
            userName: userName,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to redeem voucher: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showUseVoucherConfirmation(
    String voucherDocId,
    String voucherName,
    String voucherId,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextWidget(
            text: 'Use Voucher',
            fontSize: 20,
            color: textBlack,
            fontFamily: 'Bold',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextWidget(
                  text: 'Are you sure you want to use this voucher?',
                  fontSize: 16,
                  color: charcoalGray,
                  fontFamily: 'Regular',
                ),
                const SizedBox(height: 8),
                TextWidget(
                  text: voucherName,
                  fontSize: 14,
                  color: bayanihanBlue,
                  fontFamily: 'Bold',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: TextWidget(
                text: 'Cancel',
                fontSize: 14,
                color: ashGray,
                fontFamily: 'Regular',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bayanihanBlue,
              ),
              child: TextWidget(
                text: 'Use Voucher',
                fontSize: 14,
                color: Colors.white,
                fontFamily: 'Bold',
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _useVoucher(voucherDocId, voucherName);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _useVoucher(String voucherDocId, String voucherName) async {
    try {
      // Update voucher status to used
      await _firestore
          .collection('voucher_redemptions')
          .doc(voucherDocId)
          .update({
        'isUsed': true,
        'status': 'used',
        'usedAt': FieldValue.serverTimestamp(),
        'usedInOrder':
            'Store Purchase', // Can be modified to track actual order
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$voucherName has been used successfully!'),
          backgroundColor: palmGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to use voucher: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

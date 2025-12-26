import 'package:kaffi_cafe/services/voucher_service.dart';
import 'package:kaffi_cafe/models/voucher_model.dart';
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
  final VoucherService _voucherService = VoucherService();

  // Vouchers will be generated based on points conversion: 100 points = 10 PHP
  final box = GetStorage();

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
              StreamBuilder<List<Voucher>>(
                stream: _voucherService.getActiveVouchers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    print("Error fetching vouchers: ${snapshot.error}"); // Debug print
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final vouchers = snapshot.data ?? [];
                  print("Fetched ${vouchers.length} vouchers from Firestore"); // Debug print
                  
                  if (vouchers.isEmpty) {
                     return Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Text('No vouchers available at the moment.'),
                     );
                  }
                  
                  // Get the current user identifier (Email) securely
                  final currentUserEmail = box.read('userData')?['email'] ?? 
                                         box.read('user')?['email'] ?? 
                                         _auth.currentUser?.email;

                  if (currentUserEmail == null || currentUserEmail.isEmpty) {
                     return Center(child: Text("Please log in to see vouchers."));
                  }

                  return Column(
                    children: vouchers.map((voucher) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildVoucherCard(
                          voucher: voucher,
                          userPoints: userPoints,
                          user: currentUserEmail, // Pass the confirmed email
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Redemption History
              TextWidget(
                text: 'My Claimed Vouchers',
                fontSize: 22,
                color: textBlack,
                fontFamily: 'Bold',
              ),

              const SizedBox(height: 16),

              StreamBuilder<List<Voucher>>(
                // Use getUserClaimedVouchers to fetch active vouchers
                stream: _voucherService.getUserClaimedVouchers(
                    box.read('userData')?['email'] ?? box.read('user')?['email'] ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final claimedVouchers = snapshot.data ?? [];
                  if (claimedVouchers.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ashGray.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: TextWidget(
                          text: 'No active claimed vouchers.',
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
                    itemCount: claimedVouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = claimedVouchers[index];
                      // getUserClaimedVouchers already filters for isUsed=false and non-expired

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: bayanihanBlue.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: bayanihanBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.card_giftcard,
                                color: bayanihanBlue,
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
                                        text: voucher.name,
                                        fontSize: 14,
                                        color: textBlack,
                                        fontFamily: 'Bold',
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: palmGreen.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: TextWidget(
                                          text: 'ACTIVE',
                                          fontSize: 10,
                                          color: palmGreen,
                                          fontFamily: 'Bold',
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextWidget(
                                    text: 'Code: ${voucher.code}',
                                    fontSize: 12,
                                    color: bayanihanBlue,
                                    fontFamily: 'Bold',
                                  ),
                                  TextWidget(
                                    text:
                                        'Value: ₱${voucher.discountValue}',
                                    fontSize: 12,
                                    color: charcoalGray,
                                    fontFamily: 'Regular',
                                  ),
                                  if (voucher.expiryDate != null)
                                    TextWidget(
                                      text: 'Expires on: ${voucher.expiryDate!.day}/${voucher.expiryDate!.month}/${voucher.expiryDate!.year}',
                                      fontSize: 11,
                                      color: charcoalGray,
                                      fontFamily: 'Regular',
                                    ),
                                ],
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
    required Voucher voucher,
    required int userPoints,
    required String user,
  }) {
    final canRedeem = userPoints >= voucher.costInPoints;

    return TouchableWidget(
      onTap: canRedeem
          ? () => _redeemVoucher(voucher, user)
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
                    text: voucher.name,
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
                        text: '₱${voucher.discountValue}',
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
                        text: '${voucher.costInPoints} points',
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
      Voucher voucher, String user) async {
    try {
      // Use the service to claim the voucher (deducts points and adds to subcollection)
      // Note: We need the userId (likely email or uid). The 'user' param passed here seems to be email in current usage.
      // Ideally we should use UID. For now, assuming 'user' is the document ID for the user collection.
      // If 'user' is email, we need to make sure VoucherService uses the correct doc ID.
      // Based on StreamBuilder above: .doc(box.read('userData')?['email'] ?? box.read('user')?['email'])
      // It seems the user DOC ID is the EMAIL. So 'user' param is correct.

      await _voucherService.claimVoucher(user, voucher);

      // Get user name for the confirmation screen
      final userDoc = _firestore.collection('users').doc(user);
      final userSnapshot = await userDoc.get();
      final userData = userSnapshot.data() as Map<String, dynamic>?;
      final userName = userData?['name'] ?? 'User';

      // Navigate to voucher confirmation screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VoucherConfirmationScreen(
            voucherName: voucher.name,
            voucherCode: voucher.code,
            voucherValue: voucher.discountValue.toInt(),
            pointsSpent: voucher.costInPoints,
            userName: userName,
            expirationDate: voucher.expiryDate,
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

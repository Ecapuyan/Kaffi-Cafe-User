import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/touchable_widget.dart';

class VoucherConfirmationScreen extends StatelessWidget {
  final String voucherName;
  final String voucherCode;
  final int voucherValue;
  final int pointsSpent;
  final String userName;
  final DateTime? expirationDate;

  const VoucherConfirmationScreen({
    super.key,
    required this.voucherName,
    required this.voucherCode,
    required this.voucherValue,
    required this.pointsSpent,
    required this.userName,
    this.expirationDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: palmGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: palmGreen,
                size: 60,
              ),
            ),

            const SizedBox(height: 24),

            // Success Message
            TextWidget(
              text: 'Voucher Redeemed Successfully!',
              fontSize: 24,
              color: textBlack,
              fontFamily: 'Bold',
              align: TextAlign.center,
            ),

            const SizedBox(height: 16),

            TextWidget(
              text:
                  'This voucher ticket will be automatically available in your voucher history',
              fontSize: 16,
              color: charcoalGray,
              fontFamily: 'Regular',
              align: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Voucher Card
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
                children: [
                  // Voucher Name
                  TextWidget(
                    text: voucherName,
                    fontSize: 22,
                    color: Colors.white,
                    fontFamily: 'Bold',
                    align: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Voucher Value
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextWidget(
                      text: '₱$voucherValue',
                      fontSize: 28,
                      color: Colors.white,
                      fontFamily: 'Bold',
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Voucher Ticket (no code displayed)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        TextWidget(
                          text: 'VOUCHER TICKET',
                          fontSize: 16,
                          color: Colors.white,
                          fontFamily: 'Bold',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // User Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: 'Redeemed by',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontFamily: 'Regular',
                          ),
                          TextWidget(
                            text: userName,
                            fontSize: 14,
                            color: Colors.white,
                            fontFamily: 'Bold',
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextWidget(
                            text: 'Points Used',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontFamily: 'Regular',
                          ),
                          TextWidget(
                            text: '$pointsSpent points',
                            fontSize: 14,
                            color: Colors.white,
                            fontFamily: 'Bold',
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Expiration Date
                  if (expirationDate != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          TextWidget(
                            text:
                                'Valid until: ${expirationDate!.day}/${expirationDate!.month}/${expirationDate!.year}',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            fontFamily: 'Regular',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ashGray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'How to use:',
                    fontSize: 16,
                    color: textBlack,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(height: 8),
                  TextWidget(
                    text:
                        'This voucher will appear in your voucher history and can be used directly without entering any code',
                    fontSize: 14,
                    color: charcoalGray,
                    fontFamily: 'Regular',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            ButtonWidget(
              label: 'Done',
              onPressed: () => Navigator.of(context).pop(),
              color: bayanihanBlue,
            ),

            const SizedBox(height: 12),

            TouchableWidget(
              onTap: () {
                // In a real app, you would implement sharing functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Share functionality coming soon!'),
                    backgroundColor: bayanihanBlue,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: bayanihanBlue,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: TextWidget(
                    text: 'Share Voucher',
                    fontSize: 16,
                    color: bayanihanBlue,
                    fontFamily: 'Bold',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

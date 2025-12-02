import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/recommendation_widget.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderReference;
  final String customerName;
  final String branch;
  final String orderMethod;
  final String pickupTime;
  final List<Map<String, dynamic>> orderItems;
  final double totalAmount;

  const OrderConfirmationScreen({
    Key? key,
    required this.orderReference,
    required this.customerName,
    required this.branch,
    required this.orderMethod,
    required this.pickupTime,
    required this.orderItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Success icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: palmGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 20),

                // Success message
                TextWidget(
                  text: 'YOUR ORDER IS\nCONFIRMED!',
                  fontSize: 24,
                  fontFamily: 'Bold',
                  color: textBlack,
                  align: TextAlign.center,
                ),

                const SizedBox(height: 10),

                TextWidget(
                  text:
                      'Show your order reference number to the barista upon PICKUP',
                  fontSize: 14,
                  fontFamily: 'Regular',
                  color: charcoalGray,
                  align: TextAlign.center,
                  maxLines: 2,
                ),

                const SizedBox(height: 8),

                TextWidget(
                  text: 'once your order is complete.',
                  fontSize: 12,
                  fontFamily: 'Regular',
                  color: charcoalGray,
                ),

                const SizedBox(height: 30),

                // Order reference
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ashGray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ashGray.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'ORDER REFERENCE NUMBER',
                        fontSize: 12,
                        fontFamily: 'Bold',
                        color: charcoalGray,
                      ),
                      const SizedBox(height: 8),
                      TextWidget(
                        text: orderReference,
                        fontSize: 24,
                        fontFamily: 'Bold',
                        color: textBlack,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Customer details
                _buildDetailSection('CUSTOMER DETAILS', [
                  _buildDetailRow('Name:', customerName),
                  _buildDetailRow('Branch:', branch),
                  _buildDetailRow('Self Pickup:', pickupTime),
                ]),

                const SizedBox(height: 20),

                // Pickup instructions
                _buildDetailSection('PICKUP INSTRUCTIONS', [
                  _buildInstructionText(
                      '• Please claim your order within 45 minutes of pickup time. Should you arrive late for your PICKUP, beverages will be remade.'),
                  _buildInstructionText(
                      '• Unclaimed orders are considered sold and will not be refunded or replaced.'),
                  _buildInstructionText(
                      '• Show your order reference number to our barista upon PICKUP.'),
                ]),

                const SizedBox(height: 20),

                // Your order
                _buildDetailSection(
                  'YOUR ORDER',
                  orderItems.map((item) => _buildOrderItem(item)).toList(),
                ),

                SizedBox(height: 20),

                // Go to activity button
                ButtonWidget(
                  label: 'GO TO ACTIVITYS',
                  onPressed: () {
                    Get.back(); // Go back to home screen
                  },
                  color: palmGreen,
                  textColor: Colors.white,
                  fontSize: 16,
                  height: 50,
                  radius: 25,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: title,
            fontSize: 14,
            fontFamily: 'Bold',
            color: textBlack,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: TextWidget(
              text: label,
              fontSize: 14,
              fontFamily: 'Regular',
              color: charcoalGray,
            ),
          ),
          Expanded(
            child: TextWidget(
              text: value,
              fontSize: 14,
              fontFamily: 'Regular',
              color: textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextWidget(
        text: text,
        fontSize: 12,
        fontFamily: 'Regular',
        color: charcoalGray,
        maxLines: 3,
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: ashGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_cafe,
              color: bayanihanBlue.withOpacity(0.5),
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: '${item['quantity']}x ${item['name']}',
                  fontSize: 14,
                  fontFamily: 'Bold',
                  color: textBlack,
                ),
                if (item['customizations'] != null)
                  TextWidget(
                    text:
                        '${item['customizations']['size']} • ${item['customizations']['sweetness']} • ${item['customizations']['ice']}',
                    fontSize: 12,
                    fontFamily: 'Regular',
                    color: charcoalGray,
                    maxLines: 2,
                  ),
              ],
            ),
          ),

          TextWidget(
            text: 'P ${(item['price'] * item['quantity']).toStringAsFixed(2)}',
            fontSize: 14,
            fontFamily: 'Bold',
            color: textBlack,
          ),
        ],
      ),
    );
  }
}

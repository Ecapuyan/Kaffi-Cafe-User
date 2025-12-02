import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaffi_cafe/screens/home_screen.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/toast_widget.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Sample order data
  final List<Map<String, dynamic>> _orders = [
    {
      'item': 'Espresso',
      'price': 69.0,
      'quantity': 2,
      'customizations': '2 Shots, Medium Sweetness, Regular Ice',
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
    },
    {
      'item': 'Croissant',
      'price': 49.0,
      'quantity': 1,
      'customizations': 'None',
      'image':
          'https://static.vecteezy.com/system/resources/thumbnails/012/025/024/small_2x/coffee-banner-ads-retro-brown-style-with-latte-and-coffee-beans-3d-realistic-simple-vector.jpg',
    },
  ];

  // Sample vouchers
  final List<Map<String, dynamic>> _vouchers = [
    {'name': 'None', 'discount': 0.0},
    {'name': '10% Off Order', 'discount': 0.1},
    {'name': 'Free Espresso', 'discount': 69.0},
  ];

  // State variables
  String _selectedMethod = 'Pickup';
  String _selectedVoucher = 'None';
  String _selectedPayment = 'Cash';
  final List<String> _deliveryMethods = ['Pickup', 'Dine-in'];
  final List<String> _paymentMethods = [
    'Cash',
    'Credit Card',
    'Mobile Payment'
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.036;
    final padding = screenWidth * 0.035;

    // Calculate subtotal, discount, and total
    double subtotal = _orders.fold(
        0, (sum, order) => sum + order['price'] * order['quantity']);
    double discount = _selectedVoucher == 'None'
        ? 0.0
        : _selectedVoucher == '10% Off Order'
            ? subtotal * 0.1
            : _vouchers
                .firstWhere((v) => v['name'] == _selectedVoucher)['discount'];
    double total = subtotal - discount;
    int earnedPoints = (total / 10).floor(); // 1 point per ₱10 spent

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: bayanihanBlue,
        title: TextWidget(
          text: 'Checkout',
          fontSize: 24,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Method
              TextWidget(
                text: 'Delivery Method',
                fontSize: 20,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _deliveryMethods.map((method) {
                  final isSelected = _selectedMethod == method;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      showCheckmark: false,
                      label: TextWidget(
                        text: method,
                        fontSize: fontSize,
                        color: isSelected ? plainWhite : textBlack,
                        isBold: isSelected,
                        fontFamily: 'Regular',
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedMethod = method;
                          });
                        }
                      },
                      backgroundColor: cloudWhite,
                      selectedColor: bayanihanBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? bayanihanBlue : ashGray,
                          width: 1.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      elevation: isSelected ? 3 : 0,
                      pressElevation: 5,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              DividerWidget(),
              // Order List
              TextWidget(
                text: 'Your Order',
                fontSize: 20,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: plainWhite,
                        boxShadow: [
                          BoxShadow(
                            color: bayanihanBlue.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(18),
                            ),
                            child: Image.network(
                              order['image'],
                              width: screenWidth * 0.25,
                              height: screenWidth * 0.25,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: screenWidth * 0.25,
                                height: screenWidth * 0.25,
                                color: ashGray,
                                child: Center(
                                  child: TextWidget(
                                    text: order['item'][0],
                                    fontSize: 24,
                                    color: plainWhite,
                                    isBold: true,
                                    fontFamily: 'Bold',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: order['item'],
                                  fontSize: fontSize + 1,
                                  color: textBlack,
                                  isBold: true,
                                  fontFamily: 'Bold',
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                TextWidget(
                                  text: 'Qty: ${order['quantity']}',
                                  fontSize: fontSize - 1,
                                  color: charcoalGray,
                                  fontFamily: 'Regular',
                                ),
                                const SizedBox(height: 4),
                                TextWidget(
                                  text: order['customizations'],
                                  fontSize: fontSize - 1,
                                  color: charcoalGray,
                                  fontFamily: 'Regular',
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 4),
                                TextWidget(
                                  text:
                                      '₱${(order['price'] * order['quantity']).toStringAsFixed(0)}',
                                  fontSize: fontSize,
                                  color: sunshineYellow,
                                  isBold: true,
                                  fontFamily: 'Bold',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              DividerWidget(),
              // Voucher Selection
              TextWidget(
                text: 'Apply Voucher',
                fontSize: 20,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: _selectedVoucher,
                isExpanded: true,
                items: _vouchers.map((voucher) {
                  return DropdownMenuItem<String>(
                    value: voucher['name'],
                    child: TextWidget(
                      text: voucher['name'],
                      fontSize: fontSize,
                      color: textBlack,
                      fontFamily: 'Regular',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVoucher = value!;
                  });
                },
                style: const TextStyle(color: textBlack),
                dropdownColor: plainWhite,
                borderRadius: BorderRadius.circular(10),
                underline: Container(
                  height: 1,
                  color: ashGray,
                ),
              ),
              const SizedBox(height: 18),
              DividerWidget(),
              // Payment Method
              TextWidget(
                text: 'Payment Method',
                fontSize: 20,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: _selectedPayment,
                isExpanded: true,
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: TextWidget(
                      text: method,
                      fontSize: fontSize,
                      color: textBlack,
                      fontFamily: 'Regular',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPayment = value!;
                  });
                },
                style: const TextStyle(color: textBlack),
                dropdownColor: plainWhite,
                borderRadius: BorderRadius.circular(10),
                underline: Container(
                  height: 1,
                  color: ashGray,
                ),
              ),
              const SizedBox(height: 18),
              DividerWidget(),
              // Order Summary
              TextWidget(
                text: 'Order Summary',
                fontSize: 20,
                color: textBlack,
                isBold: true,
                fontFamily: 'Bold',
                letterSpacing: 1.2,
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: plainWhite,
                    boxShadow: [
                      BoxShadow(
                        color: bayanihanBlue.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(
                            text: 'Subtotal',
                            fontSize: fontSize + 1,
                            color: textBlack,
                            fontFamily: 'Regular',
                          ),
                          TextWidget(
                            text: '₱${subtotal.toStringAsFixed(0)}',
                            fontSize: fontSize + 1,
                            color: textBlack,
                            isBold: true,
                            fontFamily: 'Bold',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(
                            text: 'Discount',
                            fontSize: fontSize + 1,
                            color: textBlack,
                            fontFamily: 'Regular',
                          ),
                          TextWidget(
                            text: '-₱${discount.toStringAsFixed(0)}',
                            fontSize: fontSize + 1,
                            color: textBlack,
                            isBold: true,
                            fontFamily: 'Bold',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(
                            text: 'Total',
                            fontSize: fontSize + 2,
                            color: textBlack,
                            isBold: true,
                            fontFamily: 'Bold',
                          ),
                          TextWidget(
                            text: '₱${total.toStringAsFixed(0)}',
                            fontSize: fontSize + 2,
                            color: sunshineYellow,
                            isBold: true,
                            fontFamily: 'Bold',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(
                            text: 'Earned Points',
                            fontSize: fontSize + 1,
                            color: textBlack,
                            fontFamily: 'Regular',
                          ),
                          TextWidget(
                            text: '+$earnedPoints Points',
                            fontSize: fontSize + 1,
                            color: sunshineYellow,
                            isBold: true,
                            fontFamily: 'Bold',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Confirm Order Button
              Center(
                child: ButtonWidget(
                  label: 'Confirm Order',
                  onPressed: () {
                    Get.offAll(HomeScreen(),
                        transition: Transition.circularReveal);
                    showToast('Order placed successfully!');
                  },
                  color: bayanihanBlue,
                  textColor: plainWhite,
                  fontSize: fontSize + 2,
                  height: 50,
                  radius: 12,
                  width: screenWidth * 0.6,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

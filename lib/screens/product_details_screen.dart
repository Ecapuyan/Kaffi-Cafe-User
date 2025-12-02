import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final void Function(Map<String, dynamic> item, int quantity) addToCart;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
    required this.addToCart,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  String _selectedEspresso = 'Standard (double)';
  bool _addShot = false;
  String _selectedSize = 'Regular';
  String _selectedSweetness = 'Regular Sweetness';
  String _selectedIce = 'Regular';

  final List<String> _espressoOptions = [
    'Standard (double)',
  ];

  final List<String> _sizeOptions = [
    'Regular',
    'Large',
  ];

  final List<String> _sweetnessLevels = [
    'Regular Sweetness',
    'Less Sweet',
    'Extra Sweet',
  ];

  final List<String> _iceLevels = [
    'Regular',
    'Less Ice',
  ];

  bool get _isDrink {
    final category = widget.product['category'] as String?;
    return category == 'Coffee' || category == 'Non-Coffee Drinks';
  }

  double get _totalPrice {
    double basePrice = widget.product['price'].toDouble();
    if (_isDrink) {
      double addShotPrice = _addShot ? 25.0 : 0.0;
      double sizePrice = _selectedSize == 'Large' ? 15.0 : 0.0;
      return basePrice + addShotPrice + sizePrice;
    }
    return basePrice;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, color: textBlack),
                  ),
                  Expanded(
                    child: TextWidget(
                      text: widget.product['name'],
                      fontSize: 20,
                      fontFamily: 'Bold',
                      color: textBlack,
                      align: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Product image placeholder
            Stack(
              children: [
                Container(
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.3,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: ashGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(
                        widget.product['image'],
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Ingredients overlay at bottom of image
                Positioned(
                  bottom: 0,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Ingredients:',
                          fontSize: 14,
                          fontFamily: 'Bold',
                          color: textBlack,
                        ),
                        const SizedBox(height: 4),
                        TextWidget(
                          text:
                              widget.product['ingredients'] ?? 'Coffee, Water',
                          fontSize: 12,
                          fontFamily: 'Regular',
                          color: charcoalGray,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Product details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name and description
                    TextWidget(
                      text: widget.product['name'],
                      fontSize: 24,
                      fontFamily: 'Bold',
                      color: textBlack,
                    ),

                    const SizedBox(height: 20),

                    // Show customization options only for drinks
                    if (_isDrink) ...[
                      // Espresso Shots
                      _buildSectionTitle('Espresso Shots'),
                      const SizedBox(height: 12),
                      ..._espressoOptions.map((espresso) => _buildRadioOption(
                            title: espresso,
                            subtitle: 'P 0.00',
                            value: espresso,
                            groupValue: _selectedEspresso,
                            onChanged: (value) =>
                                setState(() => _selectedEspresso = value!),
                          )),
                      const SizedBox(height: 8),
                      _buildCheckboxOption(
                        title: 'Add Shot',
                        subtitle: '+P 25.00',
                        value: _addShot,
                        onChanged: (value) => setState(() => _addShot = value!),
                      ),

                      const SizedBox(height: 20),

                      // Coffee Size
                      _buildSectionTitle('Coffee Size - Choose one'),
                      const SizedBox(height: 12),
                      ..._sizeOptions.map((size) => _buildRadioOption(
                            title: size,
                            subtitle: size == 'Large' ? '+P 15.00' : 'P 0.00',
                            value: size,
                            groupValue: _selectedSize,
                            onChanged: (value) =>
                                setState(() => _selectedSize = value!),
                          )),

                      const SizedBox(height: 20),

                      // Sweetness Level
                      _buildSectionTitle('Sweetness Level - Choose one'),
                      const SizedBox(height: 12),
                      ..._sweetnessLevels.map((sweetness) => _buildRadioOption(
                            title: sweetness,
                            subtitle: 'P 0.00',
                            value: sweetness,
                            groupValue: _selectedSweetness,
                            onChanged: (value) =>
                                setState(() => _selectedSweetness = value!),
                          )),

                      const SizedBox(height: 20),

                      // Ice Level
                      _buildSectionTitle('Ice Level'),
                      const SizedBox(height: 12),
                      ..._iceLevels.map((ice) => _buildRadioOption(
                            title: ice,
                            subtitle: 'P 0.00',
                            value: ice,
                            groupValue: _selectedIce,
                            onChanged: (value) =>
                                setState(() => _selectedIce = value!),
                          )),
                    ] else ...[
                      // For non-drink items, show the description
                      if (widget.product['description'] != null &&
                          widget.product['description']
                              .toString()
                              .isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bayanihanBlue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: bayanihanBlue.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: 'Description',
                                fontSize: 16,
                                fontFamily: 'Bold',
                                color: textBlack,
                              ),
                              const SizedBox(height: 8),
                              TextWidget(
                                text: widget.product['description'],
                                fontSize: 14,
                                color: charcoalGray,
                                fontFamily: 'Regular',
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Fallback if no description is available
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bayanihanBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: bayanihanBlue,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextWidget(
                                  text:
                                      'This item is served as is. No customization available.',
                                  fontSize: 14,
                                  color: textBlack,
                                  fontFamily: 'Regular',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom add to cart section
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quantity controls
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: ashGray),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: Icon(Icons.remove,
                        color: _quantity > 1 ? textBlack : ashGray),
                  ),
                  TextWidget(
                    text: '$_quantity',
                    fontSize: 18,
                    fontFamily: 'Bold',
                    color: textBlack,
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: Icon(Icons.add, color: textBlack),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Add to cart button
            Expanded(
              child: ButtonWidget(
                label:
                    'ADD TO CART - P ${(_totalPrice * _quantity).toStringAsFixed(2)}',
                onPressed: () {
                  // Create item with or without customizations
                  Map<String, dynamic> item = {
                    'name': widget.product['name'],
                    'price': _totalPrice,
                    'quantity': _quantity,
                    'image': widget.product['image'], // Add image field
                  };

                  // Add customizations only for drinks
                  if (_isDrink) {
                    item['customizations'] = {
                      'espresso': _selectedEspresso,
                      'addShot': _addShot,
                      'size': _selectedSize,
                      'sweetness': _selectedSweetness,
                      'ice': _selectedIce,
                    };
                  }

                  widget.addToCart(item, _quantity);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: TextWidget(
                        text: '${widget.product['name']} added to cart',
                        fontSize: 14,
                        color: Colors.white,
                        fontFamily: 'Regular',
                      ),
                      backgroundColor: bayanihanBlue,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                color: palmGreen,
                textColor: Colors.white,
                fontSize: 16,
                height: 50,
                radius: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return TextWidget(
      text: title,
      fontSize: 16,
      fontFamily: 'Bold',
      color: textBlack,
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required void Function(String?) onChanged,
  }) {
    final isSelected = value == groupValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? bayanihanBlue : ashGray.withOpacity(0.5),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? bayanihanBlue.withOpacity(0.05)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? bayanihanBlue : ashGray,
                    width: 2,
                  ),
                  color: isSelected ? bayanihanBlue : Colors.transparent,
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextWidget(
                  text: title,
                  fontSize: 14,
                  fontFamily: 'Regular',
                  color: textBlack,
                ),
              ),
              TextWidget(
                text: subtitle,
                fontSize: 14,
                fontFamily: 'Bold',
                color: isSelected ? bayanihanBlue : charcoalGray,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxOption({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: value ? bayanihanBlue : ashGray.withOpacity(0.5),
              width: value ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: value ? bayanihanBlue.withOpacity(0.05) : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    color: value ? bayanihanBlue : ashGray,
                    width: 2,
                  ),
                  color: value ? bayanihanBlue : Colors.transparent,
                ),
                child: value
                    ? const Center(
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextWidget(
                  text: title,
                  fontSize: 14,
                  fontFamily: 'Regular',
                  color: textBlack,
                ),
              ),
              TextWidget(
                text: subtitle,
                fontSize: 14,
                fontFamily: 'Bold',
                color: value ? bayanihanBlue : charcoalGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

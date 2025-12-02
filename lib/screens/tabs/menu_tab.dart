import 'package:flutter/material.dart';
import 'package:get/get_core/get_core.dart';
import 'package:kaffi_cafe/screens/home_screen.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaffi_cafe/screens/product_details_screen.dart';
import 'package:kaffi_cafe/widgets/recommendation_widget.dart';
import 'package:get_storage/get_storage.dart';

class MenuTab extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final void Function(Map<String, dynamic> item, int quantity) addToCart;
  final void Function(Map<String, dynamic> item) removeFromCart;
  final VoidCallback clearCart;
  final double subtotal;
  final VoidCallback onViewCart;
  final String? selectedBranch;
  final void Function(String?)? setBranch;
  final String? selectedType;
  final void Function(String?)? setType;
  final List<String>? branches;
  const MenuTab({
    Key? key,
    required this.cartItems,
    required this.addToCart,
    required this.removeFromCart,
    required this.clearCart,
    required this.subtotal,
    required this.onViewCart,
    this.selectedBranch,
    this.setBranch,
    this.selectedType,
    this.setType,
    this.branches,
  }) : super(key: key);

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  final List<String> _categories = [
    'All',
    'Coffee',
    'Non-Coffee Drinks',
    'Pastries',
    'Sandwiches',
    'Frappe',
    'Cloud Series',
    'Milk Tea',
    'Fruit Tea',
    'Croffle',
    'Pasta',
    'Add-ons',
  ];
  String _selectedCategory = 'All';

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Coffee':
        return Icons.local_cafe;
      case 'Non-Coffee Drinks':
        return Icons.local_bar;
      case 'Pastries':
        return Icons.cookie;
      case 'Sandwiches':
        return Icons.lunch_dining;
      case 'Add-ons':
        return Icons.add_circle_outline;
      default:
        return Icons.restaurant_menu;
    }
  }

  final _storage = GetStorage();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.45;
    final cardHeight = screenWidth * 0.55;
    final fontSize = screenWidth * 0.035;
    final padding = screenWidth * 0.03;

    return Scaffold(
      floatingActionButton: widget.cartItems.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(50, 12.5, 12.5, 0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
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
                          // Cart icon with item count
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: bayanihanBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.shopping_cart,
                                    color: bayanihanBlue,
                                    size: 20,
                                  ),
                                ),
                                if (widget.cartItems.length > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: TextWidget(
                                          text: '${widget.cartItems.length}',
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontFamily: 'Bold',
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Price display
                          Expanded(
                            child: TextWidget(
                              text: 'P ${widget.subtotal.toStringAsFixed(2)}',
                              fontSize: 18,
                              color: textBlack,
                              fontFamily: 'Bold',
                            ),
                          ),
                          // Checkout button
                          ButtonWidget(
                            label: 'Checkout',
                            onPressed:
                                (_storage.read('selectedBranch') == null ||
                                        _storage.read('selectedType') == null)
                                    ? null
                                    : widget.onViewCart,
                            color: bayanihanBlue,
                            textColor: Colors.white,
                            fontSize: 16,
                            height: 45,
                            width: 100,
                            radius: 22,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Branch & Type Header
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7FB),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: bayanihanBlue, size: 22),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextWidget(
                            text: widget.selectedBranch ?? 'Select Branch',
                            fontSize: 16,
                            color: bayanihanBlue,
                            fontFamily: 'Bold',
                            maxLines: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            if (widget.selectedType == null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: (widget.selectedType != null)
                                  ? bayanihanBlue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 7),
                              child: TextWidget(
                                text: widget.selectedType ?? 'Select Type',
                                fontSize: 15,
                                color: (widget.selectedType != null)
                                    ? Colors.white
                                    : bayanihanBlue,
                                fontFamily: 'Bold',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextWidget(
                    text: 'Our Menu',
                    fontSize: 22,
                    color: textBlack,
                    isBold: true,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(height: 10),
                  DividerWidget(),
                  // Category Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            showCheckmark: false,
                            label: TextWidget(
                              text: category,
                              fontSize: 14,
                              color: isSelected ? plainWhite : textBlack,
                              isBold: isSelected,
                              fontFamily: 'Regular',
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              }
                            },
                            backgroundColor: cloudWhite,
                            selectedColor: bayanihanBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7.5),
                              side: BorderSide(
                                color: isSelected ? bayanihanBlue : ashGray,
                                width: 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.5, vertical: 5),
                            elevation: isSelected ? 1 : 0,
                            pressElevation: 1,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Menu Grid from Firestore
                  StreamBuilder<QuerySnapshot>(
                    stream: _selectedCategory == 'All'
                        ? FirebaseFirestore.instance
                            .collection('products')
                            .where('branch',
                                isEqualTo: _storage.read('selectedBranch'))
                            .orderBy('timestamp', descending: true)
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('products')
                            .where('branch',
                                isEqualTo: _storage.read('selectedBranch'))
                            .where('category', isEqualTo: _selectedCategory)
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: \\${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final menuItems = snapshot.data!.docs;
                      if (menuItems.isEmpty) {
                        return Center(child: Text('No items found.'));
                      }

                      // Product Grid with proper physics
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: cardWidth / cardHeight,
                        ),
                        itemCount: menuItems.length,
                        itemBuilder: (context, index) {
                          final data =
                              menuItems[index].data() as Map<String, dynamic>;
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: plainWhite,
                                boxShadow: [
                                  BoxShadow(
                                    color: bayanihanBlue.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: data['image'] != null &&
                                            data['image'].toString().isNotEmpty
                                        ? Image.network(
                                            data['image'],
                                            height: cardHeight * 0.5,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              color: ashGray,
                                              height: cardHeight * 0.5,
                                              width: double.infinity,
                                              child: Center(
                                                child: Icon(
                                                  _getCategoryIcon(
                                                      data['category']),
                                                  size: 40,
                                                  color: plainWhite,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: ashGray,
                                            height: cardHeight * 0.5,
                                            width: double.infinity,
                                            child: Center(
                                              child: Icon(
                                                _getCategoryIcon(
                                                    data['category']),
                                                size: 40,
                                                color: plainWhite,
                                              ),
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(padding),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextWidget(
                                          text: data['name'],
                                          fontSize: fontSize + 2,
                                          color: textBlack,
                                          isBold: true,
                                          fontFamily: 'Bold',
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextWidget(
                                              text:
                                                  '₱${(data['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
                                              fontSize: 18,
                                              color: const Color.fromARGB(
                                                  255, 255, 213, 0),
                                              isBold: true,
                                              fontFamily: 'Bold',
                                            ),
                                            ButtonWidget(
                                              label: 'Order',
                                              onPressed: (_storage.read(
                                                              'selectedBranch') ==
                                                          null ||
                                                      _storage.read(
                                                              'selectedType') ==
                                                          null)
                                                  ? null
                                                  : () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProductDetailsScreen(
                                                            product: data,
                                                            addToCart: widget
                                                                .addToCart,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                              color: bayanihanBlue,
                                              textColor: plainWhite,
                                              fontSize: fontSize - 2,
                                              height: 34,
                                              radius: 10,
                                              width: 80,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

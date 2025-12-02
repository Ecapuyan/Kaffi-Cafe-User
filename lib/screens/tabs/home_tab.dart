import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaffi_cafe/screens/reservation_screen.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/touchable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'dart:math';

class HomeTab extends StatefulWidget {
  final VoidCallback? onBranchSelected;
  final void Function(String type, String branch)? onTypeAndBranchSelected;
  final void Function(Map<String, dynamic> item, int quantity)? addToCart;
  const HomeTab(
      {Key? key,
      this.onBranchSelected,
      this.onTypeAndBranchSelected,
      this.addToCart})
      : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final box = GetStorage();
  // No static recent orders, use Firestore instead

  Widget _buildRecentOrderSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.034;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId',
              isEqualTo:
                  box.read('userData')?['email'] ?? box.read('user')?['email'])
          .orderBy('timestamp', descending: true)
          .limit(1) // Only get the most recent order
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data!.docs;

        if (orders.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextWidget(
                text: 'No recent orders found.',
                fontSize: fontSize,
                color: textBlack,
                fontFamily: 'Regular',
              ),
            ),
          );
        }

        // Get the most recent order
        final orderData = orders[0].data() as Map<String, dynamic>;
        final items = orderData['items'] as List<dynamic>?;

        if (items == null || items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextWidget(
                text: 'No items in recent order.',
                fontSize: fontSize,
                color: textBlack,
                fontFamily: 'Regular',
              ),
            ),
          );
        }

        return Column(
          children: [
            // 💙 YOUR RECENT ORDER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: 'YOUR RECENT ORDER',
                  fontSize: 22,
                  color: textBlack,
                  isBold: true,
                  fontFamily: 'Bold',
                ),
                ElevatedButton(
                  onPressed: () {
                    if (items.isNotEmpty && widget.addToCart != null) {
                      for (var item in items) {
                        if (item is Map<String, dynamic>) {
                          final itemName = item['name'] ?? 'Order';
                          final itemPrice = item['price'] ?? 0;
                          final itemQuantity = item['quantity'] ?? 1;
                          widget.addToCart!(
                            {
                              'name': itemName,
                              'price': itemPrice,
                              'image': item['image'] ?? '',
                            },
                            itemQuantity is int ? itemQuantity : 1,
                          );
                        }
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Order items added to cart!'),
                          duration: Duration(seconds: 2),
                          backgroundColor: bayanihanBlue,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                  ),
                  child: TextWidget(
                    text: 'RE-ORDER',
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: 'Bold',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Product cards in a horizontal scrollable list
            SizedBox(
              height: 200,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map<String, dynamic>;
                  final itemName = item['name'] ?? 'Product';
                  final itemPrice = item['price'] ?? 0;
                  final itemImage = item['image'] ?? '';

                  return Center(
                    child: Container(
                      width: 350,
                      margin: EdgeInsets.only(
                        right: index < items.length - 1 ? 12 : 0,
                      ),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFB8D4A8),
                                      Color(0xFFA8C498),
                                    ],
                                  ),
                                ),
                                child: itemImage.isNotEmpty
                                    ? Image.network(
                                        itemImage,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Center(
                                          child: Icon(
                                            Icons.local_cafe,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.local_cafe,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            // Product Details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: itemName,
                                      fontSize: 14,
                                      color: textBlack,
                                      fontFamily: 'Medium',
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 4),
                                    TextWidget(
                                      text: '₱ ${itemPrice.toStringAsFixed(2)}',
                                      fontSize: 16,
                                      color: bayanihanBlue,
                                      fontFamily: 'Bold',
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Coffee':
        return Icons.local_cafe;
      case 'Drinks':
        return Icons.local_drink;
      case 'Foods':
        return Icons.fastfood;
      default:
        return Icons.fastfood;
    }
  }

  void _showAddToCartDialog(Map<String, dynamic> item) {
    int quantity = 1;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add ${item['name']}'),
          content: Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (quantity > 1) {
                    quantity--;
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
              Text('$quantity'),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  quantity++;
                  (context as Element).markNeedsBuild();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (widget.addToCart != null) {
                  widget.addToCart!(item, quantity);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['name']} added to cart'),
                  ),
                );
              },
              child: Text('Add to Cart'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build product cards
  Widget _buildProductCard(Map<String, dynamic> data, double cardWidth,
      double cardHeight, double gradientHeight, double padding) {
    return TouchableWidget(
      onTap: () {
        _showAddToCartDialog(data);
      },
      child: Card(
        elevation: 1,
        child: Container(
          height: cardHeight,
          width: cardWidth,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                // Category icon background
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: bayanihanBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                          image: NetworkImage(
                            data['image'],
                          ),
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: gradientHeight,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          jetBlack.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),

                // Text content
                Padding(
                  padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextWidget(
                              text: data['name'] ?? 'Product',
                              fontSize: 16,
                              fontFamily: 'Medium',
                              color: Colors.white,
                              maxLines: 1,
                            ),
                          ),
                          TextWidget(
                            text:
                                '₱${(data['price'] as num?)?.toStringAsFixed(0) ?? '0'}',
                            fontSize: 22,
                            fontFamily: 'Bold',
                            color: bayanihanBlue,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add state to track selected type
  String? _pendingType;

  /// Complementary Recommendation Algorithm Function
  /// This function recommends complementary items based on cart contents
  Future<List<Map<String, dynamic>>> getKNNRecommendations(String userId,
      {int k = 3}) async {
    try {
      // Define drink and food categories
      final List<String> drinkCategories = [
        'Coffee',
        'Non-Coffee Drinks',
        'Frappes',
        'Cloud Series',
        'Milk Tea',
        'Fruit Tea'
      ];

      final List<String> foodCategories = [
        'Sandwiches',
        'Croffle',
        'Pasta',
        'Pastries',
        'Add-ons'
      ];

      // Get current cart items from storage or pass them as parameter
      // For now, we'll get the most recent order to simulate cart
      final recentOrderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      List<Map<String, dynamic>> cartItems = [];
      if (recentOrderSnapshot.docs.isNotEmpty) {
        final orderData =
            recentOrderSnapshot.docs.first.data() as Map<String, dynamic>;
        final items = orderData['items'] as List<dynamic>?;
        if (items != null) {
          cartItems =
              items.map((item) => item as Map<String, dynamic>).toList();
        }
      }

      // If no cart items, return popular products
      if (cartItems.isEmpty) {
        return await _getPopularProducts(k);
      }

      // Determine if cart has more drinks or food
      int drinkCount = 0;
      int foodCount = 0;

      for (var item in cartItems) {
        // Get product details to check category
        final productSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('name', isEqualTo: item['name'])
            .limit(1)
            .get();

        if (productSnapshot.docs.isNotEmpty) {
          final productData = productSnapshot.docs.first.data();
          final category = productData['category'] as String?;

          if (category != null && drinkCategories.contains(category)) {
            drinkCount++;
          } else if (category != null && foodCategories.contains(category)) {
            foodCount++;
          }
        }
      }

      // Determine which category to recommend
      final bool recommendFood = drinkCount > foodCount;
      final List<String> targetCategories =
          recommendFood ? foodCategories : drinkCategories;

      // Get products from target categories
      List<Map<String, dynamic>> recommendations = [];

      for (String category in targetCategories) {
        final categorySnapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('category', isEqualTo: category)
            .orderBy('orderCount', descending: true)
            .limit(k)
            .get();

        for (var doc in categorySnapshot.docs) {
          final productData = doc.data();
          productData['similarity_score'] =
              1.0; // Default score for complementary items
          recommendations.add(productData);
        }
      }

      // Sort by order count and limit to k items
      recommendations.sort((a, b) {
        final aCount = a['orderCount'] as int? ?? 0;
        final bCount = b['orderCount'] as int? ?? 0;
        return bCount.compareTo(aCount);
      });

      return recommendations.take(k).toList();
    } catch (e) {
      print('Error in recommendation: $e');
      // Return empty list if there's an error
      return [];
    }
  }

  /// Helper function to get popular products when no cart is available
  Future<List<Map<String, dynamic>>> _getPopularProducts(int k) async {
    try {
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('orderCount', descending: true)
          .limit(k)
          .get();

      return productsSnapshot.docs.map((doc) {
        final productData = doc.data();
        productData['similarity_score'] = 1.0;
        return productData;
      }).toList();
    } catch (e) {
      print('Error getting popular products: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.42;
    final cardHeight = screenWidth * 0.55;
    final gradientHeight = cardHeight * 0.6;
    final fontSize = screenWidth * 0.035;
    final padding = screenWidth * 0.03;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recommendation Banner
            Image.asset(
              'assets/images/illu.png',
            ),
            // DividerWidget(),
            // // For You Section
            // TextWidget(
            //   text: 'For You',
            //   fontSize: 22,
            //   color: textBlack,
            //   isBold: true,
            //   fontFamily: 'Bold',
            // ),
            // const SizedBox(height: 10),
            // SizedBox(
            //   height: 180,
            //   child: FutureBuilder<List<Map<String, dynamic>>>(
            //     future: getKNNRecommendations(box.read('userData')?['email'] ?? box.read('user')?['email'] ?? '',
            //         k: 5),
            //     builder: (context, snapshot) {
            //       if (snapshot.hasError) {
            //         return Center(child: Text('Error: ${snapshot.error}'));
            //       }
            //       if (!snapshot.hasData) {
            //         return const Center(child: CircularProgressIndicator());
            //       }
            //       final recommendations = snapshot.data!;
            //       if (recommendations.isEmpty) {
            //         // Fallback to latest products if no recommendations
            //         return StreamBuilder<QuerySnapshot>(
            //           stream: FirebaseFirestore.instance
            //               .collection('products')
            //               .orderBy('timestamp', descending: true)
            //               .limit(5)
            //               .snapshots(),
            //           builder: (context, productSnapshot) {
            //             if (productSnapshot.hasError) {
            //               return Center(
            //                   child: Text('Error: ${productSnapshot.error}'));
            //             }
            //             if (!productSnapshot.hasData) {
            //               return const Center(
            //                   child: CircularProgressIndicator());
            //             }
            //             final products = productSnapshot.data!.docs;
            //             if (products.isEmpty) {
            //               return Center(child: Text('No products found.'));
            //             }
            //             return ListView.builder(
            //               scrollDirection: Axis.horizontal,
            //               itemCount: products.length,
            //               itemBuilder: (context, index) {
            //                 final data =
            //                     products[index].data() as Map<String, dynamic>;
            //                 return _buildProductCard(data, cardWidth,
            //                     cardHeight, gradientHeight, padding);
            //               },
            //             );
            //           },
            //         );
            //       }
            //       return ListView.builder(
            //         scrollDirection: Axis.horizontal,
            //         itemCount: recommendations.length,
            //         itemBuilder: (context, index) {
            //           final data = recommendations[index];
            //           return _buildProductCard(
            //               data, cardWidth, cardHeight, gradientHeight, padding);
            //         },
            //       );
            //     },
            //   ),
            // ),
            const SizedBox(height: 16),

            DividerWidget(),

            Center(child: _buildRecentOrderSection()),
            const SizedBox(height: 16),
            DividerWidget(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TouchableWidget(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: const Text(
                                'Seat Reservation',
                                style: TextStyle(
                                    fontFamily: 'Bold',
                                    fontWeight: FontWeight.bold),
                              ),
                              content: const Text(
                                'Do you want to reserve seats?',
                                style: TextStyle(fontFamily: 'Regular'),
                              ),
                              actions: <Widget>[
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                    setState(() {
                                      _pendingType = 'Dine in';
                                    });
                                    _showBranchSelectionDialog('Dine in');
                                  },
                                  child: const Text(
                                    'Close',
                                    style: TextStyle(
                                        fontFamily: 'Regular',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        final screenWidth =
                                            MediaQuery.of(context).size.width;
                                        final fontSize = screenWidth * 0.036;
                                        final padding = screenWidth * 0.035;

                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          backgroundColor: plainWhite,
                                          title: TextWidget(
                                            text: 'Select Branch for Dine in',
                                            fontSize: 20,
                                            color: textBlack,
                                            isBold: true,
                                            fontFamily: 'Bold',
                                            letterSpacing: 1.2,
                                          ),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: _branches.map((branch) {
                                                return Card(
                                                  elevation: 3,
                                                  margin: const EdgeInsets.only(
                                                      bottom: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: TouchableWidget(
                                                    onTap: () {
                                                      box.write(
                                                          'selectedBranch',
                                                          branch['name']!);
                                                      box.write('selectedType',
                                                          'Dine in');

                                                      // Handle branch selection
                                                      Navigator.pop(context);
                                                      // Reservation here
                                                      Get.to(SeatReservationScreen(),
                                                              transition: Transition
                                                                  .circularReveal)
                                                          ?.then((result) {
                                                        if (result['action'] ==
                                                            'goToMenu') {
                                                          if (widget
                                                                  .onBranchSelected !=
                                                              null) {
                                                            widget
                                                                .onBranchSelected!();
                                                          }
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                          padding),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        color: plainWhite,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: bayanihanBlue
                                                                .withOpacity(
                                                                    0.1),
                                                            blurRadius: 6,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            child:
                                                                Image.network(
                                                              branch['image']!,
                                                              width:
                                                                  screenWidth *
                                                                      0.25,
                                                              height:
                                                                  screenWidth *
                                                                      0.25,
                                                              fit: BoxFit.cover,
                                                              errorBuilder:
                                                                  (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Container(
                                                                width:
                                                                    screenWidth *
                                                                        0.25,
                                                                height:
                                                                    screenWidth *
                                                                        0.25,
                                                                color: ashGray,
                                                                child: Center(
                                                                  child:
                                                                      TextWidget(
                                                                    text: branch[
                                                                        'name']![0],
                                                                    fontSize:
                                                                        24,
                                                                    color:
                                                                        plainWhite,
                                                                    isBold:
                                                                        true,
                                                                    fontFamily:
                                                                        'Bold',
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 12),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                TextWidget(
                                                                  text: branch[
                                                                      'name']!,
                                                                  fontSize:
                                                                      fontSize +
                                                                          1,
                                                                  color:
                                                                      textBlack,
                                                                  isBold: true,
                                                                  fontFamily:
                                                                      'Bold',
                                                                  maxLines: 1,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                          actions: [
                                            ButtonWidget(
                                              label: 'Cancel',
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              color: ashGray,
                                              textColor: textBlack,
                                              fontSize: fontSize,
                                              height: 40,
                                              radius: 12,
                                              width: 100,
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    // Get.off(LandingScreen(),
                                    //     transition: Transition.circularReveal);
                                  },
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(
                                        fontFamily: 'Regular',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ));
                  },
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/salad.png',
                            height: 125,
                          ),
                          TextWidget(
                            text: 'Dine In',
                            fontSize: 18,
                            fontFamily: 'Bold',
                            color: Colors.black,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TouchableWidget(
                  onTap: () {
                    setState(() {
                      _pendingType = 'Pickup';
                    });
                    _showBranchSelectionDialog('Pickup');
                  },
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/delivery.png',
                            height: 125,
                          ),
                          TextWidget(
                            text: 'Pickup',
                            fontSize: 18,
                            fontFamily: 'Bold',
                            color: Colors.black,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  final List<Map<String, String>> _branches = [
    {
      'name': 'Kaffi Cafe - Eloisa St',
      'address': '123 Bayanihan St, Manila, Philippines',
      'image':
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/10/1f/ef/54/te-kaffi.jpg?w=1000&h=-1&s=1',
    },
    {
      'name': 'Kaffi Cafe - P.Noval',
      'address': '456 Espresso Ave, Quezon City, Philippines',
      'image':
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/13/02/71/53/fron.jpg?w=1000&h=-1&s=1',
    },
  ];
  // Show branch selection dialog
  void _showBranchSelectionDialog(String method) {
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final fontSize = screenWidth * 0.036;
        final padding = screenWidth * 0.035;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: plainWhite,
          title: TextWidget(
            text: 'Select Branch for $method',
            fontSize: 20,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
            letterSpacing: 1.2,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _branches.map((branch) {
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TouchableWidget(
                    onTap: () {
                      box.write('selectedBranch', branch['name']);
                      box.write('selectedType', method);
                      Navigator.pop(context);
                      if (widget.onTypeAndBranchSelected != null &&
                          _pendingType != null) {
                        widget.onTypeAndBranchSelected!(
                            _pendingType!, branch['name']!);
                        _pendingType = null;
                      } else if (widget.onBranchSelected != null) {
                        widget.onBranchSelected!();
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: TextWidget(
                            text: 'Selected ${branch['name']} for $method',
                            fontSize: fontSize - 1,
                            color: plainWhite,
                            fontFamily: 'Regular',
                          ),
                          backgroundColor: bayanihanBlue,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
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
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              branch['image']!,
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
                                    text: branch['name']![0],
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
                                  text: branch['name']!,
                                  fontSize: fontSize + 1,
                                  color: textBlack,
                                  isBold: true,
                                  fontFamily: 'Bold',
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            ButtonWidget(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
              color: ashGray,
              textColor: textBlack,
              fontSize: fontSize,
              height: 40,
              radius: 12,
              width: 100,
            ),
          ],
        );
      },
    );
  }
}

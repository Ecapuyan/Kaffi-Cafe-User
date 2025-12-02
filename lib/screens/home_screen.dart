import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaffi_cafe/screens/tabs/account_tab.dart';
import 'package:kaffi_cafe/screens/tabs/home_tab.dart';
import 'package:kaffi_cafe/screens/tabs/menu_tab.dart';
import 'package:kaffi_cafe/screens/tabs/order_screen.dart';
import 'package:kaffi_cafe/screens/tabs/reward_tab.dart';
import 'package:kaffi_cafe/screens/notifications_screen.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/logout_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/widgets/touchable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'reservation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GetStorage _storage = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;
  int _notificationCount = 0;
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    // Load stored branch and type
    _selectedBranch = _storage.read('selectedBranch');
    _selectedType = _storage.read('selectedType');
    // Get notification count in real-time
    _listenForNotifications();

    // Store the timestamp of when the app was opened
    _storage.write('lastOpenedTimestamp', Timestamp.now());

    // If not set, show dialog to select
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_storage.read('selectedBranch') == null ||
          _storage.read('selectedType') == null) {
        showOrderDialog();
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _listenForNotifications() {
    _notificationSubscription?.cancel();
    final userEmail = _storage.read('user')?['email'];
    if (userEmail != null) {
      _notificationSubscription = _firestore
          .collection('orders')
          .where('userId', isEqualTo: userEmail)
          .snapshots()
          .listen((snapshot) {
        _updateNotificationCount(snapshot.docs);
      });
    }
  }

  void _updateNotificationCount(List<QueryDocumentSnapshot> orderDocs) {
    final userEmail = _storage.read('user')?['email'];
    if (userEmail == null) {
      setState(() {
        _notificationCount = 0;
      });
      return;
    }

    List readNotifications =
        _storage.read('readNotifications_$userEmail') ?? [];

    Set<String> allNotificationIds = {};

    for (var doc in orderDocs) {
      final orderData = doc.data() as Map<String, dynamic>;
      final paymentMethod = orderData['paymentMethod'] ?? 'Unknown';
      final status = orderData['status'] ?? 'Pending';

      // Add order status notification
      allNotificationIds.add('${doc.id}_status');

      // Add payment notification if applicable
      if (paymentMethod != 'Cash' && status != 'Pending') {
        allNotificationIds.add('${doc.id}_payment');
      }
    }

    int unreadCount = 0;
    for (String notificationId in allNotificationIds) {
      if (!readNotifications.contains(notificationId)) {
        unreadCount++;
      }
    }

    if (mounted) {
      setState(() {
        _notificationCount = unreadCount;
      });
    }
  }

  // Cart state
  final List<Map<String, dynamic>> _cartItems = [];
  double get _subtotal => _cartItems.fold(
      0, (sum, item) => sum + (item['price'] * item['quantity']));

  String? _selectedBranch;
  String? _selectedType;

  void _setBranch(String? branch) {
    setState(() {
      _selectedBranch = branch;
    });
  }

  void _setType(String? type) {
    setState(() {
      _selectedType = type;
    });
  }

  void _addToCart(Map<String, dynamic> item, int quantity) {
    // Check if an item with the same name AND customizations already exists in cart
    final existingIndex = _cartItems.indexWhere((cartItem) {
      if (cartItem['name'] != item['name']) return false;

      // If both items have customizations, check if they match
      if (cartItem.containsKey('customizations') &&
          item.containsKey('customizations')) {
        final cartCustomizations =
            cartItem['customizations'] as Map<String, dynamic>? ?? {};
        final itemCustomizations =
            item['customizations'] as Map<String, dynamic>? ?? {};

        // Convert maps to strings for comparison
        final cartCustomizationsStr = cartCustomizations.toString();
        final itemCustomizationsStr = itemCustomizations.toString();

        return cartCustomizationsStr == itemCustomizationsStr;
      }

      // If only one has customizations, they don't match
      return !(cartItem.containsKey('customizations') ||
          item.containsKey('customizations'));
    });

    setState(() {
      if (existingIndex >= 0) {
        // Update quantity of existing item
        _cartItems[existingIndex]['quantity'] += quantity;
      } else {
        // Add new item to cart with all its properties including customizations
        final Map<String, dynamic> newItem = Map<String, dynamic>.from(item);
        newItem['quantity'] = quantity;

        // Ensure the item has all required fields
        if (!newItem.containsKey('name')) {
          newItem['name'] = 'Unknown Item';
        }
        if (!newItem.containsKey('price')) {
          newItem['price'] = 0.0;
        }
        if (!newItem.containsKey('quantity')) {
          newItem['quantity'] = quantity;
        }

        _cartItems.add(newItem);

        // Debug print to verify customizations are added
        print('Added item to cart: $newItem');
        if (newItem.containsKey('customizations')) {
          print('Item customizations: ${newItem['customizations']}');
        }
      }
    });
  }

  void _removeFromCart(Map<String, dynamic> item) {
    setState(() {
      _cartItems.remove(item);
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _selectedBranch = null;
      _selectedType = null;
    });
  }

  void _goToMenuTab() {
    if (_storage.read('selectedBranch') == null ||
        _storage.read('selectedType') == null) {
      showOrderDialog();
    } else {
      setState(() {
        _selectedIndex = 1;
      });
    }
  }

  void _goToOrderTab() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      if (_storage.read('selectedBranch') == null ||
          _storage.read('selectedType') == null) {
        showOrderDialog();
      }
    }
  }

  final box = GetStorage();

  showOrderDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final cardHeight = 110.0;
        final cardRadius = 18.0;
        final iconSize = 56.0;
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextWidget(
                  text: 'How would you like to get your order?',
                  fontSize: 18,
                  fontFamily: 'Bold',
                  align: TextAlign.center,
                  color: textBlack,
                ),
                SizedBox(height: 24),
                TouchableWidget(
                  onTap: () {
                    Navigator.pop(context);
                    _showBranchSelectionDialog('Pickup');
                  },
                  child: Card(
                    color: const Color(0xFFE6F0FA),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    child: Container(
                      height: cardHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(iconSize / 2),
                            ),
                            child: Image.asset(
                              'assets/images/delivery.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            child: TextWidget(
                              text: 'SELF PICKUP',
                              fontSize: 18,
                              fontFamily: 'Bold',
                              color: bayanihanBlue,
                              align: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TouchableWidget(
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                        barrierDismissible: false,
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
                                                        if (result != null &&
                                                            result is Map) {
                                                          if (result[
                                                                  'action'] ==
                                                              'goToMenu') {
                                                            print('12345');
                                                            // User wants to checkout with reservation
                                                            setState(() {
                                                              _selectedIndex =
                                                                  1; // Switch to menu tab
                                                            });
                                                            // Show message to add items to cart
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Reservation added! Add items to your cart and checkout.'),
                                                                backgroundColor:
                                                                    Colors.blue,
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                              ),
                                                            );
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
                    color: const Color(0xFFF6F7FB),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    child: Container(
                      height: cardHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(iconSize / 2),
                            ),
                            child: Image.asset(
                              'assets/images/salad.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            child: TextWidget(
                              text: 'DINE IN',
                              fontSize: 18,
                              fontFamily: 'Bold',
                              color: bayanihanBlue,
                              align: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeTab(
        onBranchSelected: _goToMenuTab,
        onTypeAndBranchSelected: (type, branch) {
          setState(() {
            _selectedType = type;
            _selectedBranch = branch;
            _selectedIndex = 1;
          });
        },
        addToCart: _addToCart,
      ),
      MenuTab(
        cartItems: _cartItems,
        addToCart: _addToCart,
        removeFromCart: _removeFromCart,
        clearCart: _clearCart,
        subtotal: _subtotal,
        onViewCart: _goToOrderTab,
        selectedBranch: _selectedBranch,
        selectedType: _selectedType,
      ),
      OrderScreen(
        cartItems: _cartItems,
        removeFromCart: _removeFromCart,
        addToCart: _addToCart,
        clearCart: _clearCart,
        subtotal: _subtotal,
        setBranch: _setBranch,
        setType: _setType,
        branches: _branches.map((b) => b['name']!).toList(),
      ),
      RewardScreen(),
      AccountScreen(isAccountTabSelected: _selectedIndex == 4),
    ];
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: bayanihanBlue,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  ).then((_) {
                    // Refresh notification count when returning from notifications screen
                    _listenForNotifications();
                  });
                },
                icon: Icon(
                  Icons.notifications,
                ),
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _notificationCount > 99
                          ? '99+'
                          : _notificationCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () {
              logout(context, HomeScreen());
            },
            icon: Icon(
              Icons.logout,
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        title: TextWidget(
          text:
              "Good Day ${box.read('userData')?['name']?.toString().split(' ').first ?? 'User'}!",
          fontSize: 24,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Reward',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: bayanihanBlue,
        unselectedItemColor: charcoalGray,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }

  final List<Map<String, String>> _branches = [
    {
      'name': 'Kaffi Cafe - Eloisa St',
      'address':
          '1218 Delos Reyes St. corner Eloisa St. Sampaloc Manila, Manila, Philippines',
      'image':
          'https://scontent.fmnl17-4.fna.fbcdn.net/v/t39.30808-6/476890271_122195140076044862_838675133139261737_n.jpg?stp=cp6_dst-jpg_tt6&_nc_cat=105&ccb=1-7&_nc_sid=833d8c&_nc_eui2=AeGVA5qlNpnAd7Wo9rN-kHnBnnrCa4mxRuOeesJribFG4-jedYkMZg2S-G6HyFIJcHi9rokroVfJ1AlhG2YlE2q0&_nc_ohc=68uUiaVz7TsQ7kNvwELFdX-&_nc_oc=AdkMdqPXhwf02wcxfxWDnUagsJCFq1YHBytGN62_NTrolVs3-fgMZRbPFuGb_Oh55mg&_nc_zt=23&_nc_ht=scontent.fmnl17-4.fna&_nc_gid=m5T_bS6LODrW3JBRza6BUA&oh=00_AfjrlZTPQM9Z0U65viEJbcU_vDwcLVEIrQv2fEtsoPcUgA&oe=6932FED8',
    },
    {
      'name': 'Kaffi Cafe - P.Noval',
      'address': '1051 Padre Noval St',
      'image':
          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/13/02/71/53/fron.jpg?w=1000&h=-1&s=1',
    },
  ];
  // Show branch selection dialog
  void _showBranchSelectionDialog(String method) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                      setState(() {
                        _selectedBranch = branch['name'];
                        _selectedType = method;
                        // Store selection in GetStorage
                        _storage.write('selectedBranch', _selectedBranch);
                        _storage.write('selectedType', _selectedType);
                      });

                      Navigator.pop(context);
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

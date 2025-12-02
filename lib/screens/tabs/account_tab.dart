import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaffi_cafe/screens/chatsupport_screen.dart';
import 'package:kaffi_cafe/screens/order_details_screen.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/divider_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

class AccountScreen extends StatefulWidget {
  final bool isAccountTabSelected;
  const AccountScreen({super.key, required this.isAccountTabSelected});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Set<String> _processedOrderIds = {};

  // Tab selection (Activity or Reservations)
  bool _showActivity = true;

  // Order status filter
  String _selectedStatus = 'All';
  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Preparing',
    'Ready',
    'Completed',
    'Cancelled'
  ];

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return palmGreen; // Green
      case 'pending':
        return accentOrange; // Orange
      case 'preparing':
        return palmGreen; // Green
      case 'ready':
        return Colors.purple;
      case 'cancelled':
        return festiveRed; // Red
      default:
        return textBlack; // Black
    }
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

  final box = GetStorage();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.44;
    final cardHeight = screenWidth * 0.58;
    final fontSize = screenWidth * 0.036;
    final padding = screenWidth * 0.035;

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
        final userName = userData?['name'];
        final userEmail = userData?['email'];
        final userPoints = userData?['points'] ?? 0;
        final totalOrders = userData?['totalOrders'] ?? 0;

        return SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Information
                TextWidget(
                  text: 'Profile',
                  fontSize: 22,
                  color: textBlack,
                  isBold: true,
                  fontFamily: 'Bold',
                  letterSpacing: 1.3,
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: bayanihanBlue.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: plainWhite,
                      boxShadow: [
                        BoxShadow(
                          color: bayanihanBlue.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Placeholder
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: bayanihanBlue.withOpacity(0.1),
                            border: Border.all(
                              color: bayanihanBlue,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: TextWidget(
                              text: userName != null && userName.isNotEmpty ? userName[0] : 'U',
                              fontSize: 28,
                              color: bayanihanBlue,
                              isBold: true,
                              fontFamily: 'Bold',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Profile Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    color: bayanihanBlue,
                                    size: fontSize + 4,
                                  ),
                                  const SizedBox(width: 8),
                                  TextWidget(
                                    text: userName ?? 'No Name',
                                    fontSize: fontSize + 3,
                                    color: textBlack,
                                    isBold: true,
                                    fontFamily: 'Bold',
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: bayanihanBlue,
                                    size: fontSize + 4,
                                  ),
                                  const SizedBox(width: 8),
                                  TextWidget(
                                    text: userEmail ?? 'No Email',
                                    fontSize: fontSize + 1,
                                    color: charcoalGray,
                                    fontFamily: 'Regular',
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
                const SizedBox(height: 18),
                DividerWidget(),
                // Points Tracker
                TextWidget(
                  text: 'Points Tracker',
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: 'Your Points',
                          fontSize: fontSize + 2,
                          color: textBlack,
                          isBold: true,
                          fontFamily: 'Bold',
                        ),
                        TextWidget(
                          text: '${userPoints} Points',
                          fontSize: fontSize + 2,
                          color: sunshineYellow,
                          isBold: true,
                          fontFamily: 'Bold',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                DividerWidget(),
                // Activity/Reservations Toggle
                TextWidget(
                  text: 'Your History',
                  fontSize: 20,
                  color: textBlack,
                  isBold: true,
                  fontFamily: 'Bold',
                  letterSpacing: 1.2,
                ),
                const SizedBox(height: 12),
                // Toggle buttons
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: cloudWhite,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showActivity = true;
                            });
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: _showActivity
                                  ? bayanihanBlue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: TextWidget(
                                text: 'Activity',
                                fontSize: 14,
                                color: _showActivity ? plainWhite : textBlack,
                                isBold: true,
                                fontFamily: 'Bold',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showActivity = false;
                            });
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: !_showActivity
                                  ? bayanihanBlue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: TextWidget(
                                text: 'Reservations',
                                fontSize: 14,
                                color: !_showActivity ? plainWhite : textBlack,
                                isBold: true,
                                fontFamily: 'Bold',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Content based on selected tab
                if (_showActivity) ...[
                  // Activity Section
                  TextWidget(
                    text: 'Activity',
                    fontSize: 18,
                    color: textBlack,
                    isBold: true,
                    fontFamily: 'Bold',
                    letterSpacing: 1.2,
                  ),
                  const SizedBox(height: 12),
                  // Status Filter Chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _statusFilters.map((status) {
                        final isSelected = _selectedStatus == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: TextWidget(
                              text: status,
                              fontSize: 12,
                              color: isSelected ? plainWhite : textBlack,
                              fontFamily: 'Regular',
                            ),
                            selected: isSelected,
                            selectedColor: bayanihanBlue,
                            backgroundColor: cloudWhite,
                            onSelected: (selected) {
                              setState(() {
                                _selectedStatus = status;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? bayanihanBlue : ashGray,
                                width: isSelected ? 1 : 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('orders')
                        .where('userId',
                            isEqualTo: box.read('userData')?['email'] ??
                                box.read('user')?['email'])
                        .orderBy('timestamp', descending: true)
                        .limit(10)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final orders = snapshot.data!.docs;

                      // Filter orders based on selected status
                      final filteredOrders = _selectedStatus == 'All'
                          ? orders
                          : orders.where((order) {
                              final orderData =
                                  order.data() as Map<String, dynamic>;
                              final status = orderData['status'] ?? 'Pending';
                              return status.toLowerCase() ==
                                  _selectedStatus.toLowerCase();
                            }).toList();

                      if (filteredOrders.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 60,
                                color: charcoalGray,
                              ),
                              const SizedBox(height: 16),
                              TextWidget(
                                text: 'No orders found',
                                fontSize: fontSize + 2,
                                color: charcoalGray,
                                fontFamily: 'Regular',
                              ),
                              const SizedBox(height: 8),
                              TextWidget(
                                text: _selectedStatus == 'All'
                                    ? 'Your activity will appear here'
                                    : 'No orders with status: $_selectedStatus',
                                fontSize: fontSize - 1,
                                color: charcoalGray,
                                fontFamily: 'Regular',
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final orderData = filteredOrders[index].data()
                              as Map<String, dynamic>;
                          // Try different possible field names for cart items
                          List<Map<String, dynamic>> cartItems = [];
                          if (orderData['cartItems'] != null) {
                            cartItems = List<Map<String, dynamic>>.from(
                                orderData['cartItems']);
                          } else if (orderData['items'] != null) {
                            cartItems = List<Map<String, dynamic>>.from(
                                orderData['items']);
                          } else if (orderData['products'] != null) {
                            cartItems = List<Map<String, dynamic>>.from(
                                orderData['products']);
                          }
                          final orderId = filteredOrders[index].id;
                          final timestamp =
                              orderData['timestamp'] as Timestamp?;
                          final status = orderData['status'] ?? 'Pending';
                          final total = orderData['total'] ?? 0.0;

                          final box = GetStorage();
                          final lastOpenedTimestamp =
                              box.read('lastOpenedTimestamp') as Timestamp?;

                          if (widget.isAccountTabSelected &&
                              index == 0 &&
                              status == 'Completed' &&
                              !_processedOrderIds.contains(orderId) &&
                              (lastOpenedTimestamp == null ||
                                  (timestamp != null &&
                                      timestamp
                                          .toDate()
                                          .isAfter(lastOpenedTimestamp.toDate())))) {
                            _processedOrderIds.add(orderId);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => OrderDetailsScreen(
                                      orderData: orderData,
                                      orderId: orderId,
                                    ),
                                  ),
                                );
                              }
                            });
                          }

                          final branch =
                              orderData['branch'] ?? 'Unknown Branch';
                          final type = orderData['type'] ?? '';

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsScreen(
                                    orderData: orderData,
                                    orderId: orderId,
                                  ),
                                ),
                              );
                            },
                            child: Card(
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Order header
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextWidget(
                                          text:
                                              'Order #${orderId.substring(0, 8)}',
                                          fontSize: fontSize + 1,
                                          color: textBlack,
                                          isBold: true,
                                          fontFamily: 'Bold',
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(status)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color:
                                                      _getStatusColor(status),
                                                  width: 1,
                                                ),
                                              ),
                                              child: TextWidget(
                                                text: status,
                                                fontSize: fontSize - 2,
                                                color: _getStatusColor(status),
                                                isBold: true,
                                                fontFamily: 'Bold',
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 14,
                                              color: ashGray,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Order details
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 16,
                                          color: charcoalGray,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: TextWidget(
                                            text: '$branch',
                                            fontSize: fontSize - 1,
                                            color: charcoalGray,
                                            fontFamily: 'Regular',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_outlined,
                                          size: 16,
                                          color: charcoalGray,
                                        ),
                                        const SizedBox(width: 4),
                                        TextWidget(
                                          text: timestamp != null
                                              ? _formatDate(timestamp)
                                              : 'Unknown date',
                                          fontSize: fontSize - 1,
                                          color: charcoalGray,
                                          fontFamily: 'Regular',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Items list
                                    ...cartItems
                                        .map((item) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: bayanihanBlue
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        _getCategoryIcon(
                                                            item['category']),
                                                        size: 16,
                                                        color: bayanihanBlue,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: TextWidget(
                                                      text:
                                                          '${item['name']} x${item['quantity']}',
                                                      fontSize: fontSize - 1,
                                                      color: textBlack,
                                                      fontFamily: 'Regular',
                                                    ),
                                                  ),
                                                  TextWidget(
                                                    text:
                                                        '₱${(item['price'] * item['quantity']).toStringAsFixed(0)}',
                                                    fontSize: fontSize - 1,
                                                    color: sunshineYellow,
                                                    isBold: true,
                                                    fontFamily: 'Bold',
                                                  ),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                    const SizedBox(height: 8),
                                    // Total
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextWidget(
                                          text: 'Total',
                                          fontSize: fontSize + 1,
                                          color: textBlack,
                                          isBold: true,
                                          fontFamily: 'Bold',
                                        ),
                                        TextWidget(
                                          text: '₱${total.toStringAsFixed(0)}',
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
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  DividerWidget(),
                ] else ...[
                  // Reservations Section
                  TextWidget(
                    text: 'Your Reservations',
                    fontSize: 18,
                    color: textBlack,
                    isBold: true,
                    fontFamily: 'Bold',
                    letterSpacing: 1.2,
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('reservations')
                        .where('userEmail',
                            isEqualTo: box.read('userData')?['email'] ??
                                box.read('user')?['email'])
                        .orderBy('createdAt', descending: true)
                        .limit(10)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final reservations = snapshot.data!.docs;

                      if (reservations.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_busy_outlined,
                                size: 60,
                                color: charcoalGray,
                              ),
                              const SizedBox(height: 16),
                              TextWidget(
                                text: 'No reservations found',
                                fontSize: fontSize + 2,
                                color: charcoalGray,
                                fontFamily: 'Regular',
                              ),
                              const SizedBox(height: 8),
                              TextWidget(
                                text:
                                    'Your table reservations will appear here',
                                fontSize: fontSize - 1,
                                color: charcoalGray,
                                fontFamily: 'Regular',
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                          final reservationData = reservations[index].data()
                              as Map<String, dynamic>;
                          final reservationId = reservations[index].id;
                          final createdAt =
                              reservationData['createdAt'] as Timestamp?;
                          final status =
                              reservationData['status'] ?? 'confirmed';
                          final tableName =
                              reservationData['tableName'] ?? 'Unknown Table';
                          final tableCapacity =
                              reservationData['tableCapacity'] ?? 0;
                          final date = reservationData['date'] ?? '';
                          final time = reservationData['time'] ?? '';
                          final guests = reservationData['guests'] ?? 1;
                          final branch =
                              reservationData['branch'] ?? 'Unknown Branch';

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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Reservation header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextWidget(
                                        text: tableName,
                                        fontSize: fontSize + 1,
                                        color: textBlack,
                                        isBold: true,
                                        fontFamily: 'Bold',
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getReservationStatusColor(
                                                      status)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    _getReservationStatusColor(
                                                        status),
                                                width: 1,
                                              ),
                                            ),
                                            child: TextWidget(
                                              text: status.toUpperCase(),
                                              fontSize: fontSize - 2,
                                              color: _getReservationStatusColor(
                                                  status),
                                              isBold: true,
                                              fontFamily: 'Bold',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Reservation details
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: charcoalGray,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: TextWidget(
                                          text: branch,
                                          fontSize: fontSize - 1,
                                          color: charcoalGray,
                                          fontFamily: 'Regular',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: charcoalGray,
                                      ),
                                      const SizedBox(width: 4),
                                      TextWidget(
                                        text: date,
                                        fontSize: fontSize - 1,
                                        color: charcoalGray,
                                        fontFamily: 'Regular',
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.access_time_outlined,
                                        size: 16,
                                        color: charcoalGray,
                                      ),
                                      const SizedBox(width: 4),
                                      TextWidget(
                                        text: time,
                                        fontSize: fontSize - 1,
                                        color: charcoalGray,
                                        fontFamily: 'Regular',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.people_outline,
                                        size: 16,
                                        color: charcoalGray,
                                      ),
                                      const SizedBox(width: 4),
                                      TextWidget(
                                        text:
                                            '$guests Guest${guests > 1 ? 's' : ''}',
                                        fontSize: fontSize - 1,
                                        color: charcoalGray,
                                        fontFamily: 'Regular',
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.table_restaurant_outlined,
                                        size: 16,
                                        color: charcoalGray,
                                      ),
                                      const SizedBox(width: 4),
                                      TextWidget(
                                        text: 'Capacity: $tableCapacity',
                                        fontSize: fontSize - 1,
                                        color: charcoalGray,
                                        fontFamily: 'Regular',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Created at
                                  if (createdAt != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: charcoalGray,
                                        ),
                                        const SizedBox(width: 4),
                                        TextWidget(
                                          text:
                                              'Booked on ${_formatDate(createdAt)}',
                                          fontSize: fontSize - 2,
                                          color: charcoalGray,
                                          fontFamily: 'Regular',
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 8),
                                  // Cancel button for confirmed reservations
                                  if (status == 'confirmed')
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            try {
                                              await _firestore
                                                  .collection('reservations')
                                                  .doc(reservationId)
                                                  .update({
                                                'status': 'cancelled',
                                                'cancelledAt': FieldValue
                                                    .serverTimestamp(),
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: TextWidget(
                                                    text:
                                                        'Reservation cancelled successfully',
                                                    fontSize: 14,
                                                    color: plainWhite,
                                                    fontFamily: 'Regular',
                                                  ),
                                                  backgroundColor:
                                                      bayanihanBlue,
                                                  duration: const Duration(
                                                      seconds: 2),
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: TextWidget(
                                                    text:
                                                        'Failed to cancel reservation',
                                                    fontSize: 14,
                                                    color: plainWhite,
                                                    fontFamily: 'Regular',
                                                  ),
                                                  backgroundColor: festiveRed,
                                                  duration: const Duration(
                                                      seconds: 2),
                                                ),
                                              );
                                            }
                                          },
                                          child: TextWidget(
                                            text: 'Cancel Reservation',
                                            fontSize: fontSize - 1,
                                            color: festiveRed,
                                            fontFamily: 'Bold',
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  DividerWidget(),
                ],
                // FAQ Button
                Center(
                  child: ButtonWidget(
                    label: 'Chat with Bot',
                    onPressed: () {
                      Get.to(ChatFaqSupportScreen(),
                          transition: Transition.circularReveal);
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
        );
      },
    );
  }

  Color _getReservationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return palmGreen; // Green
      case 'checked_in':
        return bayanihanBlue; // Blue
      case 'completed':
        return Colors.purple; // Purple
      case 'cancelled':
        return festiveRed; // Red
      default:
        return textBlack; // Black
    }
  }
}

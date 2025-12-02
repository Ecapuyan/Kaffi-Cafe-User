import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage = GetStorage();

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userEmail = _storage.read('user')?['email'];
      // Fetch orders from Firestore
      final ordersQuery = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userEmail)
          .orderBy('timestamp', descending: true)
          .get();

      // Convert orders to notifications
      final List<Map<String, dynamic>> notifications = [];

      for (var doc in ordersQuery.docs) {
        final orderData = doc.data();
        final orderId = orderData['orderId'] ?? doc.id;
        final status = orderData['status'] ?? 'Pending';
        final timestamp = orderData['timestamp'] as Timestamp?;
        final paymentMethod = orderData['paymentMethod'] ?? 'Unknown';
        final total = orderData['total'] ?? 0.0;
        final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);

        // Calculate subtotal
        double subtotal = 0.0;
        for (var item in items) {
          subtotal += (item['price'] ?? 0.0) * (item['quantity'] ?? 1);
        }

        // Calculate tax (assuming 12% tax)
        final tax = subtotal * 0.12;

        // Format timestamp
        String formattedTimestamp = 'Just now';
        if (timestamp != null) {
          final date = timestamp.toDate();
          final now = DateTime.now();
          final difference = now.difference(date);

          if (difference.inDays > 0) {
            formattedTimestamp =
                '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
          } else if (difference.inHours > 0) {
            formattedTimestamp =
                '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
          } else if (difference.inMinutes > 0) {
            formattedTimestamp =
                '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
          }
        }

        // Create order status notification
        notifications.add({
          'id': '${doc.id}_status',
          'title': 'Order $status',
          'message': 'Your order $orderId has been $status',
          'type': 'order_status',
          'timestamp': formattedTimestamp,
          'orderDetails': {
            'orderId': orderId,
            'date': timestamp != null
                ? _formatDate(timestamp.toDate())
                : 'Unknown date',
            'items': items,
            'subtotal': subtotal,
            'tax': tax,
            'total': total,
            'paymentMethod': paymentMethod,
            'status': status,
          }
        });

        // Create payment notification if applicable
        if (paymentMethod != 'Cash' && status != 'Pending') {
          // Get fresh read notifications list for payment notification
          List readNotifications =
              _storage.read('readNotifications_$userEmail') ?? [];

          notifications.add({
            'id': '${doc.id}_payment',
            'title':
                'Payment ${status == 'Refunded' ? 'Refunded' : 'Successful'}',
            'message': status == 'Refunded'
                ? 'Your refund of ₱${total.toStringAsFixed(2)} has been processed'
                : 'Your payment of ₱${total.toStringAsFixed(2)} has been processed',
            'type': 'transaction',
            'timestamp': formattedTimestamp,
            'orderDetails': {
              'orderId': orderId,
              'date': timestamp != null
                  ? _formatDate(timestamp.toDate())
                  : 'Unknown date',
              'items': items,
              'subtotal': subtotal,
              'tax': tax,
              'total': total,
              'paymentMethod': paymentMethod,
              'status': status == 'Refunded' ? 'Refunded' : 'Paid',
              'refundAmount': status == 'Refunded' ? total : null,
              'refundReason': status == 'Refunded' ? 'Order refund' : null,
            }
          });
        }
      }

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notifications: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _markAsRead(String id) {
    // Get the list of read notifications from storage
    final userEmail = _storage.read('user')?['email'];
    List readNotifications =
        _storage.read('readNotifications_$userEmail') ?? [];

    // Add the notification ID to the list if not already present
    if (!readNotifications.contains(id)) {
      readNotifications.add(id);
      // Save the updated list to storage
      _storage.write('readNotifications_$userEmail', readNotifications);
    }

    // Update the UI by calling setState
    setState(() {});
  }

  void _markAllAsRead() {
    // Get the list of read notifications from storage
    final userEmail = _storage.read('user')?['email'];
    List readNotifications =
        _storage.read('readNotifications_$userEmail') ?? [];

    // Add all notification IDs to the list
    for (var notification in _notifications) {
      if (!readNotifications.contains(notification['id'])) {
        readNotifications.add(notification['id']);
      }
    }

    // Save the updated list to storage
    _storage.write('readNotifications_$userEmail', readNotifications);

    // Update the UI by calling setState
    setState(() {});
  }

  void _showOrderDetails(Map<String, dynamic> orderDetails) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Order Receipt',
                      fontSize: 20,
                      fontFamily: 'Bold',
                      color: textBlack,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Order ID:',
                      fontSize: 14,
                      color: textBlack,
                    ),
                    TextWidget(
                      text: orderDetails['orderId'],
                      fontSize: 14,
                      fontFamily: 'Bold',
                      color: textBlack,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Date:',
                      fontSize: 14,
                      color: textBlack,
                    ),
                    TextWidget(
                      text: orderDetails['date'],
                      fontSize: 14,
                      color: textBlack,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Status:',
                      fontSize: 14,
                      color: textBlack,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(orderDetails['status']),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextWidget(
                        text: orderDetails['status'],
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'Bold',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextWidget(
                  text: 'Items:',
                  fontSize: 16,
                  fontFamily: 'Bold',
                  color: textBlack,
                ),
                const SizedBox(height: 8),
                ...List.generate(orderDetails['items'].length, (index) {
                  final item = orderDetails['items'][index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextWidget(
                            text: '${item['quantity']}x ${item['name']}',
                            fontSize: 14,
                            color: textBlack,
                          ),
                        ),
                        TextWidget(
                          text: '₱${item['price'].toStringAsFixed(2)}',
                          fontSize: 14,
                          color: textBlack,
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Subtotal:',
                      fontSize: 14,
                      color: textBlack,
                    ),
                    TextWidget(
                      text: '₱${orderDetails['subtotal'].toStringAsFixed(2)}',
                      fontSize: 14,
                      color: textBlack,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Tax:',
                      fontSize: 14,
                      color: textBlack,
                    ),
                    TextWidget(
                      text: '₱${orderDetails['tax'].toStringAsFixed(2)}',
                      fontSize: 14,
                      color: textBlack,
                    ),
                  ],
                ),
                if (orderDetails['refundAmount'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: 'Refund:',
                        fontSize: 14,
                        color: Colors.red,
                      ),
                      TextWidget(
                        text:
                            '-₱${orderDetails['refundAmount'].toStringAsFixed(2)}',
                        fontSize: 14,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Total:',
                      fontSize: 16,
                      fontFamily: 'Bold',
                      color: textBlack,
                    ),
                    TextWidget(
                      text: '₱${orderDetails['total'].toStringAsFixed(2)}',
                      fontSize: 16,
                      fontFamily: 'Bold',
                      color: textBlack,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: 'Payment Method:',
                      fontSize: 14,
                      color: textBlack,
                    ),
                    TextWidget(
                      text: orderDetails['paymentMethod'],
                      fontSize: 14,
                      color: textBlack,
                    ),
                  ],
                ),
                if (orderDetails['refundReason'] != null) ...[
                  const SizedBox(height: 16),
                  TextWidget(
                    text: 'Refund Reason:',
                    fontSize: 14,
                    fontFamily: 'Bold',
                    color: textBlack,
                  ),
                  const SizedBox(height: 4),
                  TextWidget(
                    text: orderDetails['refundReason'],
                    fontSize: 14,
                    color: textBlack,
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bayanihanBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: TextWidget(
                      text: 'Close',
                      fontSize: 16,
                      fontFamily: 'Bold',
                      color: Colors.white,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
      case 'Paid':
        return Colors.green;
      case 'Ready for Pickup':
        return Colors.blue;
      case 'Refunded':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: bayanihanBlue,
        automaticallyImplyLeading: true,
        title: TextWidget(
          text: "Notifications",
          fontSize: 24,
          fontFamily: 'Bold',
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      TextWidget(
                        text: "No notifications",
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      TextWidget(
                        text: "Your order updates will appear here",
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final userEmail = _storage.read('user')?['email'];
                      List readNotifications =
                          _storage.read('readNotifications_$userEmail') ?? [];
                      final isRead =
                          readNotifications.contains(notification['id']);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: notification['type'] == 'order_status'
                                  ? bayanihanBlue.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              notification['type'] == 'order_status'
                                  ? Icons.receipt_long
                                  : Icons.payments,
                              color: notification['type'] == 'order_status'
                                  ? bayanihanBlue
                                  : Colors.green,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: TextWidget(
                                  text: notification['title'],
                                  fontSize: 16,
                                  fontFamily: 'Bold',
                                  color: textBlack,
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              TextWidget(
                                text: notification['message'],
                                fontSize: 14,
                                color: textBlack,
                              ),
                              const SizedBox(height: 8),
                              TextWidget(
                                text: notification['timestamp'],
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          onTap: () {
                            _markAsRead(notification['id']);
                            _showOrderDetails(notification['orderDetails']);
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

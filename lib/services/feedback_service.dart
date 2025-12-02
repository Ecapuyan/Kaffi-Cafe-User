import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addFeedback({
    required double rating,
    required String comment,
    required String userId,
    required String orderId,
    required String branch,
    required String username,
    required List<Map<String, dynamic>> orderItems,
  }) async {
    try {
      await _firestore.collection('feedback').add({
        'rating': rating,
        'comment': comment,
        'userId': userId,
        'orderId': orderId,
        'branch': branch,
        'username': username,
        'orderItems': orderItems,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // You might want to log this error or handle it in a way that makes sense for your app.
      print('Error adding feedback: $e');
      rethrow;
    }
  }

  Future<bool> hasFeedback(String orderId) async {
    try {
      final querySnapshot = await _firestore
          .collection('feedback')
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking for feedback: $e');
      return false;
    }
  }
}

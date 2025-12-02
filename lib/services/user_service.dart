import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create new user document
  Future<void> createUser({
    required String name,
    required String email,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'points': 0,
        'totalOrders': 0,
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  // Update last login
  Future<void> updateLastLogin() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get user data
  Stream<DocumentSnapshot> getUserData() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore.collection('users').doc(user.uid).snapshots();
    }
    throw Exception('User not authenticated');
  }

  // Update user points
  Future<void> updatePoints(int points) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'points': FieldValue.increment(points),
      });
    }
  }

  // Update total orders
  Future<void> incrementTotalOrders() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'totalOrders': FieldValue.increment(1),
      });
    }
  }
} 
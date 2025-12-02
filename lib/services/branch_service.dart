import 'package:cloud_firestore/cloud_firestore.dart';

class BranchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all branches
  Future<QuerySnapshot> getBranches() async {
    return await _firestore.collection('branches').get();
  }

  // Get a specific branch by name
  Future<DocumentSnapshot?> getBranchByName(String name) async {
    try {
      final querySnapshot = await _firestore
          .collection('branches')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null;
    } catch (e) {
      print('Error getting branch: $e');
      return null;
    }
  }

  // Check if a branch is online
  Future<bool> isBranchOnline(String name) async {
    try {
      final branchDoc = await getBranchByName(name);
      if (branchDoc != null && branchDoc.exists) {
        final data = branchDoc.data() as Map<String, dynamic>;
        return data['isOnline'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking branch online status: $e');
      return false;
    }
  }

  // Stream to listen for branch status changes
  Stream<bool> getBranchOnlineStatusStream(String name) {
    return _firestore
        .collection('branches')
        .where('name', isEqualTo: name)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return data['isOnline'] ?? false;
      }
      return false;
    });
  }
}

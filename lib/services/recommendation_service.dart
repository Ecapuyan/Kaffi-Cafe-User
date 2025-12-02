import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Define drink categories
  final List<String> drinkCategories = [
    'Coffee',
    'Non-Coffee Drinks',
    'Frappes',
    'Cloud Series',
    'Milk Tea',
    'Fruit Tea'
  ];

  // Define food categories
  final List<String> foodCategories = [
    'Sandwiches',
    'Croffle',
    'Pasta',
    'Pastries',
    'Add-ons'
  ];

  // Helpers: Check category type
  bool _isDrinkCategory(String category) => drinkCategories.contains(category);
  bool _isFoodCategory(String category) => foodCategories.contains(category);

  // Get category of a product from Firestore
  Future<String?> _getProductCategory(String productName) async {
    try {
      final productSnapshot = await _firestore
          .collection('products')
          .where('name', isEqualTo: productName)
          .limit(1)
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        return productSnapshot.docs.first.data()['category'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting product category: $e');
      return null;
    }
  }

  // FIXED: Now productName is used correctly
  Future<List<Map<String, dynamic>>> getYouMightAlsoLike(
      String productName,
      {int k = 3,
      String? branchName}) async {
    try {
      // Query orders
      Query<Map<String, dynamic>> ordersQuery = _firestore.collection('orders');

      if (branchName != null) {
        ordersQuery = ordersQuery.where('branch', isEqualTo: branchName);
      }

      final ordersSnapshot = await ordersQuery.where('status',
          whereIn: ['Completed', 'Pending', 'Preparing']).get();

      if (ordersSnapshot.docs.isEmpty) return [];

      // USER-ITEM MATRIX
      Map<String, Map<String, int>> userItemMatrix = {};
      Set<String> allProducts = {};

      for (var orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data();
        final userId = orderData['userId'] as String;
        final items = orderData['items'] as List<dynamic>;

        userItemMatrix.putIfAbsent(userId, () => {});

        for (var item in items) {
          final itemName = item['name'] as String;
          allProducts.add(itemName);
          userItemMatrix[userId]![itemName] = 1;
        }
      }

      // Fill missing values = 0
      for (var user in userItemMatrix.keys) {
        for (var p in allProducts) {
          userItemMatrix[user]!.putIfAbsent(p, () => 0);
        }
      }

      // FIXED: Build target vector using productName
      Map<String, int> targetVector = {};
      for (var user in userItemMatrix.keys) {
        targetVector[user] = userItemMatrix[user]![productName] ?? 0;
      }

      // Compute similarity
      Map<String, double> productSimilarities = {};

      for (var p in allProducts) {
        if (p == productName) continue;

        Map<String, int> productVec = {};
        for (var user in userItemMatrix.keys) {
          productVec[user] = userItemMatrix[user]![p] ?? 0;
        }

        double similarity =
            _calculateCosineSimilarity(targetVector, productVec);

        productSimilarities[p] = similarity;
      }

      // Sort similarities
      List<MapEntry<String, double>> sortedSimilarities =
          productSimilarities.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

      List<Map<String, dynamic>> allRecommendations = [];

      // Get top products (raw)
      for (int i = 0; i < min(k * 3, sortedSimilarities.length); i++) {
        final recommendedName = sortedSimilarities[i].key;
        final similarity = sortedSimilarities[i].value;

        if (similarity < 0.1) continue; // MORE REALISTIC

        final productSnapshot = await _firestore
            .collection('products')
            .where('name', isEqualTo: recommendedName)
            .limit(1)
            .get();

        if (productSnapshot.docs.isNotEmpty) {
          final data = productSnapshot.docs.first.data();
          data['similarity'] = similarity;
          allRecommendations.add(data);
        }
      }

      // Filter complementary category
      final productCategory = await _getProductCategory(productName);
      List<Map<String, dynamic>> finalResults = [];

      if (productCategory != null) {
        if (_isDrinkCategory(productCategory)) {
          // recommend food
          for (var rec in allRecommendations) {
            if (_isFoodCategory(rec['category'])) {
              finalResults.add(rec);
              if (finalResults.length == k) break;
            }
          }
        } else if (_isFoodCategory(productCategory)) {
          // recommend drinks
          for (var rec in allRecommendations) {
            if (_isDrinkCategory(rec['category'])) {
              finalResults.add(rec);
              if (finalResults.length == k) break;
            }
          }
        }
      }

      finalResults.sort((a, b) => (b['similarity']).compareTo(a['similarity']));

      return finalResults;
    } catch (e) {
      print('Recommendation Error: $e');
      return [];
    }
  }

  // Cosine similarity
  double _calculateCosineSimilarity(Map<String, int> a, Map<String, int> b) {
    double dot = 0, magA = 0, magB = 0;

    for (var user in a.keys) {
      dot += a[user]! * b[user]!;
      magA += pow(a[user]!, 2);
    }
    for (var v in b.values) {
      magB += pow(v, 2);
    }

    if (magA == 0 || magB == 0) return 0;

    return dot / (sqrt(magA) * sqrt(magB));
  }
}

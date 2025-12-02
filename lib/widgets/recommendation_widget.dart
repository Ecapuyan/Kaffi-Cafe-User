import 'package:flutter/material.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';
import 'package:kaffi_cafe/screens/product_details_screen.dart';
import 'package:kaffi_cafe/services/recommendation_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationWidget extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final void Function(Map<String, dynamic> item, int quantity) addToCart;
  final String? selectedBranch;
  final String? selectedType;

  const RecommendationWidget({
    Key? key,
    required this.cartItems,
    required this.addToCart,
    this.selectedBranch,
    this.selectedType,
  }) : super(key: key);

  @override
  State<RecommendationWidget> createState() => _RecommendationWidgetState();
}

class _RecommendationWidgetState extends State<RecommendationWidget> {
  final RecommendationService _recommendationService = RecommendationService();
  final GetStorage _storage = GetStorage();
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      List<Map<String, dynamic>> recommendations = [];

      // If cart has items, get recommendations based on the first item
      if (widget.cartItems.isNotEmpty) {
        final firstItemName = widget.cartItems.first['name'] as String;
        recommendations = await _recommendationService
            .getYouMightAlsoLike(firstItemName);
      }

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      print('Error loading recommendations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    // Always show the widget, even if no recommendations (show popular products)
    return _buildRecommendationWidget();
  }

  Widget _buildLoadingWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'You Might Also Like',
            fontSize: 18,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 10),
          Container(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(
                color: bayanihanBlue,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'You Might Also Like',
            fontSize: 18,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 10),
          Container(
            height: 100,
            child: Center(
              child: TextWidget(
                text: 'Unable to load recommendations',
                fontSize: 14,
                color: charcoalGray,
                fontFamily: 'Regular',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF5FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'You Might Also Like',
            fontSize: 18,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 12),
          if (_recommendations.isEmpty)
            TextWidget(
              text:
                  'No recommendations available yet. Start ordering to see suggestions!',
              fontSize: 14,
              color: charcoalGray,
              fontFamily: 'Regular',
            )
          else
            Column(
              children: _recommendations
                  .map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildRecommendationCard(product),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> product) {
    final bool canAdd = _storage.read('selectedBranch') != null &&
        _storage.read('selectedType') != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: plainWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: ashGray.withOpacity(0.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product['image'] != null &&
                      product['image'].toString().isNotEmpty
                  ? Image.network(
                      product['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.local_cafe,
                          color: bayanihanBlue.withOpacity(0.6),
                          size: 24,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.local_cafe,
                        color: bayanihanBlue.withOpacity(0.6),
                        size: 24,
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
                  text: product['name'],
                  fontSize: 14,
                  color: textBlack,
                  isBold: true,
                  fontFamily: 'Bold',
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                TextWidget(
                  text:
                      'P ${(product['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                  fontSize: 13,
                  color: bayanihanBlue,
                  fontFamily: 'Bold',
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: !canAdd
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          product: product,
                          addToCart: widget.addToCart,
                        ),
                      ),
                    );
                  },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: canAdd ? bayanihanBlue : ashGray.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

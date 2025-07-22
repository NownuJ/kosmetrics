import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'product_detail_page.dart';

class RankingListPage extends StatefulWidget {
  final String? selectedAge;
  final String? selectedSkinType;


  const RankingListPage({this.selectedAge, this.selectedSkinType, super.key});

  @override
  _RankingListPageState createState() => _RankingListPageState();
}

class _RankingListPageState extends State<RankingListPage> {
  List<Product> _rankedProducts = [];
  bool _isLoading = true;

  final List<String> ageOptions = ['20s', '30s', '40s', '50s', '60s+'];
  final List<String> skinTypeOptions = ['Dry', 'Oily', 'Combination', 'Normal', 'Dry & Oily'];

  @override
  void initState() {
    super.initState();
    _loadRankedProducts();
  }

  Future<void> _loadRankedProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();

    final products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

    final int? ageIndex = widget.selectedAge != null ? ageOptions.indexOf(widget.selectedAge!) : null;
    final int? skinIndex = widget.selectedSkinType != null ? skinTypeOptions.indexOf(widget.selectedSkinType!) : null;

    final scoredProducts = products.map((product) {
      double? ageScore;
      if (ageIndex != null &&
          ageIndex >= 0 &&
          ageIndex < product.ageRatings.length &&
          product.ageRatings[ageIndex]['avg'] != null) {
        ageScore = (product.ageRatings[ageIndex]['avg'] as num).toDouble();
      }

      double? skinScore;
      if (skinIndex != null &&
          skinIndex >= 0 &&
          skinIndex < product.skinTypeRatings.length &&
          product.skinTypeRatings[skinIndex]['avg'] != null) {
        skinScore = (product.skinTypeRatings[skinIndex]['avg'] as num).toDouble();
      }

      double finalScore;
      if (ageScore != null && skinScore != null) {
        finalScore = (ageScore + skinScore) / 2.0;
      } else if (ageScore != null) {
        finalScore = ageScore;
      } else if (skinScore != null) {
        finalScore = skinScore;
      } else {
        finalScore = 0.0;
      }

      return {
        'product': product,
        'score': finalScore,
      };
    }).toList();

    scoredProducts.sort((a, b) {
      final aScore = (a['score'] ?? 0.0) as double;
      final bScore = (b['score'] ?? 0.0) as double;
      return bScore.compareTo(aScore);
    });

    setState(() {
      _rankedProducts = scoredProducts.map((e) => e['product'] as Product).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ageLabel = widget.selectedAge != null ? 'Age: ${widget.selectedAge}' : '';
    final skinLabel = widget.selectedSkinType != null ? 'Skin Type: ${widget.selectedSkinType}' : '';
    final title = [ageLabel, skinLabel].where((s) => s.isNotEmpty).join(' | ');

    return Scaffold(
      appBar: AppBar(
        title: Text(title.isEmpty ? 'Ranking' : title),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _rankedProducts.isEmpty
          ? Center(child: Text('No matching products found.'))
          : ListView.builder(
        itemCount: _rankedProducts.length,
        itemBuilder: (context, index) {
          final product = _rankedProducts[index];
          return ListTile(
            leading: Image.network(
              product.imageUrl,
              width: 50,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
            ),
            title: Text(product.name),
            subtitle: Text(product.brand),
            trailing: Text('#${index + 1}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

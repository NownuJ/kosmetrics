import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'product_detail_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<String> categories = [
    'Ranking',
    'Toners',
    'Lotions',
    'Sunscreens',
    'Moisturisers',
    'Cleansers'
  ];

  String selectedCategory = 'Ranking';
  String? selectedAge;
  String? selectedSkinType;
  List<Product> rankedProducts = [];
  List<Product> categoryProducts = [];
  bool isRankingLoading = false;
  bool isCategoryLoading = false;

  final List<String> ageOptions = ['Clear Selection', '20s', '30s', '40s', '50s', '60s+'];
  final List<String> skinTypeOptions = ['Clear Selection', 'Dry', 'Oily', 'Combination', 'Normal', 'Dry & Oily'];

  @override
  void initState() {
    super.initState();
    _loadRankedProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(selectedCategory),
        bottom: selectedCategory == 'Ranking'
            ? PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async {
                  final selected = await showModalBottomSheet<String>(
                    context: context,
                    builder: (_) => _buildPicker(ageOptions),
                  );
                  if (selected != null) {
                    setState(() => selectedAge = selected == 'Clear Selection' ? null : selected);
                    _loadRankedProducts();
                  }
                },
                child: Text(selectedAge ?? "Age"),
              ),
              TextButton(
                onPressed: () async {
                  final selected = await showModalBottomSheet<String>(
                    context: context,
                    builder: (_) => _buildPicker(skinTypeOptions),
                  );
                  if (selected != null) {
                    setState(() => selectedSkinType = selected == 'Clear Selection' ? null : selected);
                    _loadRankedProducts();
                  }
                },
                child: Text(selectedSkinType ?? "Skin Type"),
              ),
            ],
          ),
        )
            : null,
      ),
      body: Row(
        children: [
          Container(
            width: 120,
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category),
                  selected: selectedCategory == category,
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                    if (category == 'Ranking') {
                      _loadRankedProducts();
                    } else {
                      _loadCategoryProducts(category);
                    }
                  },
                );
              },
            ),
          ),
          Expanded(
            child: selectedCategory == 'Ranking'
                ? isRankingLoading
                ? Center(child: CircularProgressIndicator())
                : rankedProducts.isEmpty
                ? Center(child: Text('Select Age or Skin Type to see rankings'))
                : _buildProductList(rankedProducts, true)
                : isCategoryLoading
                ? Center(child: CircularProgressIndicator())
                : _buildProductList(categoryProducts, false),
          ),
        ],
      ),
    );
  }

  Widget _buildPicker(List<String> options) {
    return ListView.builder(
      itemCount: options.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(options[i]),
        onTap: () => Navigator.pop(context, options[i]),
      ),
    );
  }

  Widget _buildProductList(List<Product> products, bool isRanked) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          leading: Image.network(
            product.imageUrl,
            width: 50,
            errorBuilder: (context, _, __) => Icon(Icons.image_not_supported),
          ),
          title: Text(product.name),
          subtitle: Text(product.brand),
          trailing: isRanked ? Text('#${index + 1}') : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadRankedProducts() async {
    setState(() => isRankingLoading = true);

    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    final products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

    final ageIndex = selectedAge != null ? ageOptions.indexOf(selectedAge!) - 1 : null;
    final skinIndex = selectedSkinType != null ? skinTypeOptions.indexOf(selectedSkinType!) - 1 : null;

    final scored = products.map((product) {
      double? ageScore, skinScore;

      if (ageIndex != null &&
          ageIndex >= 0 &&
          ageIndex < product.ageRatings.length &&
          product.ageRatings[ageIndex]['avg'] != null) {
        ageScore = (product.ageRatings[ageIndex]['avg'] as num).toDouble();
      }

      if (skinIndex != null &&
          skinIndex >= 0 &&
          skinIndex < product.skinTypeRatings.length &&
          product.skinTypeRatings[skinIndex]['avg'] != null) {
        skinScore = (product.skinTypeRatings[skinIndex]['avg'] as num).toDouble();
      }

      final score = ageScore != null || skinScore != null
          ? ageScore != null && skinScore != null
          ? (ageScore + skinScore) / 2
          : ageScore ?? skinScore!
          : product.rating;

      return {'product': product, 'score': score};
    }).toList();

    scored.sort((a, b) {
      final aScore = (a['score'] ?? 0.0) as double;
      final bScore = (b['score'] ?? 0.0) as double;
      return bScore.compareTo(aScore);
    });

    setState(() {
      rankedProducts = scored.map((e) => e['product'] as Product).toList();
      isRankingLoading = false;
    });
  }

  Future<void> _loadCategoryProducts(String category) async {
    setState(() => isCategoryLoading = true);

    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('Category', isEqualTo: category)
        .get();

    final products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

    setState(() {
      categoryProducts = products;
      isCategoryLoading = false;
    });
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'product_detail_page.dart';
import '../services/product_ranking_service.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<String> categories = [
    'Ranking', 'Toners', 'Lotions', 'Sunscreens', 'Moisturisers', 'Cleansers'
  ];

  final List<String> ageOptions = ['Clear Selection', '20s', '30s', '40s', '50s', '60s+'];
  final List<String> skinTypeOptions = ['Clear Selection', 'Dry', 'Oily', 'Combination', 'Normal', 'Dry & Oily'];

  String selectedCategory = 'Ranking';
  String? selectedAge;
  String? selectedSkinType;

  List<Product> displayedProducts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);

    QuerySnapshot snapshot;
    if (selectedCategory == 'Ranking') {
      snapshot = await FirebaseFirestore.instance.collection('products').get();
    } else {
      snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('Category', isEqualTo: selectedCategory)
          .get();
    }

    List<Product> products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

    int? ageIndex = selectedAge != null ? ageOptions.indexOf(selectedAge!) - 1 : null;
    int? skinIndex = selectedSkinType != null ? skinTypeOptions.indexOf(selectedSkinType!) - 1 : null;

    displayedProducts = ProductRankingService.rankProducts(
      products: products,
      ageIndex: ageIndex,
      skinTypeIndex: skinIndex,
    );

    setState(() => isLoading = false);
  }

  void _onFilterChanged({String? age, String? skinType}) {
    setState(() {
      selectedAge = age;
      selectedSkinType = skinType;
    });
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(selectedCategory),
        bottom: PreferredSize(
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
                    _onFilterChanged(age: selected == 'Clear Selection' ? null : selected, skinType: selectedSkinType);
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
                    _onFilterChanged(age: selectedAge, skinType: selected == 'Clear Selection' ? null : selected);
                  }
                },
                child: Text(selectedSkinType ?? "Skin Type"),
              ),
            ],
          ),
        ),
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
                    setState(() => selectedCategory = category);
                    _loadProducts();
                  },
                );
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildProductList(displayedProducts),
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

  Widget _buildProductList(List<Product> products) {
    return ListView.builder(
      key: ValueKey('${selectedCategory}-${selectedAge ?? ''}-${selectedSkinType ?? ''}'),
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
          trailing: Text('#${index + 1}'),
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
}

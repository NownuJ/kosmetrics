import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  final String category;

  ProductListPage({required this.category});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryProducts();
  }

  Future<void> _loadCategoryProducts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: widget.category)
        .get();
    final products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            leading: Image.network(product.imageUrl, width: 50, errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported)),
            title: Text(product.name),
            subtitle: Text(product.brand),
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
      ),
    );
  }
}

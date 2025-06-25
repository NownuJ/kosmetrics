// home_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('cosmetics').get();
    final products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    setState(() {
      _products = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Sunscreens')), //to be replaced with search bar
      body: _products.isEmpty // to be replaced by 3 ranking pages
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ListTile(
            leading: Image.network(product.imageUrl, width: 50),
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
      // bottomAppbar to be made (three icons)
    );
  }
}
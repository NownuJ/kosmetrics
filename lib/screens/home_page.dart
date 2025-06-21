// this is the home page of the app that displays
// 3 random top 3 products.
// also has search bars and stuff on the bottom

import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../misc/firestore_service.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    final products = await _firestoreService.fetchAllProducts();
    products.shuffle(); // for randomness
    setState(() {
      _products = products.take(6).toList(); // Take only a few for now
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Top Products')),
      body: ListView.builder(
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
    );
  }
}


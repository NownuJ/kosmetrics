import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'review_form.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Product product;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    _fetchUpdatedProduct();
  }

  Future<void> _fetchUpdatedProduct() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .get();

      setState(() {
        product = Product.fromFirestore(snapshot);
      });
    } catch (e) {
      print("Failed to fetch updated product: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print('product.id in detail page: ${product.id}');

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product.imageUrl,
                height: 200,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported, size: 100),
              ),
            ),
            SizedBox(height: 16),
            Text(
              product.brand,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              product.name,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 4),
                Text("${product.rating.toStringAsFixed(2)} / 5"),
              ],
            ),
            SizedBox(height: 16),
            _buildScoreRow("Hydration", product.hydration),
            _buildScoreRow("Oiliness", product.oiliness),
            _buildScoreRow("Irritation", product.irritation),
            _buildScoreRow("Stickiness", product.stickiness),
            SizedBox(height: 16),
            _buildIngredientSection("Low", product.lowIngredients),
            _buildIngredientSection("Medium", product.mediumIngredients),
            _buildIngredientSection("High", product.highIngredients),
            ReviewForm(product: product),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, double score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label)),
          Expanded(
            flex: 7,
            child: LinearProgressIndicator(
              value: score / 5,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blue,
              minHeight: 8,
            ),
          ),
          SizedBox(width: 8),
          Text(score.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _buildIngredientSection(String label, List<String> ingredients) {
    if (ingredients.isEmpty ||
        (ingredients.length == 1 && ingredients[0].toLowerCase() == 'null')) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        ...ingredients.map((i) => Text('- $i')),
        SizedBox(height: 8),
      ],
    );
  }
}

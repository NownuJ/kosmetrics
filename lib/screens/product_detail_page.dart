
// this is the page when user clicks on individual products for more info about them.

import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Replace with actual home route if using named routes
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Image.network(
                product.imageUrl,
                height: 200,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported, size: 100),
              ),
            ),
            SizedBox(height: 16),

            // Brand & Name
            Text(
              product.brand,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              product.name,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Rating
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 4),
                Text("${product.rating.toStringAsFixed(2)} / 5"),
              ],
            ),
            SizedBox(height: 16),

            // Scores
            _buildScoreRow("Hydration", product.hydration),
            _buildScoreRow("Oiliness", product.oiliness),
            _buildScoreRow("Irritation", product.irritation),
            _buildScoreRow("Stickiness", product.stickiness),
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
}
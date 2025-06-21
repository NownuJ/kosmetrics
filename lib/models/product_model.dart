import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final double rating;
  final double hydration;
  final double oiliness;
  final double irritation;
  final double stickiness;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.rating,
    required this.hydration,
    required this.oiliness,
    required this.irritation,
    required this.stickiness,
  });


  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      hydration: (data['hydration'] ?? 0).toDouble(),
      oiliness: (data['oiliness'] ?? 0).toDouble(),
      irritation: (data['irritation'] ?? 0).toDouble(),
      stickiness: (data['stickiness'] ?? 0).toDouble(),
    );
  }
}

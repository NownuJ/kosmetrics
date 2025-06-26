import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String name;
  final String brand;
  final String imageUrl;
  final String category;
  final double rating;
  final double hydration;
  final double oiliness;
  final double irritation;
  final double stickiness;

  final List<String> lowIngredients;
  final List<String> mediumIngredients;
  final List<String> highIngredients;

  Product({
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.hydration,
    required this.oiliness,
    required this.irritation,
    required this.stickiness,
    required this.lowIngredients,
    required this.mediumIngredients,
    required this.highIngredients,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    List<String> parseIngredients(String? raw) {
      if (raw == null || raw.trim().isEmpty || raw.trim().toLowerCase() == 'null') return [];
      return raw.split(',').map((e) => e.trim()).toList();
    }

    return Product(
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      hydration: (data['hydration'] ?? 0).toDouble(),
      oiliness: (data['oiliness'] ?? 0).toDouble(),
      irritation: (data['irritation'] ?? 0).toDouble(),
      stickiness: (data['stickiness'] ?? 0).toDouble(),
      lowIngredients: parseIngredients(data['low']),
      mediumIngredients: parseIngredients(data['medium']),
      highIngredients: parseIngredients(data['high']),
    );
  }
}


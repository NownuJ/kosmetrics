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

  final List<String> lowIngredients;
  final List<String> mediumIngredients;
  final List<String> highIngredients;

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
      id: doc.id,
      name: data['name'] ?? data['Product Name'] ?? '',
      brand: data['brand'] ?? data['Brand'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: _parseDouble(data['rating']),
      hydration: _parseDouble(data['Hydration']),
      oiliness: _parseDouble(data['Oiliness']),
      irritation: _parseDouble(data['Irritation']),
      stickiness: _parseDouble(data['Stickiness']),
      lowIngredients: parseIngredients(data['low']),
      mediumIngredients: parseIngredients(data['medium']),
      highIngredients: parseIngredients(data['high']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

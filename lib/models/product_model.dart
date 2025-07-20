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

  // These fields should be added if you're using them for ranking
  final List<dynamic> ageRatings;
  final List<dynamic> skinTypeRatings;

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
    required this.ageRatings,
    required this.skinTypeRatings,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    List<String> parseIngredients(dynamic raw) {
      if (raw == null) return [];
      if (raw is String) {
        if (raw.trim().isEmpty || raw.trim().toLowerCase() == 'null') return [];
        return raw.split(',').map((e) => e.trim()).toList();
      }
      return [];
    }

    List<Map<String, dynamic>> mapToRatingList(dynamic raw) {
      if (raw is Map) {
        return List.generate(5, (i) {
          final entry = raw[i.toString()];
          if (entry is Map) {
            return {
              'avg': (entry['avg'] as num?)?.toDouble() ?? 0.0,
              'count': (entry['count'] as num?)?.toInt() ?? 0,
            };
          }
          return {'avg': 0.0, 'count': 0};
        });
      }
      return List.generate(5, (_) => {'avg': 0.0, 'count': 0});
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
      ageRatings: mapToRatingList(data['ageRatings']),
      skinTypeRatings: mapToRatingList(data['skinTypeRatings']),
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
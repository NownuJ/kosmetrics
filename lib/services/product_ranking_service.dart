import '../models/product_model.dart';

class ProductRankingService {
  static List<Product> rankProducts({
    required List<Product> products,
    int? ageIndex,
    int? skinTypeIndex,
  }) {
    final scored = products.map((product) {
      return Product.rankWrap(product, ageIndex: ageIndex, skinTypeIndex: skinTypeIndex);
    }).toList();

    scored.sort((a, b) {
      final aScore = a['score'] as double;
      final bScore = b['score'] as double;
      return bScore.compareTo(aScore);
    });

    print('Ranking with ageIndex=$ageIndex, skinTypeIndex=$skinTypeIndex');

    return scored.map((e) => e['product'] as Product).toList();
  }
}

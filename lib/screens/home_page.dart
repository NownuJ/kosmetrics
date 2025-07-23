import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'product_detail_page.dart';
import 'ranking_list_page.dart';
import 'category_page.dart';
import 'my_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  final List<String> ageOptions = ['20s', '30s', '40s', '50s', '60s+'];
  final List<String> skinOptions = ['Dry', 'Oily', 'Combination', 'Normal', 'Dry & Oily'];
  final List<String> categoryOptions = ['Sunscreen', 'Toner', 'Lotion', 'Cleansing', 'Suncream'];

  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';

  final List<Map<String, String>> _finalCriteria = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _generateCriteriaAndLoad();
  }

  Future<void> _loadProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    final products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    setState(() {
      _allProducts = products;
      _filteredProducts = products;
    });
  }

  void _searchProducts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProducts = _allProducts.where((p) {
        return p.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _generateCriteriaAndLoad() async {
    final all = [
      ...categoryOptions.map((c) => {'type': 'category', 'value': c}),
      ...ageOptions.map((a) => {'type': 'age', 'value': a}),
      ...skinOptions.map((s) => {'type': 'skinType', 'value': s}),
    ];
    all.shuffle();

    List<Map<String, String>> selected = [];

    for (final crit in all) {
      final products = await getTopProducts(type: crit['type']!, value: crit['value']!);
      if (products.length >= 3) {
        selected.add(crit);
      }
      if (selected.length == 3) break;
    }


    setState(() {
      _finalCriteria.clear();
      _finalCriteria.addAll(selected);
      _isLoading = false;
    });
  }

  Future<List<Product>> getTopProducts({required String type, required String value}) async {
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    final products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

    List<Map<String, dynamic>> scored = [];

    for (var p in products) {
      double? score;

      if (type == 'category') {
        if ((p.category == value) && p.rating != null) {
          score = p.rating!;
        }
      } else if (type == 'age') {
        final idx = ageOptions.indexOf(value);
        if (idx >= 0 && idx < p.ageRatings.length) {
          final data = p.ageRatings[idx];
          if (data['avg'] != null && (data['count'] ?? 0) > 0) {
            score = (data['avg'] as num).toDouble();
          }
        }
      } else if (type == 'skinType') {
        final idx = skinOptions.indexOf(value);
        if (idx >= 0 && idx < p.skinTypeRatings.length) {
          final data = p.skinTypeRatings[idx];
          if (data['avg'] != null && (data['count'] ?? 0) > 0) {
            score = (data['avg'] as num).toDouble();
          }
        }
      }

      if (score != null) {
        scored.add({'product': p, 'score': score});
      }
    }

    scored.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    return scored.take(3).map((e) => e['product'] as Product).toList();
  }

  Widget _buildRankingCard(String title, List<Product> products, Map<String, String> criteria) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RankingListPage(
              selectedAge: criteria['type'] == 'age' ? criteria['value'] : null,
              selectedSkinType: criteria['type'] == 'skinType' ? criteria['value'] : null,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            ...List.generate(products.length, (i) {
              final p = products[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('${i + 1}.', style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(p.imageUrl, width: 45, height: 45, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        p.name,
                        style: const TextStyle(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    if (_isLoading && _searchQuery.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            onChanged: _searchProducts,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _searchProducts('');
                },
              )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        if (_searchQuery.isEmpty)
          ..._finalCriteria.map((criteria) {
            final type = criteria['type']!;
            final value = criteria['value']!;
            final title = type == 'category'
                ? 'Top in $value'
                : type == 'age'
                ? 'Best among $value'
                : 'Best for $value skin';

            return FutureBuilder<List<Product>>(
              future: getTopProducts(type: type, value: value),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
                return _buildRankingCard(title, snapshot.data!, criteria);
              },
            );
          }).toList(),
        if (_searchQuery.isNotEmpty)
          ..._filteredProducts.map((p) => ListTile(
            leading: Image.network(p.imageUrl, width: 50, height: 50),
            title: Text(p.name),
            subtitle: Text(p.brand),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: p),
                ),
              );
            },
          )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          CategoryPage(),
          _buildHomePage(),
          const MyPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Category'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Page'),
        ],
      ),
    );
  }
}

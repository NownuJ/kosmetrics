import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import 'product_detail_page.dart';
import 'placeholder_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  List<Product> _allProducts = [];          // All products from Firestore
  List<Product> _filteredProducts = [];     // What the user sees (search result)

  int _selectedIndex = 1; // Home tab index (0 = Category, 1 = Home, 2 = My Page)

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final snapshot = await FirebaseFirestore.instance.collection('cosmetics').get();
    final products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    setState(() {
      _allProducts = products;
      _filteredProducts = products;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _searchProducts(String query) {
    final lowerQuery = query.toLowerCase();
    final filtered = _allProducts.where((product) {
      return product.name.toLowerCase().contains(lowerQuery);
    }).toList();

    setState(() {
      _filteredProducts = filtered;
    });
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _searchProducts('');
                },
              )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: _searchProducts,
          ),
        ),
        Expanded(
          child: _filteredProducts.isEmpty
              ? const Center(child: Text('No products found'))
              : ListView.builder(
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const PlaceholderPage('Category'),
          _buildHomePage(),
          const PlaceholderPage('My Page'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Category'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Page'),
        ],
      ),
    );
  }
}

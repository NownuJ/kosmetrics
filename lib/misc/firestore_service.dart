import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart'; // your Product class

class FirestoreService {
  final CollectionReference productsRef =
  FirebaseFirestore.instance.collection('products');

  Future<List<Product>> fetchAllProducts() async {
    final snapshot = await productsRef.get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  // Optional: fetch one product by ID
  Future<Product> fetchProductById(String id) async {
    final doc = await productsRef.doc(id).get();
    return Product.fromFirestore(doc);
  }
}
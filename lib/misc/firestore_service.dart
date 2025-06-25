import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  final CollectionReference productsRef =
  FirebaseFirestore.instance.collection('products');

  Future<List<Product>> fetchAllProducts() async {
    final snapshot = await productsRef.get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }
}
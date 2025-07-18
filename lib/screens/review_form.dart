import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kosmetric/models/product_model.dart';

class ReviewForm extends StatefulWidget {
  final Product product;
  const ReviewForm({Key? key, required this.product}) : super(key: key);

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  double _rating = 3;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _submitReview() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final nickname = userDoc.data()?['nickname'] ?? 'Anonymous';

    final reviewData = {
      'userId': user.uid,
      'nickname': nickname,
      'rating': _rating,
      'comment': _commentController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    final productId = widget.product.id;
    final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
    final reviewsRef = productRef.collection('reviews');

    await reviewsRef.add(reviewData);

    final reviewsSnapshot = await reviewsRef.get();
    double totalRating = 0;
    for (var doc in reviewsSnapshot.docs) {
      totalRating += (doc['rating'] ?? 0).toDouble();
    }

    double avgRating = totalRating / reviewsSnapshot.docs.length;

    await productRef.update({'rating': avgRating});

    _commentController.clear();
    setState(() {
      _rating = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Leave a review:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  _rating = index + 1.0;
                });
              },
            );
          }),
        ),
        TextField(
          controller: _commentController,
          decoration: const InputDecoration(labelText: 'Comment'),
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _submitReview,
          child: const Text('Submit'),
        ),
        const SizedBox(height: 16),
        const Text('Reviews:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .doc(widget.product.id)
              .collection('reviews')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No reviews yet.');
            }
            return Column(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("${data['nickname'] ?? 'Anonymous'}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${data['rating'] ?? 0} ★"),
                      Text(data['comment'] ?? ''),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

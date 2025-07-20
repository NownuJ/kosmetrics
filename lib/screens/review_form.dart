import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kosmetric/models/product_model.dart';

class ReviewForm extends StatefulWidget {
  final Product product;
  const ReviewForm({super.key, required this.product});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  double _rating = 3;
  final TextEditingController _commentController = TextEditingController();
  String? _userReviewId;
  Map<String, dynamic>? _userReviewData;

  @override
  void initState() {
    super.initState();

    // Ensure _loadUserReview is called safely after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserReview();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _userReviewId = null;
          _userReviewData = null;
        });
      }
      return;
    }

    final reviewsRef = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.id)
        .collection('reviews');

    try {
      final snapshot = await reviewsRef
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (!mounted) return; // Crucial check before updating UI

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        setState(() {
          _userReviewId = doc.id;
          _userReviewData = doc.data();
          _rating = (_userReviewData?['rating'] ?? 3).toDouble();
          _commentController.text = _userReviewData?['comment'] ?? '';
        });
      } else {
        // If no user review found, clear previous if any
        setState(() {
          _userReviewId = null;
          _userReviewData = null;
          _rating = 3.0; // Reset default rating
          _commentController.text = ''; // Clear comment field
        });
      }
    } catch (e) {
      print("Error loading user review: $e");

    }
  }


  int getAgeGroupIndex(int age) {
    if (age < 30) return 0;
    if (age < 40) return 1;
    if (age < 50) return 2;
    if (age < 60) return 3;
    return 4;
  }


  Future<void> _submitReview() async {
    try {

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You must be logged in to submit a review.")),
          );
        }
        return;
      }

      if (!mounted) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();


      if (!mounted) return;

      final nickname = userDoc.data()?['nickname'] ?? 'Anonymous';
      final age = userDoc.data()?['age'] ?? 0;
      final skinTypeIndex = userDoc.data()?['skinType'] ?? 0;
      final ageGroupIndex = getAgeGroupIndex(age);

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

      final isEditing = _userReviewId != null;
      String message;

      double? oldRating;
      if (isEditing) {
        oldRating = _userReviewData?['rating']?.toDouble();
        await reviewsRef.doc(_userReviewId).update(reviewData);

        message = "Review edited!";
      } else {
        final newDoc = await reviewsRef.add(reviewData);
        if (!mounted) return;
        _userReviewId = newDoc.id;
        message = "Review submitted!";
      }

      await _loadUserReview();

      final reviewsSnapshot = await reviewsRef.get();
      if (!mounted) return;

      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += (doc['rating'] ?? 0).toDouble();
      }
      double avgRating = (reviewsSnapshot.docs.isNotEmpty) ? totalRating / reviewsSnapshot.docs.length : 0.0;
      await productRef.update({'rating': avgRating});

      if (!mounted) return;

      final productSnapshot = await productRef.get();

      if (!mounted) return;

      final productData = productSnapshot.data() ?? {};

      List<dynamic> rawAgeRatings = productData['ageRatings'] ?? List.generate(5, (_) => {'avg': 0.0, 'count': 0});
      List<dynamic> rawSkinRatings = productData['skinTypeRatings'] ?? List.generate(5, (_) => {'avg': 0.0, 'count': 0});

      List<Map<String, dynamic>> ageRatings = List.generate(5, (i) {
        if (i < rawAgeRatings.length && rawAgeRatings[i] is Map) {
          final entry = rawAgeRatings[i] as Map<String, dynamic>;
          return {
            'avg': (entry['avg'] as num?)?.toDouble() ?? 0.0,
            'count': (entry['count'] as num?)?.toInt() ?? 0,
          };
        }
        return {'avg': 0.0, 'count': 0};
      });

      List<Map<String, dynamic>> skinTypeRatings = List.generate(5, (i) {
        if (i < rawSkinRatings.length && rawSkinRatings[i] is Map) {
          final entry = rawSkinRatings[i] as Map<String, dynamic>;
          return {
            'avg': (entry['avg'] as num?)?.toDouble() ?? 0.0,
            'count': (entry['count'] as num?)?.toInt() ?? 0,
          };
        }
        return {'avg': 0.0, 'count': 0};
      });

      // === Update age group average ===
      double ageAvg = ageRatings[ageGroupIndex]['avg'];
      int ageCount = ageRatings[ageGroupIndex]['count'];
      if (isEditing && oldRating != null) {
        if (ageCount > 0) {
          double newTotal = ageAvg * ageCount - oldRating + _rating;
          ageAvg = newTotal / ageCount;
        } else {
          //should not happen
          ageAvg = _rating;
          ageCount = 1;
        }
      } else {
        double newTotal = ageAvg * ageCount + _rating;
        ageCount++;
        ageAvg = newTotal / ageCount;
      }
      ageRatings[ageGroupIndex] = {'avg': ageAvg, 'count': ageCount};

      // === Update skin type average ===
      double skinAvg = skinTypeRatings[skinTypeIndex]['avg'];
      int skinCount = skinTypeRatings[skinTypeIndex]['count'];
      if (isEditing && oldRating != null) {
        if (skinCount > 0) {
          double newTotal = skinAvg * skinCount - oldRating + _rating;
          skinAvg = newTotal / skinCount;
        } else {
          //should not happen
          skinAvg = _rating;
          skinCount = 1;
        }
      } else {
        double newTotal = skinAvg * skinCount + _rating;
        skinCount++;
        skinAvg = newTotal / skinCount;
      }
      skinTypeRatings[skinTypeIndex] = {'avg': skinAvg, 'count': skinCount};


      await productRef.update({
        'ageRatings': ageRatings,
        'skinTypeRatings': skinTypeRatings,
      });


      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e, stack) {
      print("Review submission failed: $e");
      print(stack);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong while submitting your review.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
        if (_userReviewData != null)
          ListTile(
            tileColor: Colors.blue.shade50,
            leading: const Icon(Icons.person),
            title: const Text("Your review"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < (_userReviewData!['rating'] ?? 0).round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text(_userReviewData!['comment'] ?? ''),
              ],
            ),
          ),
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

            final docs = snapshot.data!.docs;

            final otherReviews = docs.where((doc) {
              return doc['userId'] != user?.uid;
            }).toList();

            return Column(
              children: otherReviews.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final int roundedRating = (data['rating'] ?? 0).round();
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(data['nickname'] ?? 'Anonymous'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < roundedRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
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
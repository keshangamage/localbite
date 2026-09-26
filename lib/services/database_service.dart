import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/restaurant.dart';
import '../models/review.dart';

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;
  final _restaurantsRef = FirebaseFirestore.instance.collection('restaurants');
  final _reviewsRef = FirebaseFirestore.instance.collection('reviews');

  CollectionReference<Map<String, dynamic>> _favouritesRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('favourites');

  Stream<List<Restaurant>> restaurantsStream() {
    return _restaurantsRef.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Restaurant.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Stream<List<Review>> reviewsForRestaurant(String restaurantId) {
    return _reviewsRef
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map(_reviewsFromSnapshot);
  }

  Stream<List<Review>> reviewsForUser(String userId) {
    return _reviewsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(_reviewsFromSnapshot);
  }

  Future<void> addReview(Review review) async {
    await _reviewsRef.add(review.toMap());
  }

  Future<void> updateReview(Review review) async {
    await _reviewsRef.doc(review.id).update({
      'rating': review.rating,
      'title': review.title,
      'description': review.description,
      'visitDate': review.visitDate.millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteReview(String reviewId) async {
    await _reviewsRef.doc(reviewId).delete();
  }

  Stream<Set<String>> favouriteIdsStream(String userId) {
    return _favouritesRef(userId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.id).toSet(),
    );
  }

  Future<void> setFavourite({
    required String userId,
    required String restaurantId,
    required bool isFavourite,
  }) async {
    final ref = _favouritesRef(userId).doc(restaurantId);
    if (isFavourite) {
      await ref.set({'saved': true});
    } else {
      await ref.delete();
    }
  }

  List<Review> _reviewsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final reviews = snapshot.docs
        .map((doc) => Review.fromMap(doc.id, doc.data()))
        .toList();

    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }
}

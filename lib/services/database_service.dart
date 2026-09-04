import 'package:firebase_database/firebase_database.dart';

import '../models/restaurant.dart';
import '../models/review.dart';

class DatabaseService {
  final DatabaseReference _restaurantsRef = FirebaseDatabase.instance.ref(
    'restaurants',
  );

  final DatabaseReference _reviewsRef = FirebaseDatabase.instance.ref(
    'reviews',
  );

  final DatabaseReference _favouritesRef = FirebaseDatabase.instance.ref(
    'favourites',
  );

  Stream<List<Restaurant>> restaurantsStream() {
    return _restaurantsRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return <Restaurant>[];
      }

      return data.entries
          .map(
            (entry) => Restaurant.fromMap(
              entry.key as String,
              entry.value as Map<dynamic, dynamic>,
            ),
          )
          .toList();
    });
  }

  Stream<List<Review>> reviewsForRestaurant(String restaurantId) {
    return _reviewsRef
        .orderByChild('restaurantId')
        .equalTo(restaurantId)
        .onValue
        .map(_reviewsFromEvent);
  }

  Stream<List<Review>> reviewsForUser(String userId) {
    return _reviewsRef
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map(_reviewsFromEvent);
  }

  Future<void> addReview(Review review) async {
    await _reviewsRef.push().set(review.toMap());
  }

  Future<void> updateReview(Review review) async {
    await _reviewsRef.child(review.id).update({
      'rating': review.rating,
      'title': review.title,
      'description': review.description,
      'visitDate': review.visitDate.millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteReview(String reviewId) async {
    await _reviewsRef.child(reviewId).remove();
  }

  Stream<Set<String>> favouriteIdsStream(String userId) {
    return _favouritesRef.child(userId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return <String>{};
      }
      return data.keys.map((key) => key as String).toSet();
    });
  }

  Future<void> setFavourite({
    required String userId,
    required String restaurantId,
    required bool isFavourite,
  }) async {
    final ref = _favouritesRef.child(userId).child(restaurantId);
    if (isFavourite) {
      await ref.set(true);
    } else {
      await ref.remove();
    }
  }

  List<Review> _reviewsFromEvent(DatabaseEvent event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;
    if (data == null) {
      return <Review>[];
    }

    final reviews = data.entries
        .map(
          (entry) => Review.fromMap(
            entry.key as String,
            entry.value as Map<dynamic, dynamic>,
          ),
        )
        .toList();

    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }
}

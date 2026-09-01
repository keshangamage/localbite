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

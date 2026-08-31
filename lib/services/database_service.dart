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

  Future<void> addReview(Review review) async {
    await _reviewsRef.push().set(review.toMap());
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

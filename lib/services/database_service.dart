import 'package:firebase_database/firebase_database.dart';

import '../models/restaurant.dart';

class DatabaseService {
  final DatabaseReference _restaurantsRef = FirebaseDatabase.instance.ref(
    'restaurants',
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
}

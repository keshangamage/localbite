import 'package:flutter_test/flutter_test.dart';
import 'package:localbite/core/utils/date_format.dart';
import 'package:localbite/models/restaurant.dart';
import 'package:localbite/models/review.dart';

void main() {
  group('Restaurant.fromMap', () {
    test('reads a complete record', () {
      final restaurant = Restaurant.fromMap('cafe_mocha', {
        'name': 'Cafe Mocha',
        'category': 'Cafe',
        'city': 'Kandy',
        'latitude': 7.2960,
        'longitude': 80.6280,
        'rating': 4.8,
        'reviewCount': 245,
        'featured': true,
      });

      expect(restaurant.id, 'cafe_mocha');
      expect(restaurant.name, 'Cafe Mocha');
      expect(restaurant.rating, 4.8);
      expect(restaurant.reviewCount, 245);
      expect(restaurant.featured, isTrue);
    });

    test('falls back to defaults when fields are missing', () {
      final restaurant = Restaurant.fromMap('broken', {});

      expect(restaurant.name, '');
      expect(restaurant.rating, 0);
      expect(restaurant.latitude, 0);
      expect(restaurant.featured, isFalse);
    });

    test('reads a rating stored as a whole number', () {
      final restaurant = Restaurant.fromMap('x', {'rating': 5});
      expect(restaurant.rating, 5.0);
    });
  });

  group('Review', () {
    test('survives a toMap and fromMap round trip', () {
      final visited = DateTime(2026, 8, 26);
      final review = Review(
        id: 'r1',
        userId: 'u1',
        userName: 'Keshan',
        restaurantId: 'cafe_mocha',
        restaurantName: 'Cafe Mocha',
        rating: 4,
        title: 'Great experience!',
        description: 'Lovely ambience.',
        visitDate: visited,
        createdAt: visited,
        updatedAt: visited,
      );

      final restored = Review.fromMap('r1', review.toMap());

      expect(restored.userId, 'u1');
      expect(restored.rating, 4);
      expect(restored.title, 'Great experience!');
      expect(restored.visitDate, visited);
    });
  });

  group('formatDate', () {
    test('formats a date the way the review cards show it', () {
      expect(formatDate(DateTime(2026, 8, 26)), '26 Aug 2026');
      expect(formatDate(DateTime(2026, 1, 1)), '1 Jan 2026');
      expect(formatDate(DateTime(2025, 12, 31)), '31 Dec 2025');
    });
  });
}

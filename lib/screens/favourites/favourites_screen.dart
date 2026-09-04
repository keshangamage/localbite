import 'package:flutter/material.dart';

import '../../models/restaurant.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/favourite_button.dart';
import '../../widgets/restaurant_list_tile.dart';
import '../../widgets/state_views.dart';
import '../restaurant/restaurant_details_screen.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();
    final userId = AuthService().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: StreamBuilder<Set<String>>(
        stream: databaseService.favouriteIdsStream(userId),
        builder: (context, favouriteSnapshot) {
          if (favouriteSnapshot.hasError) {
            return const ErrorView(message: 'Could not load your favourites.');
          }
          if (!favouriteSnapshot.hasData) {
            return const LoadingView();
          }

          final favouriteIds = favouriteSnapshot.data!;
          if (favouriteIds.isEmpty) {
            return const EmptyView(
              icon: Icons.favorite_border,
              message: 'Your favourite places will appear here.',
            );
          }

          return StreamBuilder<List<Restaurant>>(
            stream: databaseService.restaurantsStream(),
            builder: (context, restaurantSnapshot) {
              if (restaurantSnapshot.hasError) {
                return const ErrorView(message: 'Could not load restaurants.');
              }
              if (!restaurantSnapshot.hasData) {
                return const LoadingView();
              }

              final favourites = restaurantSnapshot.data!
                  .where((restaurant) => favouriteIds.contains(restaurant.id))
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: favourites.length,
                itemBuilder: (context, index) {
                  final restaurant = favourites[index];

                  return RestaurantListTile(
                    restaurant: restaurant,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RestaurantDetailsScreen(restaurant: restaurant),
                      ),
                    ),
                    trailing: FavouriteButton(
                      isFavourite: true,
                      onPressed: () => databaseService.setFavourite(
                        userId: userId,
                        restaurantId: restaurant.id,
                        isFavourite: false,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

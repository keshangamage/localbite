import 'package:flutter/material.dart';

import '../../models/restaurant.dart';
import '../../models/review.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/favourite_button.dart';
import '../../widgets/restaurant_image.dart';
import '../../widgets/review_card.dart';
import '../../widgets/state_views.dart';
import 'review_form_screen.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  const RestaurantDetailsScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();
    final userId = AuthService().currentUser?.uid ?? '';

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewFormScreen(
                    restaurantId: restaurant.id,
                    restaurantName: restaurant.name,
                  ),
                ),
              ),
              child: const Text('ADD REVIEW'),
            ),
          ),
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return _buildLandscape(context, databaseService, userId);
          }
          return _buildPortrait(context, databaseService, userId);
        },
      ),
    );
  }

  /// Portrait: the photo is a collapsing header above the details.
  Widget _buildPortrait(
    BuildContext context,
    DatabaseService databaseService,
    String userId,
  ) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          backgroundColor: theme.colorScheme.surface,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: _CircleAction(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: _favouriteAction(databaseService, userId),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: restaurant.id,
              child: RestaurantImage(imageUrl: restaurant.imageUrl),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildInfo(context, databaseService),
          ),
        ),
      ],
    );
  }

  /// Landscape: the photo fills the left half and the details scroll on the
  /// right, so the wide screen is used instead of a short, stretched header.
  Widget _buildLandscape(
    BuildContext context,
    DatabaseService databaseService,
    String userId,
  ) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: restaurant.id,
                child: RestaurantImage(imageUrl: restaurant.imageUrl),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      _CircleAction(
                        icon: Icons.arrow_back,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      _favouriteAction(databaseService, userId),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildInfo(context, databaseService),
            ),
          ),
        ),
      ],
    );
  }

  Widget _favouriteAction(DatabaseService databaseService, String userId) {
    return StreamBuilder<Set<String>>(
      stream: databaseService.favouriteIdsStream(userId),
      builder: (context, snapshot) {
        final isFavourite = snapshot.data?.contains(restaurant.id) ?? false;

        return CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: FavouriteButton(
            isFavourite: isFavourite,
            onPressed: () => databaseService.setFavourite(
              userId: userId,
              restaurantId: restaurant.id,
              isFavourite: !isFavourite,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfo(BuildContext context, DatabaseService databaseService) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          restaurant.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              restaurant.rating.toStringAsFixed(1),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(${restaurant.reviewCount} reviews)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${restaurant.category}  ·  ${restaurant.city}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        _section(context, 'About', restaurant.description),
        _section(context, 'Opening Hours', restaurant.openingHours),
        _section(
          context,
          'Address',
          '${restaurant.address}, ${restaurant.city}',
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          'Reviews',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Review>>(
          stream: databaseService.reviewsForRestaurant(restaurant.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const ErrorView(message: 'Could not load reviews.');
            }
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: LoadingView(),
              );
            }

            final reviews = snapshot.data!;
            if (reviews.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: EmptyView(
                  icon: Icons.rate_review_outlined,
                  message: 'No reviews yet. Be the first to review.',
                ),
              );
            }

            return Column(
              children: reviews
                  .map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReviewCard(review: review),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(body, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.scrim.withValues(alpha: 0.5),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}

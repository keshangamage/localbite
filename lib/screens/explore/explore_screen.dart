import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/utils/layout.dart';
import '../../models/restaurant.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/location_service.dart';
import '../../widgets/favourite_button.dart';
import '../../widgets/restaurant_list_tile.dart';
import '../../widgets/state_views.dart';
import '../home/home_screen.dart';
import '../restaurant/restaurant_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _databaseService = DatabaseService();
  final _locationService = LocationService();
  final _searchController = TextEditingController();

  String _searchText = '';
  String? _selectedCategory;
  bool _nearbyOnly = false;
  bool _isLoadingLocation = false;
  Position? _position;
  LocationStatus? _locationStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleNearby() async {
    if (_nearbyOnly) {
      setState(() => _nearbyOnly = false);
      return;
    }

    setState(() => _isLoadingLocation = true);
    final result = await _locationService.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = false;
      _locationStatus = result.status;
      _position = result.position;
      _nearbyOnly = result.status == LocationStatus.granted;
    });
  }

  String? _distanceLabel(Restaurant restaurant) {
    final position = _position;
    if (position == null) {
      return null;
    }

    final km = _locationService.distanceInKm(
      fromLatitude: position.latitude,
      fromLongitude: position.longitude,
      toLatitude: restaurant.latitude,
      toLongitude: restaurant.longitude,
    );
    return '${km.toStringAsFixed(1)} km';
  }

  List<Restaurant> _applyFilters(List<Restaurant> restaurants) {
    final search = _searchText.toLowerCase();

    final filtered = restaurants.where((restaurant) {
      final matchesCategory =
          _selectedCategory == null || restaurant.category == _selectedCategory;
      final matchesSearch =
          search.isEmpty ||
          restaurant.name.toLowerCase().contains(search) ||
          restaurant.category.toLowerCase().contains(search) ||
          restaurant.city.toLowerCase().contains(search);
      return matchesCategory && matchesSearch;
    }).toList();

    final position = _position;
    if (_nearbyOnly && position != null) {
      filtered.sort((a, b) {
        final distanceToA = _locationService.distanceInKm(
          fromLatitude: position.latitude,
          fromLongitude: position.longitude,
          toLatitude: a.latitude,
          toLongitude: a.longitude,
        );
        final distanceToB = _locationService.distanceInKm(
          fromLatitude: position.latitude,
          fromLongitude: position.longitude,
          toLatitude: b.latitude,
          toLongitude: b.longitude,
        );
        return distanceToA.compareTo(distanceToB);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchText = value),
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          _buildFilterChips(),
          if (_locationStatus != null &&
              _locationStatus != LocationStatus.granted)
            _buildLocationNotice(),
          Expanded(child: _buildList(userId)),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final categories = kCategories.where((c) => c != 'All');

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          FilterChip(
            avatar: _isLoadingLocation
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.location_on_outlined, size: 18),
            label: const Text('Nearby'),
            selected: _nearbyOnly,
            onSelected: (_) => _toggleNearby(),
          ),
          const SizedBox(width: 8),
          for (final category in categories) ...[
            FilterChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (selected) => setState(() {
                _selectedCategory = selected ? category : null;
              }),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationNotice() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              locationMessage(_locationStatus!),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(String userId) {
    return StreamBuilder<Set<String>>(
      stream: _databaseService.favouriteIdsStream(userId),
      builder: (context, favouriteSnapshot) {
        final favouriteIds = favouriteSnapshot.data ?? <String>{};

        return StreamBuilder<List<Restaurant>>(
          stream: _databaseService.restaurantsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const ErrorView(
                message: 'Could not load restaurants. Please try again.',
              );
            }
            if (!snapshot.hasData) {
              return const LoadingView();
            }

            final restaurants = _applyFilters(snapshot.data!);
            if (restaurants.isEmpty) {
              return const EmptyView(
                icon: Icons.search_off,
                message: 'No restaurants match your search.',
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = gridColumnsFor(constraints.maxWidth);

                if (columns > 1) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: 4,
                    ),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) =>
                        _buildTile(restaurants[index], userId, favouriteIds),
                  );
                }

                return ListView.builder(
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) =>
                      _buildTile(restaurants[index], userId, favouriteIds),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTile(
    Restaurant restaurant,
    String userId,
    Set<String> favouriteIds,
  ) {
    final distance = _distanceLabel(restaurant);
    final isFavourite = favouriteIds.contains(restaurant.id);

    return RestaurantListTile(
      restaurant: restaurant,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantDetailsScreen(restaurant: restaurant),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (distance != null)
            Text(distance, style: Theme.of(context).textTheme.bodyMedium),
          FavouriteButton(
            isFavourite: isFavourite,
            onPressed: () => _databaseService.setFavourite(
              userId: userId,
              restaurantId: restaurant.id,
              isFavourite: !isFavourite,
            ),
          ),
        ],
      ),
    );
  }
}

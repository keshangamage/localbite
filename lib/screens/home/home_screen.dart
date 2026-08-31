import 'package:flutter/material.dart';

import '../../models/restaurant.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/restaurant_card.dart';
import '../restaurant/restaurant_details_screen.dart';
import '../../widgets/state_views.dart';

const List<String> kCategories = ['All', 'Cafe', 'Pizza', 'Asian', 'Fast Food'];

const Map<String, IconData> kCategoryIcons = {
  'All': Icons.grid_view_outlined,
  'Cafe': Icons.local_cafe_outlined,
  'Pizza': Icons.local_pizza_outlined,
  'Asian': Icons.ramen_dining_outlined,
  'Fast Food': Icons.lunch_dining_outlined,
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _databaseService = DatabaseService();
  final _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  String get _firstName {
    final name = AuthService().currentUser?.displayName ?? '';
    if (name.isEmpty) {
      return 'there';
    }
    return name.split(' ').first;
  }

  List<Restaurant> _applyFilters(List<Restaurant> restaurants) {
    final search = _searchText.toLowerCase();

    return restaurants.where((restaurant) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          restaurant.category == _selectedCategory;
      final matchesSearch =
          search.isEmpty ||
          restaurant.name.toLowerCase().contains(search) ||
          restaurant.category.toLowerCase().contains(search) ||
          restaurant.city.toLowerCase().contains(search);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Restaurant>>(
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
            return _buildContent(_applyFilters(snapshot.data!));
          },
        ),
      ),
    );
  }

  Widget _buildContent(List<Restaurant> restaurants) {
    final theme = Theme.of(context);

    final featured = restaurants.where((r) => r.featured).toList();
    final topRated = restaurants.where((r) => !r.featured).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting, $_firstName',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Discover great food near you',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchText = value),
                decoration: InputDecoration(
                  hintText: 'Search restaurants, cuisines...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHigh,
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
              const SizedBox(height: 24),
              Text(
                'Categories',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCategories(),
        if (restaurants.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 48),
            child: EmptyView(
              icon: Icons.search_off,
              message: 'No restaurants match your search.',
            ),
          ),
        if (featured.isNotEmpty) ...[
          const SizedBox(height: 24),
          _sectionTitle('Featured'),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FeaturedRestaurantCard(
              restaurant: featured.first,
              onTap: () => _openDetails(featured.first),
            ),
          ),
        ],
        if (topRated.isNotEmpty) ...[
          const SizedBox(height: 24),
          _sectionTitle('Top Rated'),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: topRated.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: 160,
                child: RestaurantCard(
                  restaurant: topRated[index],
                  onTap: () => _openDetails(topRated[index]),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  void _openDetails(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailsScreen(restaurant: restaurant),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCategories() {
    final theme = Theme.of(context);

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = kCategories[index];
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Column(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHigh,
                  ),
                  child: Icon(
                    kCategoryIcons[category],
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/review.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/review_card.dart';
import '../../widgets/state_views.dart';
import '../restaurant/review_form_screen.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();
    final userId = AuthService().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('My Reviews')),
      body: StreamBuilder<List<Review>>(
        stream: databaseService.reviewsForUser(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const ErrorView(message: 'Could not load your reviews.');
          }
          if (!snapshot.hasData) {
            return const LoadingView();
          }

          final reviews = snapshot.data!;
          if (reviews.isEmpty) {
            return const EmptyView(
              icon: Icons.rate_review_outlined,
              message: 'You have not written any reviews yet.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ReviewCard(
                  review: review,
                  showRestaurantName: true,
                  actions: ReviewActions(review: review),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ReviewActions extends StatelessWidget {
  const ReviewActions({super.key, required this.review});

  final Review review;

  void _edit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewFormScreen(
          restaurantId: review.restaurantId,
          restaurantName: review.restaurantName,
          existingReview: review,
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final colors = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete review?'),
        content: Text(
          'This will permanently remove your review of '
          '${review.restaurantName}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await DatabaseService().deleteReview(review.id);
      messenger.showSnackBar(const SnackBar(content: Text('Review deleted.')));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Could not delete the review. Please try again.',
            style: TextStyle(color: colors.onError),
          ),
          backgroundColor: colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: () => _edit(context),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit'),
          ),
        ),
        Container(width: 1, height: 40, color: colors.outlineVariant),
        Expanded(
          child: TextButton.icon(
            onPressed: () => _delete(context),
            icon: Icon(Icons.delete_outline, size: 18, color: colors.error),
            label: Text('Delete', style: TextStyle(color: colors.error)),
          ),
        ),
      ],
    );
  }
}

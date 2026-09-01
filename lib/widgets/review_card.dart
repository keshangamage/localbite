import 'package:flutter/material.dart';

import '../core/utils/date_format.dart';
import '../models/review.dart';
import 'rating_stars.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.review,
    this.actions,
    this.showRestaurantName = false,
  });

  final Review review;
  final Widget? actions;
  final bool showRestaurantName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        showRestaurantName
                            ? review.restaurantName
                            : review.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    RatingStars(rating: review.rating),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(review.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  'Visited ${formatDate(review.visitDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (actions != null) ...[const Divider(height: 1), actions!],
        ],
      ),
    );
  }
}

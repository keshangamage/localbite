import 'package:flutter/material.dart';

class RestaurantImage extends StatelessWidget {
  const RestaurantImage({super.key, required this.imageUrl, this.height});

  final String imageUrl;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return Container(
          height: height,
          color: colors.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          color: colors.surfaceContainerHighest,
          child: Icon(
            Icons.restaurant_outlined,
            color: colors.onSurfaceVariant,
          ),
        );
      },
    );
  }
}

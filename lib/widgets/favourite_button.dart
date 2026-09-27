import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class FavouriteButton extends StatelessWidget {
  const FavouriteButton({
    super.key,
    required this.isFavourite,
    required this.onPressed,
  });

  final bool isFavourite;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return IconButton(
      onPressed: () async {
        try {
          await onPressed();
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not update favourite. Please try again.'),
            ),
          );
        }
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isFavourite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFavourite),
          color: isFavourite ? appColors.favourite : null,
        ),
      ),
    );
  }
}

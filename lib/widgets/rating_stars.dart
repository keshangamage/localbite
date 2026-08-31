import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 16});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: size,
          color: color,
        );
      }),
    );
  }
}

class RatingSelector extends StatelessWidget {
  const RatingSelector({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Row(
      children: List.generate(5, (index) {
        final value = index + 1;

        return IconButton(
          onPressed: () => onChanged(value),
          padding: const EdgeInsets.only(right: 8),
          constraints: const BoxConstraints(),
          icon: Icon(
            value <= rating ? Icons.star : Icons.star_border,
            size: 40,
            color: color,
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';

class LocalBiteLogo extends StatelessWidget {
  const LocalBiteLogo({super.key, this.pinSize = 72, this.showTagline = false});

  final double pinSize;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Image.asset('assets/images/pin.png', height: pinSize),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'Local',
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              TextSpan(
                text: 'Bite',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ],
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'Discover. Taste. Enjoy.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

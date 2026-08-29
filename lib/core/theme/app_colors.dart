import 'package:flutter/material.dart';

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,

  primary: Color(0xFFF5B921),
  onPrimary: Color(0xFF241A00),
  primaryContainer: Color(0xFFFFE9A8),
  onPrimaryContainer: Color(0xFF251A00),

  secondary: Color(0xFF6B5D3F),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFF4E3C0),
  onSecondaryContainer: Color(0xFF241A04),

  tertiary: Color(0xFF4C6548),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFCDEBC5),
  onTertiaryContainer: Color(0xFF0A2007),

  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),

  surface: Color(0xFFFFFDF7),
  onSurface: Color(0xFF1D1B16),
  onSurfaceVariant: Color(0xFF4D4639),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFFAF4E8),
  surfaceContainer: Color(0xFFF5EFE2),
  surfaceContainerHigh: Color(0xFFEFE9DC),
  surfaceContainerHighest: Color(0xFFE9E3D6),
  surfaceDim: Color(0xFFDED8CB),
  surfaceBright: Color(0xFFFFFDF7),

  outline: Color(0xFF7F7667),
  outlineVariant: Color(0xFFDCD3C4),

  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
  inverseSurface: Color(0xFF32302A),
  onInverseSurface: Color(0xFFF5EFE2),
  inversePrimary: Color(0xFFF5B921),
  surfaceTint: Color(0xFFF5B921),
);

const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: Color(0xFFF5B921),
  onPrimary: Color(0xFF3F2E00),
  primaryContainer: Color(0xFF5A4400),
  onPrimaryContainer: Color(0xFFFFE9A8),

  secondary: Color(0xFFD7C6A0),
  onSecondary: Color(0xFF3A2F15),
  secondaryContainer: Color(0xFF52452A),
  onSecondaryContainer: Color(0xFFF4E3C0),

  tertiary: Color(0xFFB1CFAA),
  onTertiary: Color(0xFF1E361D),
  tertiaryContainer: Color(0xFF344D32),
  onTertiaryContainer: Color(0xFFCDEBC5),

  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),

  surface: Color(0xFF15130B),
  onSurface: Color(0xFFE9E2D4),
  onSurfaceVariant: Color(0xFFD0C6B4),
  surfaceContainerLowest: Color(0xFF100E07),
  surfaceContainerLow: Color(0xFF1D1B13),
  surfaceContainer: Color(0xFF211F17),
  surfaceContainerHigh: Color(0xFF2C2921),
  surfaceContainerHighest: Color(0xFF37342B),
  surfaceDim: Color(0xFF15130B),
  surfaceBright: Color(0xFF3C3930),

  outline: Color(0xFF999080),
  outlineVariant: Color(0xFF4D4639),

  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
  inverseSurface: Color(0xFFE9E2D4),
  onInverseSurface: Color(0xFF34302A),
  inversePrimary: Color(0xFF7A5900),
  surfaceTint: Color(0xFFF5B921),
);

class AppColors {
  const AppColors({required this.brandDeep, required this.favourite});

  final Color brandDeep;
  final Color favourite;

  static const AppColors light = AppColors(
    brandDeep: Color(0xFF8A6400),
    favourite: Color(0xFFE53935),
  );

  static const AppColors dark = AppColors(
    brandDeep: Color(0xFFF5B921),
    favourite: Color(0xFFE53935),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

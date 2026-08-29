import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static final ThemeData light = _themeFrom(lightColorScheme);
  static final ThemeData dark = _themeFrom(darkColorScheme);

  static ThemeData _themeFrom(ColorScheme scheme) => ThemeData(
    colorScheme: scheme,
    inputDecorationTheme: _inputDecorationTheme(scheme),
  );

  static InputDecorationThemeData _inputDecorationTheme(ColorScheme scheme) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecorationThemeData(
      border: border(scheme.outlineVariant),
      enabledBorder: border(scheme.outlineVariant),
      focusedBorder: border(scheme.primary, 2),
      errorBorder: border(scheme.error),
      focusedErrorBorder: border(scheme.error, 2),
      prefixIconColor: scheme.onSurfaceVariant,
      suffixIconColor: scheme.onSurfaceVariant,
    );
  }
}

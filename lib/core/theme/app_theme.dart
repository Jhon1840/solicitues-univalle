import 'package:flutter/material.dart';

class AppTheme {
  static const Color _semilla = Color(0xFF0F5C63);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: _semilla);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF6F8F8),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}

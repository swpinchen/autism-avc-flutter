import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
      );
}

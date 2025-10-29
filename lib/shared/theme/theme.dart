import 'package:flutter/material.dart';
import 'colors.dart';

/// Tema personalizado de Centralis siempre en modo oscuro
class CentralisTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      
      // Color scheme principal
      colorScheme: ColorScheme.dark(
      primary: CentralisColors.primary,
      primaryContainer: CentralisColors.secondary,
      secondary: CentralisColors.primary,
      secondaryContainer: CentralisColors.secondary,
      surface: CentralisColors.surface,
      onPrimary: CentralisColors.onPrimary,
      onSecondary: CentralisColors.onPrimary,
      onSurface: CentralisColors.onBackground,
      error: CentralisColors.error,
      onError: CentralisColors.onPrimary,
    ),
      
      // Scaffold background
      scaffoldBackgroundColor: CentralisColors.background,
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: CentralisColors.secondary,
        foregroundColor: CentralisColors.onBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: CentralisColors.onBackground,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CentralisColors.primary,
          foregroundColor: CentralisColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CentralisColors.linkText,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CentralisColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: const TextStyle(
          color: CentralisColors.placeholder,
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: CentralisColors.onBackground,
          fontSize: 16,
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CentralisColors.secondary,
        selectedItemColor: CentralisColors.primary,
        unselectedItemColor: CentralisColors.placeholder,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // Card theme
      cardTheme: const CardThemeData(
        color: CentralisColors.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        elevation: 2,
      ),
      
      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: CentralisColors.onBackground,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: CentralisColors.onBackground,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: CentralisColors.onBackground,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: CentralisColors.onBackground,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: CentralisColors.placeholder,
          fontSize: 14,
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: CentralisColors.onBackground,
      ),
    );
  }
}

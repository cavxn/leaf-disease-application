import 'package:flutter/material.dart';

class AppTheme {
  // Futuristic AI Color Palette
  static const Color _neonBlue = Color(0xFF00D4FF);
  static const Color _neonPurple = Color(0xFF8B5CF6);
  static const Color _neonPink = Color(0xFFEC4899);
  static const Color _cyberGreen = Color(0xFF10B981);
  static const Color _darkBg = Color(0xFF0A0A0F);
  static const Color _glassBg = Color(0x1AFFFFFF);
  static const Color _glassBorder = Color(0x33FFFFFF);

  // Light Theme Colors (Futuristic Light Mode)
  static const Color _lightPrimary = _neonBlue;
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightSecondary = _neonPurple;
  static const Color _lightOnSecondary = Color(0xFFFFFFFF);
  static const Color _lightSurface = Color(0xFFF8FAFC);
  static const Color _lightOnSurface = Color(0xFF1E293B);
  static const Color _lightBackground = Color(0xFFF1F5F9);

  // Dark Theme Colors (Futuristic Dark Mode)
  static const Color _darkPrimary = _neonBlue;
  static const Color _darkOnPrimary = Color(0xFF000000);
  static const Color _darkSecondary = _neonPurple;
  static const Color _darkOnSecondary = Color(0xFF000000);
  static const Color _darkSurface = Color(0xFF1E293B);
  static const Color _darkOnSurface = Color(0xFFF1F5F9);
  static const Color _darkBackground = _darkBg;

  // Glassmorphism Box Decoration
  static BoxDecoration get glassmorphismLight => BoxDecoration(
    color: _glassBg,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: _glassBorder, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static BoxDecoration get glassmorphismDark => BoxDecoration(
    color: _glassBg,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: _glassBorder, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 30,
        offset: const Offset(0, 15),
      ),
    ],
  );

  // Neon Gradient
  static const LinearGradient neonGradient = LinearGradient(
    colors: [_neonBlue, _neonPurple, _neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Cyber Gradient
  static const LinearGradient cyberGradient = LinearGradient(
    colors: [_darkBg, Color(0xFF1E293B), _neonBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        onPrimary: _lightOnPrimary,
        secondary: _lightSecondary,
        onSecondary: _lightOnSecondary,
        surface: _lightSurface,
        onSurface: _lightOnSurface,
        error: Color(0xFFEF4444),
        onError: Color(0xFFFFFFFF),
        background: _lightBackground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface.withOpacity(0.8),
        foregroundColor: _lightOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _lightOnSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: _lightOnPrimary,
          elevation: 8,
          shadowColor: _neonBlue.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _lightPrimary.withOpacity(0.3), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        filled: true,
        fillColor: _lightSurface,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        onPrimary: _darkOnPrimary,
        secondary: _darkSecondary,
        onSecondary: _darkOnSecondary,
        surface: _darkSurface,
        onSurface: _darkOnSurface,
        error: Color(0xFFF87171),
        onError: Color(0xFF000000),
        background: _darkBackground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface.withOpacity(0.8),
        foregroundColor: _darkOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _darkOnSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkOnPrimary,
          elevation: 8,
          shadowColor: _neonBlue.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: _darkPrimary.withOpacity(0.3), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        filled: true,
        fillColor: _darkSurface,
      ),
    );
  }
} 
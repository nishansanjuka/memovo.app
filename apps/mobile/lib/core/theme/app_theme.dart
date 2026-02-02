import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B7FFF);

  // Light Palette
  static const Color lightBg = Color(0xFFF9F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF1A1A1E);
  static const Color lightSubText = Color(0xFF6E6E77);

  // Dark Palette
  static const Color darkBg = Color(0xFF0F0F12);
  static const Color darkSurface = Color(0xFF1C1C21);
  static const Color darkText = Color(0xFFF4F4F5);
  static const Color darkSubText = Color(0xFFA1A1AA);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: primaryColor,
      surface: isDark ? darkBg : lightBg,
      onSurface: isDark ? darkText : lightText,
      surfaceContainer: isDark ? darkSurface : lightSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? darkBg : lightBg,

      // Typography
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: isDark ? darkText : lightText,
        displayColor: isDark ? darkText : lightText,
      ),

      // Component Themes
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: isDark ? darkText : lightText,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: isDark ? darkText : lightText),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: isDark ? darkSurface : lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? darkSurface : lightSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDark ? darkSubText : lightSubText,
      ),
    );
  }

  // Centralized Color Resolution (Expert Solution)
  static Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainer;
  static Color text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color subText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkSubText
      : lightSubText;
  static Color secondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.white.withOpacity(0.1)
      : Colors.black.withOpacity(0.05);

  // Primary remains a brand constant but functional for API consistency
  static Color primary(BuildContext context) => primaryColor;
}

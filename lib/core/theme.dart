import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RpgColors {
  static bool isDarkMode = true;

  static Color get background => isDarkMode ? const Color(0xff131415) : const Color(0xffffffff);
  static Color get cardBg => isDarkMode ? const Color(0xff202123) : const Color(0xffffffff);
  
  // Duolingo Green
  static const Color primary = Color(0xff58cc02); 
  // Duolingo Sky Blue
  static const Color secondary = Color(0xff1cb0f6); 
  // Streak Orange
  static const Color accent = Color(0xffff9600); 
  // Red
  static const Color error = Color(0xffea2b2b); 
  // Green
  static const Color success = Color(0xff58cc02); 

  static Color get textPrimary => isDarkMode ? const Color(0xfff3f4f6) : const Color(0xff3c3c3c);
  static Color get textSecondary => isDarkMode ? const Color(0xff9ca3af) : const Color(0xffafafaf);
  static Color get border => isDarkMode ? const Color(0xff374151) : const Color(0xffe5e5e5);
  static Color get activeCard => isDarkMode ? const Color(0xff1e3a8a) : const Color(0xffddf4ff);
}

class RpgTheme {
  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    // Determine colors based on brightness
    final isDark = brightness == Brightness.dark;
    
    // Fallback colors for ThemeData explicitly requested
    final bg = isDark ? const Color(0xff131415) : const Color(0xffffffff);
    final cardBg = isDark ? const Color(0xff202123) : const Color(0xffffffff);
    final textPrimary = isDark ? const Color(0xfff3f4f6) : const Color(0xff3c3c3c);
    final textSecondary = isDark ? const Color(0xff9ca3af) : const Color(0xffafafaf);
    final border = isDark ? const Color(0xff374151) : const Color(0xffe5e5e5);
    final inputBg = isDark ? const Color(0xff2d2e30) : const Color(0xfff7f7f7); // Better dark mode input field

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      primaryColor: RpgColors.primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: RpgColors.primary,
        onPrimary: Colors.white,
        secondary: RpgColors.secondary,
        onSecondary: Colors.white,
        error: RpgColors.error,
        onError: Colors.white,
        surface: cardBg,
        onSurface: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 2),
        ),
        elevation: 0,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBg,
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: RpgColors.secondary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RpgColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xff46a302), width: 2), // 3D bottom border look
          ),
          textStyle: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

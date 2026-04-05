import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Colors
  static const Color primary = Color(0xFFD97706);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFF59E0B);
  static const Color lostBadge = Color(0xFFEA580C);
  static const Color foundBadge = Color(0xFF16A34A);
  static const Color background = Color(0xFFFFFBEB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFFAEEE1);
  static const Color muted = Color(0xFFFCF6F0);
  static const Color error = Color(0xFFDC2626);

  // Spacing
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space48 = 48;

  // Border Radius
  static final BorderRadius radiusSmall = BorderRadius.circular(6);
  static final BorderRadius radiusMedium = BorderRadius.circular(12);

  // Badge decoration helper
  static BoxDecoration badgeDecoration(String type) {
    return BoxDecoration(
      color: type == 'lost' ? lostBadge : foundBadge,
      borderRadius: radiusSmall,
    );
  }

  // Badge text style
  static const TextStyle badgeTextStyle = TextStyle(
    color: onPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // Logo text styles
  static TextStyle logoStyle({
    required Color color,
    double fontSize = 32,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle logoOnPrimary({double fontSize = 32}) =>
      logoStyle(color: onPrimary, fontSize: fontSize);

  static TextStyle logoOnLight({double fontSize = 32}) =>
      logoStyle(color: primary, fontSize: fontSize);

  static ThemeData themeData() {
    final textTheme = TextTheme(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary,
      ),
      bodyLarge: GoogleFonts.openSans(
        fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary,
      ),
      bodyMedium: GoogleFonts.openSans(
        fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary,
      ),
      bodySmall: GoogleFonts.openSans(
        fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary,
      ),
      labelMedium: GoogleFonts.openSans(
        fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary,
      ),
      labelSmall: GoogleFonts.openSans(
        fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary,
      ),
    );

    return ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        surface: surface,
        // ignore: deprecated_member_use
        background: background,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: onPrimary,
        ),
      ),
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: radiusMedium),
          elevation: 0,
          textStyle: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: GoogleFonts.openSans(color: textSecondary),
        hintStyle: GoogleFonts.openSans(color: textSecondary),
      ),
      tabBarTheme: const TabBarThemeData(
        indicatorColor: onPrimary,
        labelColor: onPrimary,
        unselectedLabelColor: Color(0xB3FFFFFF),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radiusMedium),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: surface,
      ),
      dividerTheme: const DividerThemeData(
        color: border,
      ),
    );
  }
}

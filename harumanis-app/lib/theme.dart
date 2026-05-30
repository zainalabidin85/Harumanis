import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Amber/gold palette — buyer identity, distinct from Ai-Harumanis green
const Color kAmberDark    = Color(0xFF78350F);
const Color kAmberPrimary = Color(0xFFB45309);
const Color kAmberMid     = Color(0xFFD97706);
const Color kAmberLight   = Color(0xFFFEF3C7);
const Color kAmberTint    = Color(0xFFFFFBEB);
const Color kGreen        = Color(0xFF16A34A);
const Color kRed          = Color(0xFFDC2626);
const Color kBg           = Color(0xFFFFFAF0);
const Color kCard         = Color(0xFFFFFFFF);
const Color kText1        = Color(0xFF111827);
const Color kText2        = Color(0xFF6B7280);
const Color kText3        = Color(0xFF9CA3AF);
const Color kDivider      = Color(0xFFE5E7EB);

const kCardShadow = [
  BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4)),
];
// Billplz 1% + Zainal maintenance 1% — charged to buyer on top of farmer's price
const double kPlatformFeeRate = 0.02;

const kElevatedShadow = [
  BoxShadow(color: Color(0x18000000), blurRadius: 32, offset: Offset(0, 8)),
];

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kAmberPrimary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: kBg,
  );
  return base.copyWith(
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme)
        .apply(bodyColor: kText1, displayColor: kText1),
    cardTheme: CardThemeData(
      elevation: 0,
      color: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: kAmberPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAmberPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size.fromHeight(52),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kAmberPrimary, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(color: kText2, fontSize: 14),
      hintStyle: GoogleFonts.poppins(color: kText3),
    ),
    dividerTheme: const DividerThemeData(color: kDivider, space: 1),
  );
}

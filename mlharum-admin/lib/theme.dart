import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kIndigo900  = Color(0xFF1E1B4B);
const kIndigo700  = Color(0xFF3730A3);
const kIndigo500  = Color(0xFF6366F1);
const kIndigo100  = Color(0xFFE0E7FF);
const kIndigo50   = Color(0xFFEEF2FF);
const kBg         = Color(0xFFF8FAFC);
const kCard       = Colors.white;
const kText1      = Color(0xFF1E1B4B);
const kText2      = Color(0xFF4B5563);
const kText3      = Color(0xFF9CA3AF);
const kRed        = Color(0xFFEF4444);
const kGreen      = Color(0xFF16A34A);
const kOrange     = Color(0xFFF59E0B);

const kCardShadow = [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 2))];

ThemeData adminTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: kIndigo700, brightness: Brightness.light),
      textTheme: GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: kBg,
      appBarTheme: AppBarTheme(
        backgroundColor: kIndigo700,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kIndigo700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kIndigo50,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kIndigo500, width: 1.5)),
        labelStyle: GoogleFonts.poppins(fontSize: 14, color: kText2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        selectedColor: kIndigo700,
        labelStyle: GoogleFonts.poppins(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );

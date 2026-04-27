import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Deep Navy Backgrounds ──
  static const Color bgDark = Color(0xFF0B0F1A);
  static const Color bgCard = Color(0xFF111827);
  static const Color bgSurface = Color(0xFF1A1F2E);
  static const Color bgModal = Color(0xFF0F1320);
  static const Color bgElevated = Color(0xFF1E2538);

  // ── Neon Brand Palette ──
  static const Color cyan = Color(0xFF06D6F2);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);
  static const Color blue = Color(0xFF3B82F6);
  static const Color indigo = Color(0xFF6366F1);

  // ── Text Hierarchy ──
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDim = Color(0xFF475569);

  // ── Semantic ──
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFF87171);
  static const Color warning = Color(0xFFFBBF24);
  static const Color info = Color(0xFF60A5FA);

  // ── Borders & Glass ──
  static const Color borderStrong = Color(0x4006D6F2);
  static const Color borderMedium = Color(0x1AFFFFFF);
  static const Color borderSubtle = Color(0x0DFFFFFF);
  static const Color glassBg = Color(0x08FFFFFF);
  static const Color glassHover = Color(0x14FFFFFF);
  static const Color glassBright = Color(0x1AFFFFFF);

  // ── Gradients ──
  static const LinearGradient brandGradient = LinearGradient(
    colors: [purple, blue, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanPurple = LinearGradient(
    colors: [cyan, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purplePink = LinearGradient(
    colors: [purple, pink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFF06D6F2)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Category Colors
  static Color categoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('text') || cat.contains('nlp')) return indigo;
    if (cat.contains('image') || cat.contains('vision')) return pink;
    if (cat.contains('audio') || cat.contains('speech') || cat.contains('music')) return success;
    if (cat.contains('video')) return const Color(0xFFFB923C);
    if (cat.contains('code') || cat.contains('developer')) return cyan;
    if (cat.contains('search') || cat.contains('web')) return const Color(0xFFA78BFA);
    if (cat.contains('automation')) return warning;
    if (cat.contains('chatbot') || cat.contains('chat')) return blue;
    if (cat.contains('3d') || cat.contains('design')) return const Color(0xFFE879F9);
    if (cat.contains('data') || cat.contains('analytics')) return success;
    return const Color(0xFF94A3B8);
  }
}

class AppTheme {
  // ── 5-tier type scale (consistent sizes across the app) ──
  // Tier 1 — Display  : 32px  w800  -2% tracking  (hero headlines)
  // Tier 2 — Heading  : 20px  w700  -1% tracking  (section titles)
  // Tier 3 — Title    : 16px  w600  -0.3 tracking  (card names, nav)
  // Tier 4 — Body     : 14px  w400  1.55 height    (descriptions, paragraphs)
  // Tier 5 — Label    : 12px  w600  0.2 tracking   (tags, pills, metadata)

  static const Color _body = Color(0xFFA0A8B8); // softer than pure white

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      primaryColor: AppColors.cyan,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyan,
        secondary: AppColors.purple,
        tertiary: AppColors.pink,
        surface: AppColors.bgSurface,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.rubikTextTheme(
        const TextTheme(
          // Tier 1 — Display (hero) → overridden to Sora below
          displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.8, height: 1.15),
          displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.6, height: 1.2),
          // Tier 2 — Heading (sections) → overridden to Sora below
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.4, height: 1.3),
          headlineSmall:  TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3, height: 1.3),
          // Tier 3 — Title (cards, nav) → overridden to Sora below
          titleLarge:  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.3, height: 1.35),
          titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.2, height: 1.4),
          // Tier 4 — Body (Rubik stays)
          bodyLarge:  TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: _body, height: 1.55, letterSpacing: 0),
          bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: _body, height: 1.5, letterSpacing: 0),
          // Tier 5 — Label (Rubik stays)
          labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.2, height: 1.2),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.3, height: 1.2),
        ),
      ).copyWith(
        // Override display/headline/title tiers with Sora
        displayLarge:  GoogleFonts.sora(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.8, height: 1.15),
        displayMedium: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.6, height: 1.2),
        headlineMedium: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.4, height: 1.3),
        headlineSmall:  GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3, height: 1.3),
        titleLarge:  GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.3, height: 1.35),
        titleMedium: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.2, height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark.withValues(alpha: 0.92),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderMedium)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderMedium)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.cyan, width: 1.5)),
        hintStyle: const TextStyle(color: AppColors.textDim, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.bgDark,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderMedium),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.glassBg,
        selectedColor: AppColors.cyan.withValues(alpha: 0.15),
        side: const BorderSide(color: AppColors.borderMedium),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary, letterSpacing: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bgModal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgSurface,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.borderSubtle, thickness: 1),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

ThemeData buildAppTheme({required bool escuro, required String tipoFonte}) {
  final foreground = escuro ? Colors.white : AppColors.ink;
  TextTheme base = ThemeData.light().textTheme.apply(
    bodyColor: foreground,
    displayColor: foreground,
  );
  if (tipoFonte == 'Serif') {
    base = GoogleFonts.merriweatherTextTheme(base);
  } else if (tipoFonte == 'Mono') {
    base = GoogleFonts.sourceCodeProTextTheme(base);
  }

  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: escuro ? Brightness.dark : Brightness.light,
    primary: escuro ? const Color(0xFF86B5FF) : AppColors.primary,
    surface: escuro ? AppColors.nightSurface : Colors.white,
    onSurface: foreground,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: escuro ? Brightness.dark : Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: escuro
        ? AppColors.nightBackground
        : AppColors.paper,
    textTheme: base,
    appBarTheme: AppBarTheme(
      backgroundColor: escuro ? AppColors.nightBackground : AppColors.paper,
      foregroundColor: foreground,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: escuro ? AppColors.nightSurface : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: escuro ? AppColors.nightCard : AppColors.neutralSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 5,
      shape: CircleBorder(),
    ),
  );
}

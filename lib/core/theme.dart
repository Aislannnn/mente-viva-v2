import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

ThemeData buildAppTheme({required bool escuro, required String tipoFonte}) {
  TextTheme base = ThemeData.light().textTheme;
  if (tipoFonte == 'Serif') {
    base = GoogleFonts.merriweatherTextTheme(base);
  } else if (tipoFonte == 'Mono') {
    base = GoogleFonts.sourceCodeProTextTheme(base);
  }

  return ThemeData(
    brightness: escuro ? Brightness.dark : Brightness.light,
    colorSchemeSeed: AppColors.primary,
    textTheme: base,
  );
}

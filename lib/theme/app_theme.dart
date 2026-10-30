import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppColors {
  static const paper = Color(0xffFAF9F6),
      ink = Color(0xff252331),
      muted = Color(0xff777080);
  static const purple = Color(0xff7044D8),
      deep = Color(0xff382356),
      lavender = Color(0xffEFE9FA);
  static const line = Color(0xffECE9EF),
      green = Color(0xff2C7B63),
      rose = Color(0xffF5D6D2);
}

ThemeData partyTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'DMSans',
  scaffoldBackgroundColor: AppColors.paper,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.purple,
    primary: AppColors.purple,
    surface: AppColors.paper,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 31,
      height: 1.16,
      letterSpacing: -1.2,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    headlineMedium: TextStyle(
      fontSize: 27,
      height: 1.2,
      letterSpacing: -.9,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    titleLarge: TextStyle(
      fontSize: 19,
      letterSpacing: -.4,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    bodyMedium: TextStyle(fontSize: 13, height: 1.65, color: AppColors.muted),
    bodySmall: TextStyle(fontSize: 11, height: 1.6, color: AppColors.muted),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.paper,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontFamily: 'DMSans',
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    iconTheme: IconThemeData(color: AppColors.ink, size: 22),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      textStyle: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 50),
      foregroundColor: AppColors.ink,
      side: const BorderSide(color: AppColors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      textStyle: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(fontSize: 12, color: AppColors.muted),
    hintStyle: const TextStyle(fontSize: 12, color: Color(0xffA49BAC)),
    contentPadding: const EdgeInsets.all(15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppColors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppColors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppColors.purple, width: 1.3),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: AppColors.lavender,
    side: const BorderSide(color: AppColors.line),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
    labelStyle: const TextStyle(fontSize: 11, color: AppColors.muted),
    showCheckmark: true,
    checkmarkColor: AppColors.purple,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    indicatorColor: AppColors.lavender,
    height: 74,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (s) => TextStyle(
        fontSize: 10,
        fontFamily: 'DMSans',
        color: s.contains(WidgetState.selected)
            ? AppColors.purple
            : AppColors.muted,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  dividerTheme: const DividerThemeData(color: AppColors.line, space: 25),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.deep,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
  ),
);

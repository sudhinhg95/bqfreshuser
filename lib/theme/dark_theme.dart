import 'package:flutter/material.dart';
import 'package:sixam_mart/util/app_constants.dart';

ThemeData dark({Color color = const Color(0xFFea3244)}) => ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: color,
  secondaryHeaderColor: const Color.fromARGB(255, 30, 87, 25),
  disabledColor: const Color(0xFF6B6B6B),
  brightness: Brightness.dark,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: const Color(0xFF121212),
  shadowColor: Colors.black.withOpacity(0.5),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)),
  colorScheme: ColorScheme.dark(primary: color, secondary: color).copyWith(
    surface: const Color(0xFF121212),
  ).copyWith(error: const Color(0xFFE84D4F)),
  popupMenuTheme: const PopupMenuThemeData(color: Colors.black, surfaceTintColor: Colors.black),

  // Use the newer "*Data" theme classes expected by the SDK
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white10),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(
    color: Colors.black,
    elevation: 0,
  ),
  dividerTheme: const DividerThemeData(thickness: 0.2, color: Color(0xFF383838)),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);
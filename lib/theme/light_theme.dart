import 'package:flutter/material.dart';
import 'package:sixam_mart/util/app_constants.dart';

ThemeData light({Color color = const Color(0xFFea3244)}) => ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: color,
  secondaryHeaderColor: const Color.fromARGB(255, 30, 87, 25),
  disabledColor: const Color(0xFFBABFC4),
  brightness: Brightness.light,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: Colors.white,
  shadowColor: Colors.black.withOpacity(0.03),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)),
  colorScheme: ColorScheme.light(primary: color, secondary: color).copyWith(
    surface: const Color(0xFFFCFCFC),
  ).copyWith(error: const Color(0xFFE84D4F)),
  popupMenuTheme: const PopupMenuThemeData(color: Colors.white, surfaceTintColor: Colors.white),

  // Updated to newer "*Data" theme classes expected by newer Flutter SDKs
  dialogTheme: const DialogThemeData(surfaceTintColor: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
  ),
  bottomAppBarTheme: const BottomAppBarThemeData(
    color: Colors.white,
    elevation: 0,
    // If you relied on custom height/padding previously, you may need to adjust layout
    // where BottomAppBar is used, as height/padding were changed in the API.
  ),
  dividerTheme: const DividerThemeData(thickness: 0.2, color: Color(0xFFA0A4A8)),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);
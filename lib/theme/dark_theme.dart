import 'package:flutter/material.dart';
import 'package:sixam_mart/util/app_constants.dart';

ThemeData dark({Color color = const Color.fromARGB(240, 247, 102, 117)}) => ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: color,
  secondaryHeaderColor: const Color.fromARGB(255, 214, 45, 102),
  disabledColor: const Color.fromARGB(255, 240, 55, 55),
  brightness: Brightness.dark,
  hintColor: const Color.fromARGB(255, 255, 255, 255),
  cardColor: const Color.fromARGB(255, 36, 37, 37),
  shadowColor: Colors.white.withOpacity( 0.03),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Color.fromARGB(255, 248, 246, 246))),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)),
  colorScheme: ColorScheme.dark(primary: color, secondary: color).copyWith(surface: const Color(0xFF191A26)).copyWith(error: const Color.fromARGB(255, 187, 30, 30)),
  popupMenuTheme: const PopupMenuThemeData(color: Color(0xFF29292D), surfaceTintColor: Color(0xFF29292D)),
  dialogTheme: const DialogThemeData(surfaceTintColor: Color.fromARGB(223, 255, 255, 255)),
  floatingActionButtonTheme: FloatingActionButtonThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500))),
  bottomAppBarTheme: const BottomAppBarThemeData(
    surfaceTintColor: Colors.black, height: 60,
    padding: EdgeInsets.symmetric(vertical: 5),
  ),
  dividerTheme: const DividerThemeData(thickness: 0.5, color: Color(0xFFA0A4A8)),
  tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),
);

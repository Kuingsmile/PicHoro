import 'package:flutter/material.dart';

// Light Theme Color

const MaterialColor light = MaterialColor(lightPrimaryValue, <int, Color>{
  50: Color(0xFFE9F2FD),
  100: Color(0xFFC7E0F9),
  200: Color(0xFFA2CBF5),
  300: Color(0xFF7DB6F1),
  400: Color(0xFF61A6EE),
  500: Color(lightPrimaryValue),
  600: Color(0xFF3E8EE9),
  700: Color(0xFF3683E5),
  800: Color(0xFF2E79E2),
  900: Color(0xFF1F68DD),
});

const int lightPrimaryValue = 0xFF4596EB;

// Dark

const MaterialColor dark = MaterialColor(_darkPrimaryValue, <int, Color>{
  50: Color(0xFFE2E3E3),
  100: Color(0xFFB8B8B8),
  200: Color(0xFF888989),
  300: Color(0xFF58595A),
  400: Color(0xFF353636),
  500: Color(_darkPrimaryValue),
  600: Color(0xFF0F1011),
  700: Color(0xFF0C0D0E),
  800: Color(0xFF0A0A0B),
  900: Color(0xFF050506),
});
const int _darkPrimaryValue = 0xFF111213;

final ThemeData lightThemeData = ThemeData(
  brightness: Brightness.light,
  primarySwatch: light,
  primaryColor: Colors.orange,
  fontFamily: "iconfont", 
);

final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: dark,
  primaryColor: dark,
  fontFamily: "iconfont",
);

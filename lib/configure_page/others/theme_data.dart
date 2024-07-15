import 'package:flutter/material.dart';

// Light Theme Color
const int lightPrimaryValue = 0xFF4596EB;
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

final ThemeData lightThemeData = ThemeData(
  brightness: Brightness.light,
  primarySwatch: light,
  primaryColor: Colors.orange,
  fontFamily: "iconfont",
);

// Dark
const int darkPrimaryValue = 0xFF111213;
const MaterialColor dark = MaterialColor(darkPrimaryValue, <int, Color>{
  50: Color(0xFFE2E3E3),
  100: Color(0xFFB8B8B8),
  200: Color(0xFF888989),
  300: Color(0xFF58595A),
  400: Color(0xFF353636),
  500: Color(darkPrimaryValue),
  600: Color(0xFF0F1011),
  700: Color(0xFF0C0D0E),
  800: Color(0xFF0A0A0B),
  900: Color(0xFF050506),
});

final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: dark,
  primaryColor: dark,
  fontFamily: "iconfont",
);

// green theme color
const int greenPrimaryValue = 0xFF4CAF50;
const MaterialColor green = MaterialColor(greenPrimaryValue, <int, Color>{
  50: Color(0xFFE8F5E9),
  100: Color(0xFFC8E6C9),
  200: Color(0xFFA5D6A7),
  300: Color(0xFF81C784),
  400: Color(0xFF66BB6A),
  500: Color(greenPrimaryValue),
  600: Color(0xFF43A047),
  700: Color(0xFF388E3C),
  800: Color(0xFF2E7D32),
  900: Color(0xFF1B5E20),
});

final ThemeData greenThemeData = ThemeData(
  brightness: Brightness.light,
  primarySwatch: green,
  primaryColor: green,
  fontFamily: "iconfont",
);

// purple theme color
const int purplePrimaryValue = 0xFF673AB7;
const MaterialColor purple = MaterialColor(purplePrimaryValue, <int, Color>{
  50: Color(0xFFEDE7F6),
  100: Color(0xFFD1C4E9),
  200: Color(0xFFB39DDB),
  300: Color(0xFF9575CD),
  400: Color(0xFF7E57C2),
  500: Color(purplePrimaryValue),
  600: Color(0xFF5E35B1),
  700: Color(0xFF512DA8),
  800: Color(0xFF4527A0),
  900: Color(0xFF311B92),
});

final ThemeData purpleThemeData = ThemeData(
  brightness: Brightness.light,
  primarySwatch: purple,
  primaryColor: purple,
  fontFamily: "iconfont",
);

//orange theme color
const int orangePrimaryValue = 0xFFFF9800;
const MaterialColor orange = MaterialColor(orangePrimaryValue, <int, Color>{
  50: Color(0xFFFFF3E0),
  100: Color(0xFFFFE0B2),
  200: Color(0xFFFFCC80),
  300: Color(0xFFFFB74D),
  400: Color(0xFFFFA726),
  500: Color(orangePrimaryValue),
  600: Color(0xFFF57C00),
  700: Color(0xFFEF6C00),
  800: Color(0xFFE65100),
  900: Color(0xFFBF360C),
});

final ThemeData orangeThemeData = ThemeData(
  brightness: Brightness.light,
  primarySwatch: orange,
  primaryColor: orange,
  fontFamily: "iconfont",
);

//pink theme color
const int pinkPrimaryValue = 0xFFF8BBD0;
const MaterialColor pink = MaterialColor(pinkPrimaryValue, <int, Color>{
  50: Color(0xFFFCE4EC),
  100: Color(0xFFF8BBD0),
  200: Color(0xFFF48FB1),
  300: Color(0xFFF06292),
  400: Color(0xFFEC407A),
  500: Color(pinkPrimaryValue),
  600: Color(0xFFD81B60),
  700: Color(0xFFC2185B),
  800: Color(0xFFAD1457),
  900: Color(0xFF880E4F),
});

final ThemeData pinkThemeData = ThemeData(
  brightness: Brightness.light,
  primarySwatch: pink,
  primaryColor: pink,
  fontFamily: "iconfont",
);

// cyan theme color
const int cyanPrimaryValue = 0xFF00BCD4;
const MaterialColor cyan = MaterialColor(cyanPrimaryValue, <int, Color>{
  50: Color(0xFFE0F7FA),
  100: Color(0xFFB2EBF2),
  200: Color(0xFF80DEEA),
  300: Color(0xFF4DD0E1),
  400: Color(0xFF26C6DA),
  500: Color(cyanPrimaryValue),
  600: Color(0xFF00ACC1),
  700: Color(0xFF0097A7),
  800: Color(0xFF00838F),
  900: Color(0xFF006064),
});

final ThemeData cyanThemeData = ThemeData(
  brightness: Brightness.light,
  primarySwatch: cyan,
  primaryColor: cyan,
  fontFamily: "iconfont",
);

// gold theme color
const int goldPrimaryValue = 0xFFFFC107;
const MaterialColor gold = MaterialColor(goldPrimaryValue, <int, Color>{
  50: Color(0xFFFFFDE7),
  100: Color(0xFFFFF9C4),
  200: Color(0xFFFFF59D),
  300: Color(0xFFFFF176),
  400: Color(0xFFFFEE58),
  500: Color(goldPrimaryValue),
  600: Color(0xFFFDD835),
  700: Color(0xFFFBC02D),
  800: Color(0xFFF9A825),
  900: Color(0xFFF57F17),
});

final ThemeData goldThemeData = ThemeData(
  brightness: Brightness.light,
  primarySwatch: gold,
  primaryColor: gold,
  fontFamily: "iconfont",
);

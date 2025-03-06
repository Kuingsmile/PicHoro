import 'package:flutter/material.dart';

// Theme color definitions
const int lightPrimaryValue = 0xFF4596EB;
const int darkPrimaryValue = 0xFF111213;
const int greenPrimaryValue = 0xFF4CAF50;
const int purplePrimaryValue = 0xFF673AB7;
const int orangePrimaryValue = 0xFFFF9800;
const int pinkPrimaryValue = 0xFFF8BBD0;
const int cyanPrimaryValue = 0xFF00BCD4;
const int goldPrimaryValue = 0xFFFFC107;

// Theme data class to hold theme information
class AppThemeData {
  final String name;
  final int primaryValue;
  final Brightness brightness;

  const AppThemeData({
    required this.name,
    required this.primaryValue,
    this.brightness = Brightness.light,
  });
}

// Available themes
final List<AppThemeData> availableThemes = [
  const AppThemeData(name: 'Light', primaryValue: lightPrimaryValue),
  const AppThemeData(name: 'Dark', primaryValue: darkPrimaryValue, brightness: Brightness.dark),
  const AppThemeData(name: 'Green', primaryValue: greenPrimaryValue),
  const AppThemeData(name: 'Purple', primaryValue: purplePrimaryValue),
  const AppThemeData(name: 'Orange', primaryValue: orangePrimaryValue),
  const AppThemeData(name: 'Pink', primaryValue: pinkPrimaryValue),
  const AppThemeData(name: 'Cyan', primaryValue: cyanPrimaryValue),
  const AppThemeData(name: 'Gold', primaryValue: goldPrimaryValue),
];

// Function to generate theme data
ThemeData generateThemeData(AppThemeData themeData) {
  return ThemeData(
    brightness: themeData.brightness,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(themeData.primaryValue),
      brightness: themeData.brightness,
    ),
    fontFamily: "iconfont",
    appBarTheme: AppBarTheme(
      backgroundColor: Color(themeData.primaryValue),
    ),
  );
}

// Generated theme data instances
final ThemeData lightThemeData = generateThemeData(availableThemes[0]);
final ThemeData darkThemeData = generateThemeData(availableThemes[1]);
final ThemeData greenThemeData = generateThemeData(availableThemes[2]);
final ThemeData purpleThemeData = generateThemeData(availableThemes[3]);
final ThemeData orangeThemeData = generateThemeData(availableThemes[4]);
final ThemeData pinkThemeData = generateThemeData(availableThemes[5]);
final ThemeData cyanThemeData = generateThemeData(availableThemes[6]);
final ThemeData goldThemeData = generateThemeData(availableThemes[7]);

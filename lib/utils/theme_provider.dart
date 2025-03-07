import 'package:flutter/material.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:horopic/configure_page/others/theme_data.dart';

Map themeDataMap = {
  'light': lightThemeData,
  'green': greenThemeData,
  'dark': darkThemeData,
  'purple': purpleThemeData,
  'orange': orangeThemeData,
  'pink': pinkThemeData,
  'cyan': cyanThemeData,
  'gold': goldThemeData,
  ' ': lightThemeData,
};

class AppInfoProvider with ChangeNotifier {
  String _themeColor = '';
  String get themeColor => _themeColor;

  String _keyThemeColor = ' ';
  String get keyThemeColor => _keyThemeColor;

  AppInfoProvider() {
    _initAsync();
  }

  bool isDarkMode() => _themeColor == 'dark';

  Future<void> _initAsync() async {
    await SpUtil.getInstance();
    String colorset = SpUtil.getString('key_theme_color', defValue: 'light')!;
    _keyThemeColor = colorset;
    setTheme(colorset);
  }

  Future<void> setTheme(String themeColor) async {
    _themeColor =
        themeColor == 'auto' ? (DateTime.now().hour >= 8 && DateTime.now().hour <= 22 ? 'light' : 'dark') : themeColor;

    _keyThemeColor = _themeColor;

    notifyListeners();
    await SpUtil.getInstance();
    SpUtil.putString('key_theme_color', _themeColor);
  }
}

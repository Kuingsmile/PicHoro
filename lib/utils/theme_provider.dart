import 'package:flutter/material.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';

class AppInfoProvider with ChangeNotifier {
  String _themeColor = '';
  String get themeColor => _themeColor;

  String _keyThemeColor = ' ';
  String get keyThemeColor => _keyThemeColor;

  AppInfoProvider() {
    _initAsync();
  }

  Future<void> _initAsync() async {
    await SpUtil.getInstance();
    String colorset = SpUtil.getString('key_theme_color', defValue: 'light')!;
    _keyThemeColor = colorset;
    setTheme(colorset);
    // 设置初始化主题颜色
  }

  setTheme(String themeColor) async {
    if (themeColor == 'light') {
      _themeColor = 'light';
    } else if (themeColor == 'dark') {
      _themeColor = 'dark';
    } else {
      int timenow = DateTime.now().hour;
      if (timenow >= 8 && timenow <= 21) {
        _themeColor = 'light';
      } else {
        _themeColor = 'dark';
      }
    }
    notifyListeners();
    await SpUtil.getInstance();
    SpUtil.putString('key_theme_color', themeColor);
    _keyThemeColor = themeColor;
  }
}

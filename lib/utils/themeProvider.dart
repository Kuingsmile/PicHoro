import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';

class AppInfoProvider with ChangeNotifier {
  String _themeColor = '';
  String get themeColor => _themeColor;
  String _key_theme_color = ' ';
  String get key_theme_color => _key_theme_color;

  AppInfoProvider() {
    _initAsync();
  }

  Future<void> _initAsync() async {
    await SpUtil.getInstance();
    String colorset = SpUtil.getString('key_theme_color', defValue: 'light')!;
    _key_theme_color = colorset;
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
    _key_theme_color = themeColor;
  }
}

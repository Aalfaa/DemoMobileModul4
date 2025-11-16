import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  final _key = "isDarkMode";

  ThemeMode get mode => isDark() ? ThemeMode.dark : ThemeMode.light;

  bool isDark() {
    final pref = Get.find<SharedPreferences>();
    return pref.getBool(_key) ?? false;
  }

  void toggle() {
    final pref = Get.find<SharedPreferences>();
    final newMode = !isDark();
    pref.setBool(_key, newMode);
    Get.changeThemeMode(newMode ? ThemeMode.dark : ThemeMode.light);
  }
}

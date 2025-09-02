import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:instadown/constants/app_constants.dart';

class ThemeViewModel extends ChangeNotifier {
  static final ThemeViewModel _instance = ThemeViewModel._internal();
  factory ThemeViewModel() => _instance;
  ThemeViewModel._internal();

  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex =
          prefs.getInt(AppConstants.themeModeKey) ?? ThemeMode.system.index;
      _themeMode = ThemeMode.values[themeModeIndex];
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('테마 초기화 오류: $e');
      _themeMode = ThemeMode.system;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// 테마 모드 변경
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.themeModeKey, mode.index);
    } catch (e) {
      print('테마 저장 오류: $e');
    }
  }

  /// 라이트 모드로 설정
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// 다크 모드로 설정
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// 시스템 모드로 설정
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }

  /// 현재 테마 모드가 다크 모드인지 확인
  bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }

  /// 테마 모드 토글
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setDarkMode();
        break;
      case ThemeMode.dark:
        await setLightMode();
        break;
      case ThemeMode.system:
        // 시스템 모드에서는 현재 시스템 설정에 따라 토글
        await setDarkMode();
        break;
    }
  }

  /// 테마 모드 이름 반환
  String getThemeModeName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return '라이트';
      case ThemeMode.dark:
        return '다크';
      case ThemeMode.system:
        return '시스템';
    }
  }

  /// 테마 모드 아이콘 반환
  IconData getThemeModeIcon() {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}

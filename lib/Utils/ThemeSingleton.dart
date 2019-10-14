class ThemeSingleton {
  static final ThemeSingleton _themeSingleton = new ThemeSingleton._internal();

  bool isDark;
  bool isThemeManagerActive;
  factory ThemeSingleton() {
    return _themeSingleton;
  }
  ThemeSingleton._internal();
}

final themeSingleton = ThemeSingleton();
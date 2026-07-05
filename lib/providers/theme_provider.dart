import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() => true; // Default to dark mode

  void toggle() {
    state = !state;
  }

  void setDarkMode(bool isDark) {
    state = isDark;
  }
}

final isDarkModeProvider = NotifierProvider<ThemeNotifier, bool>(() {
  return ThemeNotifier();
});

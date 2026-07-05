import os

# telemetry_service.dart
file = 'lib/data/services/telemetry_service.dart'
content = open(file, encoding='utf-8').read()
content = content.replace("import 'dart:io';\n", "")
open(file, 'w', encoding='utf-8').write(content)

# lesson_screen.dart
file = 'lib/screens/lesson_screen.dart'
content = open(file, encoding='utf-8').read()
content = content.replace("  int _incorrectAttempts = 0;\n", "")
open(file, 'w', encoding='utf-8').write(content)

# liquid_scroll_tree_screen.dart
file = 'lib/screens/liquid_scroll_tree_screen.dart'
content = open(file, encoding='utf-8').read()
content = content.replace(").toList()", ")")
content = content.replace(".withOpacity(", ".withValues(alpha: ")
content = content.replace("class LiquidScrollTreeScreen extends StatefulWidget {", "class LiquidScrollTreeScreen extends StatefulWidget {\n  const LiquidScrollTreeScreen({super.key, required this.title, required this.curriculum});")
open(file, 'w', encoding='utf-8').write(content)

# profile_screen.dart
file = 'lib/screens/profile_screen.dart'
content = open(file, encoding='utf-8').read()
content = content.replace(".withOpacity(", ".withValues(alpha: ")
content = content.replace("activeColor: RpgColors.primary,", "activeThumbColor: RpgColors.primary,")
open(file, 'w', encoding='utf-8').write(content)

# splash_screen.dart
file = 'lib/screens/splash_screen.dart'
content = open(file, encoding='utf-8').read()
content = content.replace("import 'package:flutter_riverpod/flutter_riverpod.dart';\n", "")
content = content.replace(".withOpacity(", ".withValues(alpha: ")
open(file, 'w', encoding='utf-8').write(content)

import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'shell/main_shell.dart';

void main() => runApp(const SmartToolsApp());

class SmartToolsApp extends StatelessWidget {
  const SmartToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'SmartTools',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: mode,
          home: const MainShell(),
        );
      },
    );
  }
}

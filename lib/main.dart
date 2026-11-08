import 'package:flutter/material.dart';

void main() => runApp(const SmartToolsApp());

class AppColors {
  static const nightBlue = Color(0xFF101C35);
  static const primary = Color(0xFF2563EB);
  static const cyan = Color(0xFF22C1D6);
  static const lightGray = Color(0xFFF3F6FA);
  static const darkBackground = Color(0xFF0B1427);
}

final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.system);

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: brightness,
  ).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.cyan,
    surface: isDark ? AppColors.nightBlue : Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        isDark ? AppColors.darkBackground : AppColors.lightGray,
  );
}

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
          home: const StartPage(),
        );
      },
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.handyman_rounded,
                        size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text('SmartTools',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('par SmartLife Apps',
                      style: TextStyle(color: scheme.secondary)),
                  const SizedBox(height: 32),
                  Card(
                    color: scheme.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Apparence',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: themeModeNotifier,
                            builder: (context, mode, _) {
                              return SegmentedButton<ThemeMode>(
                                showSelectedIcon: false,
                                segments: const [
                                  ButtonSegment(
                                      value: ThemeMode.light,
                                      label: Text('Clair')),
                                  ButtonSegment(
                                      value: ThemeMode.dark,
                                      label: Text('Sombre')),
                                  ButtonSegment(
                                      value: ThemeMode.system,
                                      label: Text('Auto')),
                                ],
                                selected: {mode},
                                onSelectionChanged: (s) =>
                                    themeModeNotifier.value = s.first,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

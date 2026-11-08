import 'package:flutter/material.dart';

import '../../app/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Widget _card(BuildContext context, Widget child) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Paramètres',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _card(
            context,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apparence', style: titleStyle),
                const SizedBox(height: 12),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeModeNotifier,
                  builder: (context, mode, _) {
                    return SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                            value: ThemeMode.light, label: Text('Clair')),
                        ButtonSegment(
                            value: ThemeMode.dark, label: Text('Sombre')),
                        ButtonSegment(
                            value: ThemeMode.system, label: Text('Auto')),
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
          _card(
            context,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('À propos', style: titleStyle),
                const SizedBox(height: 8),
                const Text('SmartTools · version 0.1.0'),
                const Text('Un projet SmartLife Apps'),
                const SizedBox(height: 8),
                const Text(
                    'Gratuit, sans compte, conçu pour fonctionner hors connexion.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../models/tool.dart';
import '../../widgets/tool_tile.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = allTools.map((t) => t.category).toSet().toList();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Outils',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          for (final category in categories) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 8),
              child: Text(
                category,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final tool in allTools.where((t) => t.category == category))
              ToolTile(tool: tool),
          ],
        ],
      ),
    );
  }
}

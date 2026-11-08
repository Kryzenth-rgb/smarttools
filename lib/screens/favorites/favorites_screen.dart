import 'package:flutter/material.dart';

import '../../models/tool.dart';
import '../../widgets/tool_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<Set<String>>(
        valueListenable: favoritesNotifier,
        builder: (context, favs, _) {
          final tools = allTools.where((t) => favs.contains(t.id)).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Favoris',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              if (tools.isEmpty)
                const Text('Aucun favori pour le moment. Appuyez sur l’étoile d’un outil pour l’ajouter.')
              else
                for (final tool in tools) ToolTile(tool: tool),
            ],
          );
        },
      ),
    );
  }
}

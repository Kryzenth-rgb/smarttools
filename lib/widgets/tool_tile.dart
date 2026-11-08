import 'package:flutter/material.dart';

import '../models/tool.dart';

class ToolTile extends StatelessWidget {
  final Tool tool;

  const ToolTile({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<Set<String>>(
      valueListenable: favoritesNotifier,
      builder: (context, favorites, _) {
        final isFavorite = favorites.contains(tool.id);
        return Card(
          elevation: 0,
          color: scheme.surface,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Icon(tool.icon, color: scheme.primary),
            title: Text(tool.name),
            subtitle: Text(tool.description),
            trailing: IconButton(
              tooltip: isFavorite
                  ? 'Retirer des favoris'
                  : 'Ajouter aux favoris',
              icon: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFavorite ? Colors.amber : null,
              ),
              onPressed: () => toggleFavorite(tool.id),
            ),
            onTap: () {
              markRecent(tool.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${tool.name} : bientôt disponible')),
              );
            },
          ),
        );
      },
    );
  }
}

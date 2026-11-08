import 'package:flutter/material.dart';

import '../../models/tool.dart';
import '../../widgets/tool_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Tool> get _results {
    final q = _query.trim().toLowerCase();
    return allTools
        .where((t) =>
            t.name.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q))
        .toList();
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  List<Widget> _buildResults() {
    final results = _results;
    if (results.isEmpty) {
      return const [Text('Aucun outil trouvé.')];
    }
    return [for (final t in results) ToolTile(tool: t)];
  }

  List<Widget> _buildSections() {
    final categories = allTools.map((t) => t.category).toSet().toList();
    return [
      _title('Raccourcis rapides'),
      Row(
        children: [
          for (final id in const ['calculator', 'converter', 'stopwatch', 'notes'])
            Expanded(child: _Shortcut(tool: toolById(id))),
        ],
      ),
      const SizedBox(height: 24),
      _title('Récemment utilisés'),
      ValueListenableBuilder<List<String>>(
        valueListenable: recentNotifier,
        builder: (context, ids, _) {
          if (ids.isEmpty) {
            return const Text('Aucun outil utilisé pour le moment.');
          }
          return Column(
            children: [for (final id in ids) ToolTile(tool: toolById(id))],
          );
        },
      ),
      const SizedBox(height: 24),
      _title('Favoris'),
      ValueListenableBuilder<Set<String>>(
        valueListenable: favoritesNotifier,
        builder: (context, favs, _) {
          final tools = allTools.where((t) => favs.contains(t.id)).toList();
          if (tools.isEmpty) {
            return const Text('Appuyez sur l’étoile d’un outil pour l’ajouter ici.');
          }
          return Column(
            children: [for (final t in tools) ToolTile(tool: t)],
          );
        },
      ),
      const SizedBox(height: 24),
      _title('Catégories'),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in categories)
            ActionChip(
              label: Text(c),
              onPressed: () {
                _controller.text = c;
                setState(() => _query = c);
              },
            ),
        ],
      ),
      const SizedBox(height: 16),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final searching = _query.trim().isNotEmpty;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'SmartTools',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Tous vos outils essentiels, réunis en un seul endroit.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Rechercher un outil',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searching
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: scheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (searching) ..._buildResults() else ..._buildSections(),
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  final Tool tool;

  const _Shortcut({required this.tool});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        markRecent(tool.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tool.name} : bientôt disponible')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(tool.icon, color: scheme.primary),
            ),
            const SizedBox(height: 4),
            Text(
              tool.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

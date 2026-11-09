import 'package:flutter/material.dart';

import '../../models/note.dart';
import 'note_editor_screen.dart';
import 'notes_store.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _query = '';

  void _open([Note? note]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => NoteEditorScreen(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloc-notes'),
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle note'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Rechercher une note',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: scheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Note>>(
                valueListenable: notesNotifier,
                builder: (context, notes, _) {
                  final q = _query.trim().toLowerCase();
                  final shown = q.isEmpty
                      ? notes
                      : notes
                          .where((n) =>
                              n.title.toLowerCase().contains(q) ||
                              n.body.toLowerCase().contains(q))
                          .toList();
                  if (shown.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          notes.isEmpty
                              ? 'Aucune note. Appuyez sur « Nouvelle note ».'
                              : 'Aucune note trouvée.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: shown.length,
                    itemBuilder: (context, i) {
                      final n = shown[i];
                      final firstLine = n.body.split('\n').first.trim();
                      return Dismissible(
                        key: ValueKey(n.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: scheme.errorContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: scheme.onErrorContainer,
                          ),
                        ),
                        onDismissed: (_) {
                          deleteNote(n.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Note supprimée'),
                              action: SnackBarAction(
                                label: 'Annuler',
                                onPressed: () => saveNote(n),
                              ),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 0,
                          color: scheme.surface,
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            title: Text(
                              n.title.isEmpty ? 'Sans titre' : n.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${firstLine.isEmpty ? '' : '$firstLine\n'}'
                              '${formatNoteDate(n.updatedAt)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _open(n),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

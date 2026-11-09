import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/note.dart';
import 'notes_store.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final String _id = widget.note?.id ?? newNoteId();
  late final TextEditingController _title =
      TextEditingController(text: widget.note?.title ?? '');
  late final TextEditingController _body =
      TextEditingController(text: widget.note?.body ?? '');
  late String _status = widget.note == null
      ? ''
      : 'Modifiée le ${formatNoteDate(widget.note!.updatedAt)}';

  Timer? _debounce;
  bool _deleted = false;

  bool get _isEmpty =>
      _title.text.trim().isEmpty && _body.text.trim().isEmpty;

  @override
  void dispose() {
    _debounce?.cancel();
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _changed() {
    _debounce?.cancel();
    if (_status != 'Modification…') {
      setState(() => _status = 'Modification…');
    }
    _debounce = Timer(const Duration(milliseconds: 400), _save);
  }

  void _save() {
    if (_deleted || _isEmpty) return;
    saveNote(Note(
      id: _id,
      title: _title.text,
      body: _body.text,
      updatedAt: DateTime.now(),
    ));
    if (mounted) setState(() => _status = 'Enregistré automatiquement');
  }

  void _flush() {
    _debounce?.cancel();
    if (_deleted) return;
    if (_isEmpty) {
      deleteNote(_id);
    } else {
      _save();
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cette note ?'),
        content: const Text('Cette action est définitive.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _deleted = true;
    _debounce?.cancel();
    deleteNote(_id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) => _flush(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Note'),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              tooltip: 'Supprimer',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _title,
                  onChanged: (_) => _changed(),
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Titre',
                    border: InputBorder.none,
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: TextField(
                    controller: _body,
                    onChanged: (_) => _changed(),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Écrivez votre note…',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _status,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

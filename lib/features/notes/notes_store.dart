import 'package:flutter/foundation.dart';

import '../../models/note.dart';

final ValueNotifier<List<Note>> notesNotifier =
    ValueNotifier<List<Note>>(<Note>[]);

String newNoteId() => DateTime.now().microsecondsSinceEpoch.toString();

String formatNoteDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}

void saveNote(Note note) {
  final list = List<Note>.from(notesNotifier.value);
  final i = list.indexWhere((n) => n.id == note.id);
  if (i >= 0) {
    list[i] = note;
  } else {
    list.add(note);
  }
  list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  notesNotifier.value = list;
}

void deleteNote(String id) {
  notesNotifier.value =
      notesNotifier.value.where((n) => n.id != id).toList();
}

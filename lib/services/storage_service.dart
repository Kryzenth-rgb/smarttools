import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/theme.dart';
import '../features/calculator/calculator_screen.dart';
import '../features/notes/notes_store.dart';
import '../models/note.dart';
import '../models/tool.dart';
import 'alert_service.dart';

class AppStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _load();
    } catch (_) {
      // Sans stockage, l'application fonctionne mais ne sauvegarde pas.
      _prefs = null;
      return;
    }
    _listen();
  }

  static void _load() {
    final p = _prefs!;

    final mode = p.getString('theme_mode');
    themeModeNotifier.value = ThemeMode.values.firstWhere(
      (m) => m.name == mode,
      orElse: () => ThemeMode.system,
    );

    final sound = p.getString('timer_sound');
    if (sound != null && soundOptions.any((s) => s.id == sound)) {
      soundChoiceNotifier.value = sound;
    }

    final known = allTools.map((t) => t.id).toSet();
    favoritesNotifier.value =
        (p.getStringList('favorites') ?? <String>[]).where(known.contains).toSet();
    recentNotifier.value =
        (p.getStringList('recent') ?? <String>[]).where(known.contains).toList();

    calculatorHistory.value = p.getStringList('calc_history') ?? <String>[];

    final raw = p.getString('notes');
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        notesNotifier.value = [
          for (final e in list) Note.fromJson(e as Map<String, dynamic>),
        ];
      } catch (_) {
        // Données illisibles : on garde une copie avant tout écrasement.
        p.setString('notes_corrupted_backup', raw);
        notesNotifier.value = <Note>[];
      }
    }
  }

  static void _listen() {
    final p = _prefs!;
    themeModeNotifier.addListener(() {
      p.setString('theme_mode', themeModeNotifier.value.name);
    });
    soundChoiceNotifier.addListener(() {
      p.setString('timer_sound', soundChoiceNotifier.value);
    });
    favoritesNotifier.addListener(() {
      p.setStringList('favorites', favoritesNotifier.value.toList());
    });
    recentNotifier.addListener(() {
      p.setStringList('recent', recentNotifier.value);
    });
    calculatorHistory.addListener(() {
      p.setStringList('calc_history', calculatorHistory.value);
    });
    notesNotifier.addListener(() {
      p.setString(
        'notes',
        jsonEncode(notesNotifier.value.map((n) => n.toJson()).toList()),
      );
    });
  }
}

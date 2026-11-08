import 'package:flutter/material.dart';

class Tool {
  final String id;
  final String name;
  final String category;
  final String description;
  final IconData icon;

  const Tool({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
  });
}

const List<Tool> allTools = [
  Tool(
    id: 'calculator',
    name: 'Calculatrice',
    category: 'Calcul',
    description: 'Calculs avec historique',
    icon: Icons.calculate_rounded,
  ),
  Tool(
    id: 'converter',
    name: 'Convertisseur',
    category: 'Calcul',
    description: 'Longueur, masse, température…',
    icon: Icons.swap_horiz_rounded,
  ),
  Tool(
    id: 'stopwatch',
    name: 'Chronomètre',
    category: 'Temps',
    description: 'Temps et tours intermédiaires',
    icon: Icons.timer_rounded,
  ),
  Tool(
    id: 'timer',
    name: 'Minuteur',
    category: 'Temps',
    description: 'Compte à rebours avec alerte',
    icon: Icons.hourglass_bottom_rounded,
  ),
  Tool(
    id: 'notes',
    name: 'Bloc-notes',
    category: 'Organisation',
    description: 'Notes enregistrées sur l’appareil',
    icon: Icons.sticky_note_2_rounded,
  ),
  Tool(
    id: 'tasks',
    name: 'Tâches',
    category: 'Organisation',
    description: 'Liste de tâches avec échéances',
    icon: Icons.checklist_rounded,
  ),
  Tool(
    id: 'password',
    name: 'Mots de passe',
    category: 'Sécurité',
    description: 'Génération locale et sécurisée',
    icon: Icons.password_rounded,
  ),
  Tool(
    id: 'device',
    name: 'Infos appareil',
    category: 'Système',
    description: 'Modèle, système, écran',
    icon: Icons.phone_android_rounded,
  ),
];

// Mémoire temporaire : la sauvegarde sur l'appareil viendra à l'étape stockage.
final ValueNotifier<Set<String>> favoritesNotifier =
    ValueNotifier<Set<String>>(<String>{});
final ValueNotifier<List<String>> recentNotifier =
    ValueNotifier<List<String>>(<String>[]);

Tool toolById(String id) => allTools.firstWhere((t) => t.id == id);

void toggleFavorite(String id) {
  final next = Set<String>.from(favoritesNotifier.value);
  if (!next.remove(id)) next.add(id);
  favoritesNotifier.value = next;
}

void markRecent(String id) {
  final next = List<String>.from(recentNotifier.value)..remove(id);
  next.insert(0, id);
  recentNotifier.value = next.take(5).toList();
}

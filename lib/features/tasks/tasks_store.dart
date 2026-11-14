import 'package:flutter/foundation.dart';

import '../../models/task.dart';

final ValueNotifier<List<Task>> tasksNotifier =
    ValueNotifier<List<Task>>(<Task>[]);

String newTaskId() => DateTime.now().microsecondsSinceEpoch.toString();

String formatDue(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

bool isOverdue(Task t) {
  final due = t.dueDate;
  if (t.done || due == null) return false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return DateTime(due.year, due.month, due.day).isBefore(today);
}

void saveTask(Task task) {
  final list = List<Task>.from(tasksNotifier.value);
  final i = list.indexWhere((t) => t.id == task.id);
  if (i >= 0) {
    list[i] = task;
  } else {
    list.add(task);
  }
  tasksNotifier.value = list;
}

void deleteTask(String id) {
  tasksNotifier.value =
      tasksNotifier.value.where((t) => t.id != id).toList();
}

void toggleTask(String id) {
  tasksNotifier.value = [
    for (final t in tasksNotifier.value)
      if (t.id == id) t.copyWith(done: !t.done) else t,
  ];
}

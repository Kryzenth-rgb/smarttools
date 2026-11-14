import 'package:flutter/material.dart';

import '../../models/task.dart';
import 'tasks_store.dart';

enum _Filter { all, todo, done }

enum _Sort { due, created, title }

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  _Filter _filter = _Filter.all;
  _Sort _sort = _Sort.due;

  int _compare(Task a, Task b) {
    if (_sort == _Sort.title) {
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
    if (_sort == _Sort.created) {
      return b.createdAt.compareTo(a.createdAt);
    }
    final ad = a.dueDate;
    final bd = b.dueDate;
    if (ad == null && bd == null) return b.createdAt.compareTo(a.createdAt);
    if (ad == null) return 1;
    if (bd == null) return -1;
    final c = ad.compareTo(bd);
    return c != 0 ? c : b.createdAt.compareTo(a.createdAt);
  }

  List<Task> _visible(List<Task> all) {
    final list = all
        .where((t) => switch (_filter) {
              _Filter.todo => !t.done,
              _Filter.done => t.done,
              _Filter.all => true,
            })
        .toList();
    list.sort(_compare);
    return list;
  }

  Future<void> _openForm([Task? task]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _TaskForm(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tâches'),
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<_Sort>(
            tooltip: 'Trier',
            icon: const Icon(Icons.sort_rounded),
            initialValue: _sort,
            onSelected: (s) => setState(() => _sort = s),
            itemBuilder: (_) => const [
              PopupMenuItem(value: _Sort.due, child: Text('Par échéance')),
              PopupMenuItem(
                  value: _Sort.created, child: Text('Plus récentes')),
              PopupMenuItem(value: _Sort.title, child: Text('Par titre')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle tâche'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SegmentedButton<_Filter>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: _Filter.all, label: Text('Toutes')),
                  ButtonSegment(value: _Filter.todo, label: Text('À faire')),
                  ButtonSegment(
                      value: _Filter.done, label: Text('Terminées')),
                ],
                selected: {_filter},
                onSelectionChanged: (s) => setState(() => _filter = s.first),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Task>>(
                valueListenable: tasksNotifier,
                builder: (context, all, _) {
                  final shown = _visible(all);
                  if (shown.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          all.isEmpty
                              ? 'Aucune tâche. Appuyez sur « Nouvelle tâche ».'
                              : 'Aucune tâche dans ce filtre.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: shown.length,
                    itemBuilder: (context, i) {
                      final t = shown[i];
                      final overdue = isOverdue(t);
                      return Dismissible(
                        key: ValueKey(t.id),
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
                          deleteTask(t.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Tâche supprimée'),
                              action: SnackBarAction(
                                label: 'Annuler',
                                onPressed: () => saveTask(t),
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
                            leading: Checkbox(
                              value: t.done,
                              onChanged: (_) => toggleTask(t.id),
                            ),
                            title: Text(
                              t.title,
                              style: TextStyle(
                                decoration: t.done
                                    ? TextDecoration.lineThrough
                                    : null,
                                color:
                                    t.done ? scheme.onSurfaceVariant : null,
                              ),
                            ),
                            subtitle: t.dueDate == null
                                ? null
                                : Text(
                                    overdue
                                        ? 'En retard · ${formatDue(t.dueDate!)}'
                                        : 'Échéance : ${formatDue(t.dueDate!)}',
                                    style: TextStyle(
                                      color: overdue ? scheme.error : null,
                                    ),
                                  ),
                            onTap: () => _openForm(t),
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

class _TaskForm extends StatefulWidget {
  final Task? task;

  const _TaskForm({this.task});

  @override
  State<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<_TaskForm> {
  late final TextEditingController _title =
      TextEditingController(text: widget.task?.title ?? '');
  late DateTime? _due = widget.task?.dueDate;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _due ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _due = DateTime(picked.year, picked.month, picked.day));
    }
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Saisissez un titre.');
      return;
    }
    final old = widget.task;
    saveTask(Task(
      id: old?.id ?? newTaskId(),
      title: title,
      done: old?.done ?? false,
      dueDate: _due,
      createdAt: old?.createdAt ?? DateTime.now(),
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.task == null ? 'Nouvelle tâche' : 'Modifier la tâche',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: 'Titre',
              errorText: _error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.event_rounded),
                  label: Text(
                    _due == null
                        ? 'Ajouter une échéance'
                        : 'Échéance : ${formatDue(_due!)}',
                  ),
                ),
              ),
              if (_due != null)
                IconButton(
                  tooltip: 'Retirer l’échéance',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => setState(() => _due = null),
                ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

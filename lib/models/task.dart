class Task {
  final String id;
  final String title;
  final bool done;
  final DateTime? dueDate;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    required this.done,
    required this.dueDate,
    required this.createdAt,
  });

  Task copyWith({String? title, bool? done}) {
    return Task(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
      dueDate: dueDate,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    final due = json['dueDate'] as String?;
    return Task(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      done: (json['done'] as bool?) ?? false,
      dueDate: due == null ? null : DateTime.tryParse(due),
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

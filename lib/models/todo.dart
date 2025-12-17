import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

enum TodoPriority { low, medium, high }

@freezed
class Todo with _$Todo {
  const Todo._();

  const factory Todo({
    int? id,
    required String title,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
    @Default(TodoPriority.medium) TodoPriority priority,
    DateTime? dueDate,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  Map<String, dynamic> toSqlite() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'priority': priority.index,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory Todo.fromSqlite(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      title: map['title'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      priority: TodoPriority.values[map['priority'] as int? ?? 1],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
    );
  }
}

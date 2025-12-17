import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_geh/models/todo.dart';
import 'package:todo_geh/services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper());

class TodoNotifier extends AsyncNotifier<List<Todo>> {
  late final DatabaseHelper _db;

  @override
  Future<List<Todo>> build() async {
    _db = ref.read(databaseServiceProvider);
    return _fetchTodos();
  }

  Future<List<Todo>> _fetchTodos() async {
    return await _db.getTodos();
  }

  Future<void> addTodo(String title, [TodoPriority priority = TodoPriority.medium, DateTime? dueDate]) async {
    final todo = Todo(
      title: title, 
      createdAt: DateTime.now(),
      isCompleted: false,
      priority: priority,
      dueDate: dueDate,
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _db.insertTodo(todo);
      return _fetchTodos();
    });
  }

  Future<void> toggleTodo(Todo todo) async {
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    final previousState = state;
    state = AsyncValue.data([
      for (final t in state.value ?? [])
        if (t.id == todo.id) updatedTodo else t
    ]);

    try {
      await _db.updateTodo(updatedTodo);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> updateTodoDetails(Todo todo) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _db.updateTodo(todo);
      return _fetchTodos();
    });
  }

  Future<void> deleteTodo(int id) async {
    final previousState = state;
    state = AsyncValue.data([
      for (final t in state.value ?? [])
        if (t.id != id) t
    ]);

    try {
      await _db.deleteTodo(id);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }
}

final todoListProvider = AsyncNotifierProvider<TodoNotifier, List<Todo>>(() {
  return TodoNotifier();
});

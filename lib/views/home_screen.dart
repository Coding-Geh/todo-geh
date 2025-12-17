import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:todo_geh/models/todo.dart';
import 'package:todo_geh/viewmodels/theme_viewmodel.dart';
import 'package:todo_geh/viewmodels/todo_viewmodel.dart';

import 'package:todo_geh/views/add_todo_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('title').tr(),
        actions: [
          IconButton(
            icon: Icon(themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).setTheme(
                    themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
                  );
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              if (context.locale.languageCode == 'en') {
                context.setLocale(const Locale('id', 'ID'));
              } else {
                context.setLocale(const Locale('en', 'US'));
              }
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: todosAsync.when(
            data: (todos) {
              if (todos.isEmpty) {
                 return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task, size: 64, color: Theme.of(context).disabledColor),
                      const SizedBox(height: 16),
                      Text('home.empty'.tr(), style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ).animate().fadeIn();
              }
              return ListView.builder(
                itemCount: todos.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Dismissible(
                    key: Key('todo-${todo.id}'),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                             title: Text('home.delete_confirm'.tr()), 
                             actions: <Widget>[
                               TextButton(
                                 onPressed: () => Navigator.of(context).pop(false),
                                 child: Text('home.delete_no'.tr()),
                               ),
                               FilledButton(
                                 onPressed: () => Navigator.of(context).pop(true),
                                 child: Text('home.delete_yes'.tr()),
                               ),
                             ],
                          );
                        },
                      );
                    },
                    onDismissed: (_) {
                      ref.read(todoListProvider.notifier).deleteTodo(todo.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('home.snack_deleted'.tr()),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (_) {
                         ref.read(todoListProvider.notifier).toggleTodo(todo);
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                             content: Text(
                               todo.isCompleted 
                                 ? 'home.snack_uncompleted'.tr() 
                                 : 'home.snack_completed'.tr(),
                             ),
                             duration: const Duration(seconds: 2),
                             behavior: SnackBarBehavior.floating,
                           ),
                         );
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        color: todo.isCompleted ? Theme.of(context).disabledColor : null,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todo.dueDate != null)
                          Text(
                            '${'todo.date.due'.tr()}: ${DateFormat.yMMMd().format(todo.dueDate!)}',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                          ),
                        const SizedBox(height: 4),
                        Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: _getPriorityColor(todo.priority).withAlpha(38),
                             borderRadius: BorderRadius.circular(6),
                             border: Border.all(
                               color: _getPriorityColor(todo.priority).withAlpha(102),
                               width: 1,
                             ),
                           ),
                           child: Text(
                             'todo.priority.${todo.priority.name}'.tr().toUpperCase(),
                             style: TextStyle(
                               fontSize: 11, 
                               fontWeight: FontWeight.w600,
                               letterSpacing: 0.5,
                               color: _getPriorityColor(todo.priority),
                             ),
                           ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Theme.of(context).colorScheme.error,
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                               title: Text('home.delete_confirm'.tr()),
                               actions: <Widget>[
                                 TextButton(
                                   onPressed: () => Navigator.of(context).pop(false),
                                   child: Text('home.delete_no'.tr()),
                                 ),
                                 FilledButton(
                                   onPressed: () => Navigator.of(context).pop(true),
                                   child: Text('home.delete_yes'.tr()),
                                 ),
                               ],
                            );
                          },
                        );

                        if (confirm == true && context.mounted) {
                          ref.read(todoListProvider.notifier).deleteTodo(todo.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('home.snack_deleted'.tr()),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    onTap: () {
                       showDialog(
                        context: context,
                        builder: (context) => AddTodoDialog(todo: todo),
                      );
                    },
                  ),
                ).animate().slideX(begin: 0.1).fadeIn(duration: 200.ms),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () => launchUrl(Uri.parse('https://codinggeh.com')),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withAlpha(51),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Coding Geh',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '© ${DateTime.now().year} · ${'home.footer_rights'.tr()}',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'home.add_tooltip'.tr(),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddTodoDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return Colors.red;
      case TodoPriority.medium:
        return Colors.amber.shade700;
      case TodoPriority.low:
        return Colors.blue;
    }
  }
}

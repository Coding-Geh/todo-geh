import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:todo_geh/models/todo.dart';
import 'package:todo_geh/viewmodels/todo_viewmodel.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AddTodoDialog extends HookConsumerWidget {
  final Todo? todo;

  const AddTodoDialog({super.key, this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController(text: todo?.title ?? '');
    final priority = useState<TodoPriority>(todo?.priority ?? TodoPriority.medium);
    final dueDate = useState<DateTime?>(todo?.dueDate);
    
    return AlertDialog(
      title: Text(todo == null ? 'todo.new'.tr() : 'todo.edit'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'todo.title_hint'.tr(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<TodoPriority>(
                  initialValue: priority.value,
                  decoration: InputDecoration(labelText: 'todo.priority.label'.tr()),
                  items: TodoPriority.values.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text('todo.priority.${p.name}'.tr()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) priority.value = val;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate.value ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) dueDate.value = picked;
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(labelText: 'todo.date.due'.tr()),
                    child: Text(
                      dueDate.value != null
                          ? DateFormat.yMMMd().format(dueDate.value!)
                          : 'todo.date.select'.tr(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('todo.cancel'.tr()),
        ),
        FilledButton(
          onPressed: () {
            if (controller.text.trim().isEmpty) return;
            
            final isNew = todo == null;
            if (isNew) {
              ref.read(todoListProvider.notifier).addTodo(
                controller.text.trim(),
                priority.value,
                dueDate.value,
              );
            } else {
              ref.read(todoListProvider.notifier).updateTodoDetails(
                todo!.copyWith(
                  title: controller.text.trim(),
                  priority: priority.value,
                  dueDate: dueDate.value,
                ),
              );
            }
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isNew ? 'home.snack_added'.tr() : 'home.snack_updated'.tr(),
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Text('todo.save'.tr()),
        ),
      ],
    );
  }
}

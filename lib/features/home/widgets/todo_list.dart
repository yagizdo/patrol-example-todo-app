import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patrol_example_todo/features/delete_todo/cubit/delete_todo_cubit.dart';
import 'package:patrol_example_todo/features/home/cubit/todo_cubit.dart';
import '../../../models/todo_model.dart';
import './edit_todo_bottom_sheet.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;

  const TodoList({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return _TodoItem(todo: todo);
      },
    );
  }
}

class _TodoItem extends StatelessWidget {
  const _TodoItem({required this.todo});

  final Todo todo;

  void _showEditSheet(BuildContext context, Todo todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // This ensures the sheet is not height-constrained
      builder: (context) => EditTodoBottomSheet(todo: todo),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              if (todo.id == null) {
                Navigator.pop(context);
                return;
              }

              // Close the dialog first
              Navigator.pop(context);

              // Optimistically remove the todo from the UI
              final todoCubit = context.read<TodoCubit>();
              todoCubit.removeTodoFromState(todo.id!);

              // Delete the todo in the background
              final deleteCubit = context.read<DeleteTodoCubit>();
              await deleteCubit.deleteTodo(todo.id!);

              // If deletion failed, refresh the list to restore the todo
              if (!deleteCubit.state.isSuccess) {
                todoCubit.getTodos();
              }
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(todo.title ?? ""),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditSheet(context, todo),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
    );
  }
}

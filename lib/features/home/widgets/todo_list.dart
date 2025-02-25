import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/todo_model.dart';
import '../cubit/todo_cubit.dart';
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(todo.title),
      subtitle: Text(todo.description),
      leading: Checkbox(
        value: todo.isCompleted,
        onChanged: (_) {
          context.read<TodoCubit>().toggleTodoStatus(todo.id);
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditSheet(context, todo),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              context.read<TodoCubit>().deleteTodo(todo.id);
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:patrol_example_todo/models/todo_model.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key, required this.todos});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return _TodoItem(
          todo: todos[index],
        );
      },
    );
  }
}

class _TodoItem extends StatelessWidget {
  const _TodoItem({required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          todo.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          todo.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

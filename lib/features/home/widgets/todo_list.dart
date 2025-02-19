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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(todos[index].title),
            Text(todos[index].description),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:patrol_example_todo/features/home/widgets/todo_list.dart';
import 'package:patrol_example_todo/models/todo_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 64.0),
        child: Column(
          children: [
            Text(
              'Todo List',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Flexible(
              child: TodoList(
                todos: [
                  Todo(title: 'Todo 1', description: 'Description 1'),
                  Todo(title: 'Todo 2', description: 'Description 2'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

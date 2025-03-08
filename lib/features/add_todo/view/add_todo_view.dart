import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patrol_example_todo/features/add_todo/cubit/add_todo_cubit.dart';
import 'package:patrol_example_todo/models/todo_model.dart';

class AddTodoView extends StatefulWidget {
  const AddTodoView({super.key});

  @override
  State<AddTodoView> createState() => _AddTodoViewState();
}

class _AddTodoViewState extends State<AddTodoView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Todo')),
      body: Center(
        child: TextButton(
          onPressed: () {
            context.read<AddTodoCubit>().addTodo(Todo(
                  title: 'Test',
                  description: 'Test',
                  dueDate: '2025-01-01',
                  priority: TodoPriority.high,
                  status: TodoStatus.notStarted,
                  tags: ['Test'],
                ));
          },
          child: Text('Add Todo'),
        ),
      ),
    );
  }
}

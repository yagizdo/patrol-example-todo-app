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
  late final TextEditingController todoTitleController;
  late final TextEditingController todoDescriptionController;

  @override
  void initState() {
    super.initState();
    todoTitleController = TextEditingController();
    todoDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    todoTitleController.dispose();
    todoDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Todo')),
      body: Column(
        children: [
          _AddTodoTextField(
            labelText: 'Title',
            controller: todoTitleController,
          ),
          _AddTodoTextField(
            labelText: 'Description',
            controller: todoDescriptionController,
          ),
          _AddTodoButton(
            onPressed: _onAddTodoPressed,
          ),
        ],
      ),
    );
  }

  void _onAddTodoPressed() {
    if (todoTitleController.text.isEmpty) {
      return;
    }

    Todo todo = Todo(
      title: todoTitleController.text,
      description: todoDescriptionController.text.isEmpty
          ? 'Description'
          : todoDescriptionController.text,
      dueDate: DateTime.now().toIso8601String(),
      priority: TodoPriority.medium,
      status: TodoStatus.notStarted,
      userId: 1,
      tags: [],
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    context.read<AddTodoCubit>().addTodo(todo);
  }
}

class _AddTodoButton extends StatelessWidget {
  const _AddTodoButton({required this.onPressed});

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      child: const Text(
        'Add Todo',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class _AddTodoTextField extends StatelessWidget {
  const _AddTodoTextField({
    required this.labelText,
    this.onChanged,
    required this.controller,
  });

  final String labelText;
  final void Function(String)? onChanged;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

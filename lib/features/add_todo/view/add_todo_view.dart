import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patrol_example_todo/features/add_todo/cubit/add_todo_cubit.dart';
import 'package:patrol_example_todo/features/home/cubit/todo_cubit.dart';
import 'package:patrol_example_todo/models/todo_model.dart';

class AddTodoView extends StatefulWidget {
  const AddTodoView({super.key});

  @override
  State<AddTodoView> createState() => _AddTodoViewState();
}

class _AddTodoViewState extends State<AddTodoView> {
  late final TextEditingController todoTitleController;
  late final TextEditingController todoDescriptionController;
  late final AddTodoCubit _addTodoCubit;

  @override
  void initState() {
    super.initState();
    todoTitleController = TextEditingController();
    todoDescriptionController = TextEditingController();
    _addTodoCubit = context.read<AddTodoCubit>();
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
      body: BlocConsumer<AddTodoCubit, AddTodoState>(
        bloc: _addTodoCubit,
        listener: (context, state) {
          if (state.isSuccess) {
            context.read<TodoCubit>().getTodos();
            Navigator.pop(context);
            // Reset the state after navigation
            context.read<AddTodoCubit>().reset();
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
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
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SelectableText.rich(
                    TextSpan(
                      text: 'Error: ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: state.error,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
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

    _addTodoCubit.addTodo(todo);
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

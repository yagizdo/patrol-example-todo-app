import 'package:flutter/material.dart';
import 'package:patrol_example_todo/features/home/widgets/todo_list.dart';
import 'package:patrol_example_todo/models/todo_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/todo_cubit.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo App')),
      body: BlocBuilder<TodoCubit, TodoState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          return TodoList(todos: state.todos);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    // Show dialog to add new todo
    context.read<TodoCubit>().addTodo(
          Todo(
            id: DateTime.now().toString(),
            title: 'New Todo',
            description: '',
            isCompleted: false,
          ),
        );
  }
}

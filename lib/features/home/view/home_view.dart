import 'package:flutter/material.dart';
import 'package:patrol_example_todo/features/home/widgets/todo_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patrol_example_todo/models/todo_model.dart';
import '../cubit/todo_cubit.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    context.read<TodoCubit>().getTodos();
  }

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
    context.read<TodoCubit>().addTodo(
          Todo(
            title: 'New Todo2',
            description: 'New Todo Description',
            priority: 'High',
            status: 'In Progress',
            dueDate: DateTime.now().toString(),
            userId: 1,
            tags: ['tag1', 'tag2'],
          ),
        );
  }
}

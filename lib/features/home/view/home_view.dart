import 'package:flutter/material.dart';
import 'package:patrol_example_todo/features/home/widgets/todo_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // Show dialog to add new todo
    //   context.read<TodoCubit>().addTodo(
    //         Todo(
    //           id: DateTime.now().toString(),
    //           todo: 'New Todo',
    //           userId: 1,
    //           isCompleted: false,
    //         ),
    //       );
    // }
  }
}

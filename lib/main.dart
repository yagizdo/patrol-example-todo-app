import 'package:flutter/material.dart';
import 'package:patrol_example_todo/core/locator/app_locator.dart';
import 'package:patrol_example_todo/core/bl/repositories/todo_repo.dart';
import 'package:patrol_example_todo/features/add_todo/cubit/add_todo_cubit.dart';
import 'package:patrol_example_todo/features/home/view/home_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/home/cubit/todo_cubit.dart';

void main() {
  AppLocator.setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TodoCubit(
            todoRepo: AppLocator.locator<TodoRepo>(),
          ),
        ),
        BlocProvider(
          create: (context) => AddTodoCubit(
            todoRepo: AppLocator.locator<TodoRepo>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Patrol Example Todo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeView(),
      ),
    );
  }
}

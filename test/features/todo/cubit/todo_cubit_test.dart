import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_example_todo/features/home/cubit/todo_cubit.dart';
import 'package:patrol_example_todo/models/todo_model.dart';

import '../repo/todo_repo_mock.dart';

void main() {
  late TodoRepoMock todoRepoMock;
  late TodoCubit todoCubit;

  // Create mock todos for testing - adjust fields to match your actual Todo model
  final mockTodos = [
    Todo(title: 'Test Todo 1', description: 'Description 1'),
    Todo(title: 'Test Todo 2', description: 'Description 2'),
    Todo(title: 'Test Todo 3', description: 'Description 3'),
  ];

  setUp(() {
    todoRepoMock = TodoRepoMock();
    todoCubit = TodoCubit(todoRepo: todoRepoMock);
  });

  group('TodoCubit', () {
    test('[TodoCubit] should emit [TodoState] with todos', () async {
      when(() => todoRepoMock.fetchTodos()).thenAnswer((_) async => mockTodos);

      await todoCubit.getTodos();

      expect(todoCubit.state.todos, isNotEmpty);
      expect(todoCubit.state.todos.length, 3);
      expect(todoCubit.state.todos, mockTodos);
    });

    test('[TodoCubit] should not emit [TodoState] when fetchTodos fails',
        () async {
      when(() => todoRepoMock.fetchTodos()).thenThrow('Error');

      await todoCubit.getTodos();

      expect(todoCubit.state.error, isNotEmpty);
      expect(todoCubit.state.error, 'Error');
    });
  });
}

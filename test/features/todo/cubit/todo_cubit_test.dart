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
    Todo(id: '1', title: 'Test Todo 1', description: 'Description 1'),
    Todo(id: '2', title: 'Test Todo 2', description: 'Description 2'),
    Todo(id: '3', title: 'Test Todo 3', description: 'Description 3'),
  ];

  setUp(() {
    todoRepoMock = TodoRepoMock();
    todoCubit = TodoCubit(todoRepo: todoRepoMock);
  });

  group('TodoCubit Fetch Todos', () {
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

    test(
        '[TodoCubit] should remove a todo from the state when removeTodoFromState is called',
        () async {
      // First, set up the initial state with todos by mocking the getTodos method
      when(() => todoRepoMock.fetchTodos()).thenAnswer((_) async => mockTodos);
      await todoCubit.getTodos();

      // Verify initial state has all todos
      expect(todoCubit.state.todos.length, 3);

      // Call the method under test
      todoCubit.removeTodoFromState(mockTodos[0].id!);

      // Verify the todo was removed
      expect(todoCubit.state.todos, isNotEmpty);
      expect(todoCubit.state.todos.length, 2);
      expect(todoCubit.state.todos.any((todo) => todo.id == mockTodos[0].id),
          isFalse);
    });
  });
}

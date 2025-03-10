import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_example_todo/features/add_todo/cubit/add_todo_cubit.dart';
import 'package:patrol_example_todo/models/todo_model.dart';

import '../../todo/repo/todo_repo_mock.dart';

void main() {
  late TodoRepoMock todoRepoMock;
  late AddTodoCubit addTodoCubit;

  final newTodo = Todo(
    title: 'Test Todo 4',
    description: 'Description 4',
  );

  setUp(() {
    todoRepoMock = TodoRepoMock();
    addTodoCubit = AddTodoCubit(todoRepo: todoRepoMock);
  });

  group('AddTodoCubit', () {
    test('should emit state with success status when addTodo succeeds',
        () async {
      when(() => todoRepoMock.addTodo(newTodo)).thenAnswer((_) async => {});

      await addTodoCubit.addTodo(newTodo);

      expect(addTodoCubit.state.isSuccess, isTrue);
      expect(addTodoCubit.state.isLoading, isFalse);
      expect(addTodoCubit.state.error, isNull);
    });

    test('should emit state with error when addTodo fails', () async {
      when(() => todoRepoMock.addTodo(newTodo)).thenThrow('Error');

      await addTodoCubit.addTodo(newTodo);

      expect(addTodoCubit.state.error, isNotEmpty);
      expect(addTodoCubit.state.error, 'Error');
    });

    test('Should reset the state when reset is called', () {
      addTodoCubit.reset();

      expect(addTodoCubit.state.isSuccess, isFalse);
      expect(addTodoCubit.state.isLoading, isFalse);
      expect(addTodoCubit.state.error, isNull);
    });
  });
}

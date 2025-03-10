import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:patrol_example_todo/features/add_todo/cubit/add_todo_cubit.dart';
import 'package:patrol_example_todo/models/todo_model.dart';

import '../../todo/repo/todo_repo_mock.dart';

/// This test file verifies the behavior of the AddTodoCubit and AddTodoState classes.
///
/// The tests ensure that:
/// 1. The AddTodoCubit correctly transitions through states during addTodo operations
/// 2. The AddTodoCubit properly handles success and error cases
/// 3. The reset functionality works as expected
/// 4. The AddTodoState's copyWith method correctly updates state properties
void main() {
  // Declare test variables that will be initialized in setUp
  late TodoRepoMock todoRepoMock;
  late AddTodoCubit addTodoCubit;

  // Sample todo object used for testing
  final newTodo = Todo(
    title: 'Test Todo 4',
    description: 'Description 4',
  );

  // This function runs before each test to provide a fresh instance of dependencies
  setUp(() {
    // Create a mock of TodoRepo to simulate repository behavior without actual API calls
    todoRepoMock = TodoRepoMock();
    // Initialize the cubit with the mock repository
    addTodoCubit = AddTodoCubit(todoRepo: todoRepoMock);
  });

  group('AddTodoCubit', () {
    // Test the successful flow of adding a todo
    test(
        'emits loading then success states when addTodo completes successfully',
        () async {
      // ARRANGE: Set up the test conditions
      // Configure the mock to return successfully when addTodo is called
      when(() => todoRepoMock.addTodo(newTodo)).thenAnswer((_) async => {});

      // Set up a listener to capture all state changes during the test
      // This allows us to verify the sequence of states emitted by the cubit
      final states = <AddTodoState>[];
      final subscription = addTodoCubit.stream.listen(states.add);

      // Verify the initial state before any action
      expect(addTodoCubit.state.isLoading, isFalse,
          reason: 'Initial state should not be loading');
      expect(addTodoCubit.state.isSuccess, isFalse,
          reason: 'Initial state should not indicate success');
      expect(addTodoCubit.state.error, isNull,
          reason: 'Initial state should not have an error');

      // ACT: Perform the action being tested
      await addTodoCubit.addTodo(newTodo);

      // Wait for all state changes to be processed
      // This ensures that all asynchronous state emissions are captured
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      // ASSERT: Verify the expected outcomes
      // Check that exactly 2 states were emitted (loading and success)
      expect(states.length, 2,
          reason: 'Should emit exactly 2 states: loading and success');

      // Verify the first emitted state (loading state)
      expect(states[0].isLoading, isTrue,
          reason: 'First state should be loading');
      expect(states[0].isSuccess, isFalse,
          reason: 'First state should not indicate success');
      expect(states[0].error, isNull,
          reason: 'First state should not have an error');

      // Verify the second emitted state (success state)
      expect(states[1].isLoading, isFalse,
          reason: 'Second state should not be loading');
      expect(states[1].isSuccess, isTrue,
          reason: 'Second state should indicate success');
      expect(states[1].error, isNull,
          reason: 'Second state should not have an error');

      // Verify the final state of the cubit
      expect(addTodoCubit.state.isSuccess, isTrue,
          reason: 'Final state should indicate success');
      expect(addTodoCubit.state.isLoading, isFalse,
          reason: 'Final state should not be loading');
      expect(addTodoCubit.state.error, isNull,
          reason: 'Final state should not have an error');

      // Verify that the repository method was called exactly once
      verify(() => todoRepoMock.addTodo(newTodo)).called(1);
    });

    // Test the error flow of adding a todo
    test('emits loading then error states when addTodo fails', () async {
      // ARRANGE: Set up the test conditions
      // Configure the mock to throw an error when addTodo is called
      const errorMessage = 'Error';
      when(() => todoRepoMock.addTodo(newTodo)).thenThrow(errorMessage);

      // Set up a listener to capture all state changes during the test
      final states = <AddTodoState>[];
      final subscription = addTodoCubit.stream.listen(states.add);

      // Verify the initial state before any action
      expect(addTodoCubit.state.isLoading, isFalse,
          reason: 'Initial state should not be loading');
      expect(addTodoCubit.state.isSuccess, isFalse,
          reason: 'Initial state should not indicate success');
      expect(addTodoCubit.state.error, isNull,
          reason: 'Initial state should not have an error');

      // ACT: Perform the action being tested
      await addTodoCubit.addTodo(newTodo);

      // Wait for all state changes to be processed
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      // ASSERT: Verify the expected outcomes
      // Check that exactly 2 states were emitted (loading and error)
      expect(states.length, 2,
          reason: 'Should emit exactly 2 states: loading and error');

      // Verify the first emitted state (loading state)
      expect(states[0].isLoading, isTrue,
          reason: 'First state should be loading');
      expect(states[0].isSuccess, isFalse,
          reason: 'First state should not indicate success');
      expect(states[0].error, isNull,
          reason: 'First state should not have an error');

      // Verify the second emitted state (error state)
      expect(states[1].isLoading, isFalse,
          reason: 'Second state should not be loading');
      expect(states[1].isSuccess, isFalse,
          reason: 'Second state should not indicate success');
      expect(states[1].error, errorMessage,
          reason: 'Second state should contain the error message');

      // Verify the final state of the cubit
      expect(addTodoCubit.state.error, errorMessage,
          reason: 'Final state should contain the error message');
      expect(addTodoCubit.state.isLoading, isFalse,
          reason: 'Final state should not be loading');
      expect(addTodoCubit.state.isSuccess, isFalse,
          reason: 'Final state should not indicate success');

      // Verify that the repository method was called exactly once
      verify(() => todoRepoMock.addTodo(newTodo)).called(1);
    });

    // Test the reset functionality of the cubit
    test('resets state to initial values when reset is called', () {
      // ARRANGE: Set up the test conditions
      // First set a non-initial state to verify that reset actually changes the state
      addTodoCubit.emit(const AddTodoState(
        isLoading: true,
        isSuccess: true,
        error: 'Some error',
      ));

      // ACT: Perform the action being tested
      addTodoCubit.reset();

      // ASSERT: Verify the expected outcomes
      // Verify that all state properties are reset to their initial values
      expect(addTodoCubit.state.isSuccess, isFalse,
          reason: 'isSuccess should be reset to false');
      expect(addTodoCubit.state.isLoading, isFalse,
          reason: 'isLoading should be reset to false');
      expect(addTodoCubit.state.error, isNull,
          reason: 'error should be reset to null');
      expect(addTodoCubit.state.todo, const Todo(),
          reason: 'todo should be reset to an empty Todo');
    });
    // Test that the copyWith method correctly updates all state properties
    test('copyWith correctly updates all state properties', () {
      // Create an initial state and a test todo for verification
      const initialState = AddTodoState();
      final testTodo =
          Todo(title: 'Test Title', description: 'Test Description');

      // Test updating isLoading property
      expect(initialState.copyWith(isLoading: true).isLoading, true,
          reason: 'copyWith should update isLoading to true');
      expect(initialState.copyWith(isLoading: false).isLoading, false,
          reason: 'copyWith should update isLoading to false');

      // Test updating error property
      expect(initialState.copyWith(error: 'Test Error').error, 'Test Error',
          reason: 'copyWith should update error correctly');

      // Test updating isSuccess property
      expect(initialState.copyWith(isSuccess: true).isSuccess, true,
          reason: 'copyWith should update isSuccess to true');
      expect(initialState.copyWith(isSuccess: false).isSuccess, false,
          reason: 'copyWith should update isSuccess to false');

      // Test updating todo property
      expect(initialState.copyWith(todo: testTodo).todo, testTodo,
          reason: 'copyWith should update todo correctly');

      // Test that properties remain unchanged when not provided to copyWith
      // This is important for the "?? this.property" pattern in copyWith
      final modifiedState = initialState.copyWith(
        isLoading: true,
        error: 'Error',
        isSuccess: true,
        todo: testTodo,
      );

      final unchangedState = modifiedState.copyWith();
      expect(unchangedState.isLoading, true,
          reason:
              'isLoading should remain unchanged when not provided to copyWith');
      expect(unchangedState.error, 'Error',
          reason:
              'error should remain unchanged when not provided to copyWith');
      expect(unchangedState.isSuccess, true,
          reason:
              'isSuccess should remain unchanged when not provided to copyWith');
      expect(unchangedState.todo, testTodo,
          reason: 'todo should remain unchanged when not provided to copyWith');
    });
  });
}

// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:patrol_example_todo/features/home/cubit/todo_cubit.dart';
// import 'package:patrol_example_todo/models/todo_model.dart';

// import '../repo/todo_repo_mock.dart';

// void main() {
//   late TodoRepoMock todoRepoMock;
//   late TodoCubit todoCubit;

//   setUp(() {
//     todoRepoMock = TodoRepoMock();
//     todoCubit = TodoCubit(todoRepo: todoRepoMock);
//   });

//   group('TodoCubit', () {
//     test('[TodoCubit] should emit [TodoState] with todos', () async {
//       when(() => todoRepoMock.getTodos())
//           .thenAnswer((_) async => TodoResponse.mock().todos);

//       await todoCubit.getTodos();

//       expect(todoCubit.state.todos, isNotEmpty);
//       expect(todoCubit.state.todos.length, 3);
//       expect(todoCubit.state.todos, TodoResponse.mock().todos);
//     });
//     test('[TodoCubit] should not emit [TodoState] when getTodos fails',
//         () async {
//       when(() => todoRepoMock.getTodos()).thenThrow('Error');

//       await todoCubit.getTodos();

//       expect(todoCubit.state.error, isNotEmpty);
//       expect(todoCubit.state.error, 'Error');
//     });
//   });
// }

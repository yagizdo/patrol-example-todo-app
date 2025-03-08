import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patrol_example_todo/core/bl/repositories/todo_repo.dart';
import 'package:patrol_example_todo/models/todo_model.dart';

class AddTodoState extends Equatable {
  final Todo todo;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const AddTodoState({
    this.todo = const Todo(),
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  AddTodoState copyWith({
    Todo? todo,
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return AddTodoState(
      todo: todo ?? this.todo,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [todo, isLoading, error, isSuccess];
}

class AddTodoCubit extends Cubit<AddTodoState> {
  AddTodoCubit({required this.todoRepo}) : super(const AddTodoState());

  final TodoRepo todoRepo;

  Future<void> addTodo(Todo todo) async {
    emit(state.copyWith(isLoading: true));
    try {
      await todoRepo.addTodo(todo);
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void reset() {
    emit(const AddTodoState(
      isSuccess: false,
      isLoading: false,
      error: null,
      todo: Todo(),
    ));
  }
}

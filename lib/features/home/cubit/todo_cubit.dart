import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:patrol_example_todo/features/home/repo/todo_repo.dart';
import '../../../models/todo_model.dart';

class TodoState extends Equatable {
  final List<Todo> todos;
  final bool isLoading;
  final String? error;

  const TodoState({
    this.todos = const [],
    this.isLoading = false,
    this.error,
  });

  TodoState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    String? error,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [todos, isLoading, error];
}

class TodoCubit extends Cubit<TodoState> {
  TodoCubit() : super(const TodoState());

  final TodoRepo todoRepo = TodoRepo();

  Future<void> getTodos() async {
    emit(state.copyWith(isLoading: true));
    try {
      final todos = await todoRepo.getTodos();
      emit(state.copyWith(todos: todos, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }
}

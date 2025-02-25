import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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

  void addTodo(Todo todo) {
    final currentTodos = [...state.todos];
    currentTodos.add(todo);
    emit(state.copyWith(todos: currentTodos));
  }

  void deleteTodo(String id) {
    final currentTodos = [...state.todos];
    currentTodos.removeWhere((todo) => todo.id == id);
    emit(state.copyWith(todos: currentTodos));
  }

  void editTodo(Todo updatedTodo) {
    final currentTodos = [...state.todos];
    final todoIndex =
        currentTodos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (todoIndex != -1) {
      currentTodos[todoIndex] = updatedTodo;
      emit(state.copyWith(todos: currentTodos));
    }
  }

  void toggleTodoStatus(String id) {
    final currentTodos = [...state.todos];
    final todoIndex = currentTodos.indexWhere((todo) => todo.id == id);
    if (todoIndex != -1) {
      currentTodos[todoIndex] = currentTodos[todoIndex].copyWith(
        isCompleted: !currentTodos[todoIndex].isCompleted,
      );
      emit(state.copyWith(todos: currentTodos));
    }
  }
}

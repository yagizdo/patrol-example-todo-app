import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patrol_example_todo/core/bl/repositories/todo_repo.dart';

class DeleteTodoState extends Equatable {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const DeleteTodoState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  @override
  List<Object?> get props => [isLoading, error, isSuccess];

  DeleteTodoState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return DeleteTodoState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        isSuccess: isSuccess ?? this.isSuccess);
  }
}

class DeleteTodoCubit extends Cubit<DeleteTodoState> {
  DeleteTodoCubit({required this.todoRepo}) : super(const DeleteTodoState());

  final TodoRepo todoRepo;

  Future<void> deleteTodo(String id) async {
    emit(state.copyWith(isLoading: true));
    try {
      await todoRepo.deleteTodo(id);
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }
}

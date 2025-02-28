import 'package:equatable/equatable.dart';

class TodoResponse extends Equatable {
  final List<Todo> todos;
  final int total;
  final int skip;
  final int limit;

  const TodoResponse({
    required this.todos,
    required this.total,
    required this.skip,
    required this.limit,
  });

  @override
  List<Object?> get props => [todos, total, skip, limit];

  factory TodoResponse.fromJson(Map<String, dynamic> json) {
    return TodoResponse(
      todos: (json['todos'] as List).map((e) => Todo.fromJson(e)).toList(),
      total: json['total'],
      skip: json['skip'],
      limit: json['limit'],
    );
  }
}

class Todo extends Equatable {
  final String id;
  final String todo;
  final bool isCompleted;
  final int userId;

  const Todo({
    required this.id,
    required this.todo,
    required this.userId,
    this.isCompleted = false,
  });

  Todo copyWith({
    String? id,
    String? todo,
    bool? isCompleted,
    int? userId,
  }) {
    return Todo(
      id: id ?? this.id,
      todo: todo ?? this.todo,
      userId: userId ?? this.userId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, todo, userId, isCompleted];

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'].toString(),
      todo: json['todo'],
      userId: json['userId'],
      isCompleted: json['completed'],
    );
  }
}

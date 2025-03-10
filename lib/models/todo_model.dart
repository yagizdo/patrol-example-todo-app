import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String? id;
  final String? title;
  final String? description;
  final String? dueDate;
  final TodoPriority? priority;
  final TodoStatus? status;
  final List<String>? tags;
  final int? userId;
  final String? createdAt;
  final String? updatedAt;

  const Todo({
    this.id,
    this.title,
    this.description,
    this.dueDate,
    this.priority,
    this.status,
    this.userId,
    this.tags,
    this.createdAt,
    this.updatedAt,
  });

  Todo copyWith({
    String? title,
    String? description,
    String? dueDate,
    TodoPriority? priority,
    TodoStatus? status,
    List<String>? tags,
    int? userId,
    String? createdAt,
    String? updatedAt,
  }) {
    return Todo(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        priority,
        status,
        userId,
        tags,
        createdAt,
        updatedAt,
      ];

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'],
      priority: json['priority'] != null
          ? TodoPriorityExtension.fromString(json['priority'])
          : null,
      status: json['status'] != null
          ? TodoStatusExtension.fromString(json['status'])
          : null,
      userId: json['userId'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority?.name,
      'status': status?.name,
      'userId': userId,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

enum TodoStatus {
  notStarted,
  inProgress,
  completed,
}

extension TodoStatusExtension on TodoStatus {
  String get name {
    switch (this) {
      case TodoStatus.notStarted:
        return 'Not Started';
      case TodoStatus.inProgress:
        return 'In Progress';
      case TodoStatus.completed:
        return 'Completed';
    }
  }

  static TodoStatus fromString(String value) {
    return switch (value) {
      'Not Started' => TodoStatus.notStarted,
      'In Progress' => TodoStatus.inProgress,
      'Completed' => TodoStatus.completed,
      _ => throw ArgumentError('Invalid TodoStatus value: $value'),
    };
  }
}

enum TodoPriority {
  low,
  medium,
  high,
  critical,
}

extension TodoPriorityExtension on TodoPriority {
  String get name {
    switch (this) {
      case TodoPriority.low:
        return 'Low';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.high:
        return 'High';
      case TodoPriority.critical:
        return 'Critical';
    }
  }

  static TodoPriority fromString(String value) {
    return switch (value) {
      'Low' => TodoPriority.low,
      'Medium' => TodoPriority.medium,
      'High' => TodoPriority.high,
      'Critical' => TodoPriority.critical,
      _ => throw ArgumentError('Invalid TodoPriority value: $value'),
    };
  }
}

import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final String? title;
  final String? description;
  final String? dueDate;
  final String? priority;
  final String? status;
  final List<String>? tags;
  final int? userId;
  final String? createdAt;
  final String? updatedAt;

  const Todo({
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
    String? priority,
    String? status,
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
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate'],
      priority: json['priority'],
      status: json['status'],
      userId: json['userId'],
      tags: json['tags'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'status': status,
      'userId': userId,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

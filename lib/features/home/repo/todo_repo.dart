import 'package:dio/dio.dart';
import 'package:patrol_example_todo/models/todo_model.dart';

class TodoRepo {
  Future<List<Todo>> getTodos() async {
    Dio dio = Dio();
    final response =
        await dio.get('https://dummyjson.com/todos?limit=3&skip=10');
    final todoResponse = TodoResponse.fromJson(response.data);
    final todos = todoResponse.todos;

    return todos;
  }

  Future<void> addTodo(Todo todo) async {
    return;
  }

  Future<void> updateTodo(Todo todo) async {
    return;
  }

  Future<void> deleteTodo(String id) async {
    return;
  }

  Future<void> toggleTodoStatus(String id) async {
    return;
  }
}

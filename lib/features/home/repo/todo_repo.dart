import 'package:dio/dio.dart';
import 'package:patrol_example_todo/models/todo_model.dart';
import 'dart:convert';

/// Repository for handling Todo-related API operations
class TodoRepo {
  final Dio _dio;
  final String _baseUrl = 'https://shrimo.com/fake-api';

  /// Creates a TodoRepo with an optional Dio instance
  /// This allows for dependency injection and easier testing
  TodoRepo({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetches todos from the API
  /// Returns a list of Todo objects
  Future<List<Todo>> fetchTodos() async {
    try {
      final response = await _dio.get('$_baseUrl/todos');
      return _parseResponse(response);
    } on DioException catch (e) {
      throw _handleDioException(e, 'fetch todos');
    } catch (e) {
      throw Exception('Failed to fetch todos: $e');
    }
  }

  /// Parses API response and handles different response formats
  List<Todo> _parseResponse(Response response) {
    if (response.statusCode != 200) {
      throw Exception('Failed to load todos: ${response.statusCode}');
    }

    List<dynamic> jsonData;

    if (response.data is String) {
      jsonData = jsonDecode(response.data);
    } else if (response.data is List) {
      jsonData = response.data;
    } else {
      throw Exception(
          'Unexpected response format: ${response.data.runtimeType}');
    }

    return _convertAndParseTodos(jsonData);
  }

  /// Converts and parses JSON data to Todo objects
  List<Todo> _convertAndParseTodos(List<dynamic> jsonData) {
    final todos = <Todo>[];

    for (var item in jsonData) {
      try {
        // Convert tags from List<dynamic> to List<String> if present
        if (item['tags'] != null && item['tags'] is List) {
          item['tags'] =
              (item['tags'] as List).map((tag) => tag.toString()).toList();
        }
        todos.add(Todo.fromJson(item));
      } catch (e) {
        // Log error but continue processing other items
        print('Error parsing todo item: $e');
      }
    }

    return todos;
  }

  /// Handles Dio exceptions with descriptive error messages
  Exception _handleDioException(DioException e, String operation) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Network timeout while trying to $operation');
      case DioExceptionType.badResponse:
        return Exception(
            'Server error (${e.response?.statusCode}) while trying to $operation: ${e.response?.statusMessage}');
      case DioExceptionType.connectionError:
        return Exception('No internet connection while trying to $operation');
      default:
        return Exception(
            'Network error while trying to $operation: ${e.message}');
    }
  }
}

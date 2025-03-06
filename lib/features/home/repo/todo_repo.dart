import 'package:dio/dio.dart';
import 'package:patrol_example_todo/constants/string_constants.dart';
import 'package:patrol_example_todo/models/todo_model.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Repository for handling Todo-related API operations
class TodoRepo {
  final Dio _dio;

  /// Creates a TodoRepo with an optional Dio instance
  /// This allows for dependency injection and easier testing
  TodoRepo({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetches todos from the API
  /// Returns a list of Todo objects
  Future<List<Todo>> fetchTodos() async {
    try {
      final response = await _dio.get(TODOS_ENDPOINT);

      if (response.statusCode != 200) {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }

      // Parse response data based on its type
      final jsonData = _parseResponseData(response.data);

      // Convert JSON to Todo objects with error handling
      return _convertJsonToTodos(jsonData);
    } on DioException catch (e) {
      throw _createNetworkException(e, 'fetch todos');
    } catch (e) {
      throw Exception('Failed to fetch todos: $e');
    }
  }

  /// Parses response data to a List<dynamic> regardless of its original format
  List<dynamic> _parseResponseData(dynamic data) {
    if (data is String) {
      return jsonDecode(data);
    } else if (data is List) {
      return data;
    } else {
      throw Exception('Unexpected response format: ${data.runtimeType}');
    }
  }

  /// Converts JSON data to Todo objects with error handling for individual items
  List<Todo> _convertJsonToTodos(List<dynamic> jsonData) {
    return jsonData
        .map((item) {
          try {
            // Handle tags conversion
            if (item['tags'] != null && item['tags'] is List) {
              item['tags'] = List<String>.from(
                  (item['tags'] as List).map((tag) => tag.toString()));
            }
            return Todo.fromJson(item);
          } catch (e) {
            // Log error in debug mode
            if (kDebugMode) {
              print('Error parsing todo item: $e');
              print('Problematic JSON: $item');
            }
            // Return null for failed items
            return null;
          }
        })
        // Filter out null items and cast to List<Todo>
        .whereType<Todo>()
        .toList();
  }

  /// Creates a descriptive exception for network errors
  Exception _createNetworkException(DioException e, String operation) {
    final message = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Network timeout',
      DioExceptionType.badResponse =>
        'Server error (${e.response?.statusCode}): ${e.response?.statusMessage}',
      DioExceptionType.connectionError => 'No internet connection',
      _ => 'Network error: ${e.message}'
    };

    return Exception('$message while trying to $operation');
  }
}

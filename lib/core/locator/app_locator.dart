import 'package:get_it/get_it.dart';
import 'package:patrol_example_todo/core/bl/repositories/todo_repo.dart';

class AppLocator {
  static final locator = GetIt.instance;

  static void setup() {
    locator.registerLazySingleton(() => TodoRepo());
  }
}

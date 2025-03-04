import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol_example_todo/core/locator/app_locator.dart';
import 'package:patrol_example_todo/main.dart';

void main() {
  patrolSetUp(() {
    // Initialize GetIt before running tests
    AppLocator.setup();
  });
  patrolTest(
    'Should show the app title as a "Todo App"',
    ($) async {
      // Launch the app
      await $.pumpWidgetAndSettle(
        const MyApp(),
      );

      // Expect the app title to be "Todo App"
      expect($('Todo App'), findsOneWidget,
          reason: 'App title should be "Todo App"');
    },
  );
}

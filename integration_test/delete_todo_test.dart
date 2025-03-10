import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol_example_todo/core/locator/app_locator.dart';
import 'package:patrol_example_todo/main.dart';

void main() {
  // Set up the dependency injection before running tests
  // This ensures all required services are properly initialized
  patrolSetUp(() {
    AppLocator.setup();
  });

  group('DeleteTodoCubit', () {
    // Test case to verify todo deletion functionality
    patrolTest('When I delete a todo, it should be removed from the list',
        (tester) async {
      // Step 1: Launch the application and add a todo first
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Step 2: Add a todo to delete
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Todo to Delete');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Todo'));
      await tester.pumpAndSettle();

      // Step 3: Verify the todo was added
      expect(find.text('Todo to Delete'), findsOneWidget);

      // Step 4: Tap the delete icon on the todo item
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Step 5: Confirm deletion in the dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Step 6: Verify the todo was removed
      expect(find.text('Todo to Delete'), findsNothing);
    });
  });
}

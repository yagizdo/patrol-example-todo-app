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

  // Test case to verify the todo addition functionality
  patrolTest('When I add a todo, it should be added to the list',
      (tester) async {
    // Launch the application
    await tester.pumpWidget(const MyApp());
    // Wait for the app to stabilize
    await tester.pumpAndSettle();

    // Step 1: Tap the FAB with plus icon to navigate to the add todo screen
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
    await tester.pumpAndSettle();

    // Step 2: Enter text for the first todo item
    await tester.enterText(find.byType(TextField), 'Test Todo');
    // Wait to ensure the text is properly entered
    await tester.pumpAndSettle(duration: const Duration(seconds: 1));

    // Step 3: Tap the Add Todo button to add the todo
    await tester.tap(find.byType(ElevatedButton));
    // Wait for the save operation to complete and UI to update
    await tester.pumpAndSettle(duration: const Duration(seconds: 1));

    // Step 4: Verify the first todo was added successfully
    expect(find.text('Test Todo'), findsOneWidget);

    // Step 5: Add a second todo to verify multiple additions work
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
    await tester.pumpAndSettle(duration: const Duration(seconds: 1));

    // Step 6: Enter text for the second todo item
    await tester.enterText(find.byType(TextField), 'Test Todo 2');
    await tester.pumpAndSettle(duration: const Duration(seconds: 1));

    // Step 7: Save the second todo
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(duration: const Duration(seconds: 1));

    // Step 8: Verify the second todo was added successfully
    expect(find.text('Test Todo 2'), findsOneWidget);
  });
}

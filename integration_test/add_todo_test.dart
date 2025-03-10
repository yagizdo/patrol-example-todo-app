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
    // Step 1: Launch the application and wait for it to stabilize
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Step 2: Tap the FAB with plus icon to navigate to the add todo screen
    // The FloatingActionButton is located at the bottom right of the HomeView
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
    await tester.pumpAndSettle();

    // Step 3: Verify we're on the Add Todo screen by checking for the AppBar title
    expect(find.text('Add'), findsOneWidget);

    // Step 4: Enter text for the first todo item in the title field
    // We're targeting the first TextField which is for the title
    final titleTextField = find.byType(TextField).first;
    await tester.enterText(titleTextField, 'Test Todo');
    await tester.pumpAndSettle();

    // Step 5: Tap the Add Todo button to save the todo
    // The button is an ElevatedButton with text 'Add Todo'
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    // Step 6: Verify we're back on the home screen and the todo was added successfully
    // We should see the todo title in the list
    expect(find.text('Test Todo'), findsOneWidget);

    // Step 7: Add a second todo to verify multiple additions work
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
    await tester.pumpAndSettle();

    // Step 8: Enter text for the second todo item
    await tester.enterText(titleTextField, 'Test Todo 2');
    await tester.pumpAndSettle();

    // Step 9: Add a description for the second todo to test multiple fields
    final descriptionTextField = find.byType(TextField).at(1);
    await tester.enterText(descriptionTextField, 'This is a description');
    await tester.pumpAndSettle();

    // Step 10: Save the second todo
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    // Step 11: Verify the second todo was added successfully
    expect(find.text('Test Todo 2'), findsOneWidget);

    // Step 12: Verify both todos exist in the list
    expect(find.text('Test Todo'), findsOneWidget);
    expect(find.text('Test Todo 2'), findsOneWidget);

    // Step 13: Clean up - Delete the first todo
    // Tap the delete icon on the first todo item
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    // Confirm deletion in the dialog
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Step 14: Clean up - Delete the second todo
    // Now the second todo becomes the first in the list
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    // Confirm deletion in the dialog
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Step 15: Final verification - Ensure all test todos are removed
    expect(find.text('Test Todo'), findsNothing);
    expect(find.text('Test Todo 2'), findsNothing);
  });
}

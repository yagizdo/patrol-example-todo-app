import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol_example_todo/core/locator/app_locator.dart';
import 'package:patrol_example_todo/main.dart' as app;

void main() {
  patrolSetUp(() {
    AppLocator.setup();
  });

  patrolTest(
    'Take photo from camera test',
    (PatrolIntegrationTester tester) async {
      // Start the application
      await tester.pumpWidgetAndSettle(const app.MyApp());

      // Verify we are on the main screen
      expect(find.text('Todo App'), findsOneWidget,
          reason: 'Todo App title should be visible');

      // Tap on the image picker button
      await tester.tap(find.byKey(const Key('fileUploadButton')));
      await tester.pumpAndSettle();

      // Verify we are on the file upload screen
      expect(find.text('File Upload'), findsOneWidget,
          reason: 'File Upload title should be visible');

      // Wait for camera permission dialog to appear
      await Future.delayed(const Duration(milliseconds: 100));

      // Tap open camera button
      await tester.tap(find.byKey(const Key('cameraButton')));

      // Handle camera permission dialog if it appears
      if (await tester.native.isPermissionDialogVisible()) {
        // If tester.native.tap() is not working, use the following code
        // await tester.native.grantPermissionWhenInUse();
        await tester.native.tap(
          Selector(text: 'Allow'),
          appId: 'com.apple.springboard',
        );
      }

      // Wait for the camera to open
      await Future.delayed(const Duration(milliseconds: 100));

      // Wait for the camera to close
      await Future.delayed(const Duration(milliseconds: 100));

      expect(find.text('File Upload'), findsOneWidget,
          reason: 'File Upload title should be visible');
    },
  );
}

/// Extension to make it easier to work with NativeAutomator
///
/// This is a temporary extension to make it easier to work with NativeAutomator
/// until the NativeAutomator class is updated to support the new features.
///
/// Once the NativeAutomator class is updated, this extension should be removed.
///
/// // Tap on the cancel button example using the extension
/// await tester.native.tapIfExists('Cancel');
extension NativeAutomatorEx on NativeAutomator {
  // Check if a native view exists
  Future<bool> exists(Selector selector, {String? appId}) async =>
      (await getNativeViews(selector, appId: appId)).isNotEmpty;

  // Tap on a native view if it exists
  Future<void> tapIfExists(String text) async {
    // Create a selector for the native view
    final selector = Selector(text: text);

    // If the native view exists, tap on it
    if (await exists(selector)) {
      await tap(selector);
    }
  }
}

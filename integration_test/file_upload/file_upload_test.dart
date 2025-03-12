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
    'File upload test',
    (PatrolIntegrationTester $) async {
      // Start the application
      await $.pumpWidget(const app.MyApp());
      await $.pumpAndSettle();

      // Verify we are on the main screen
      expect(find.text('Todo App'), findsOneWidget);

      // Tap on the file upload button
      await $(Key('fileUploadButton')).tap();
      await $.pumpAndSettle();

      // Verify we are on the file upload screen
      expect(find.text('Dosya Yükleme'), findsOneWidget);

      // Tap on the pick file button
      await $(Key('pickFileButton')).tap();

      // When the file picker opens, native interaction is required
      // This part varies depending on the device and operating system

      // Example for Android:
      // try {
      //   // If permission dialog appears (Android)
      //   await $.native.grantPermissionWhenInUse();
      //   await $.pumpAndSettle();
      // } catch (e) {
      //   // Permission dialog may not appear, continue in this case
      // }

      // // Check if the file picker is visible (on iOS need to check On My iPhone text)
      // if (Platform.isIOS) {
      //   expect(find.text('On My iPhone'), findsOneWidget);
      // } else {
      //   // Need to add Android example
      // }

      await $.native.tap(Selector(textContains: 'test-pdf'));

      await $.pumpAndSettle();

      expect(find.text('Dosya Yükleme'), findsOneWidget);

      expect(find.text('Seçilen Dosya: test-pdf.pdf'), findsOneWidget);

      // expect(find.text('This document is password protected'), findsOneWidget);

      // await $.native.tap(Selector(text: 'Done'));
    },
  );
}

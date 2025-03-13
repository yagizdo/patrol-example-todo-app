import 'dart:io';

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
      print('Permission dialog visible mi');

      // Handle camera permission dialog if it appears
      if (await tester.native.isPermissionDialogVisible()) {
        print('Permission dialog visible');
        await tester.native.grantPermissionWhenInUse();
        //   await tester.native.tap(
        //     Selector(text: 'Allow'),
        //     appId: 'com.apple.springboard',
        //   );
        // }
      }

      await tester.native.tap(
        Selector(text: 'Cancel'),
        //appId: 'com.apple.springboard',
      );

      expect(find.text('File Upload'), findsOneWidget,
          reason: 'File Upload title should be visible');
    },
  );
}

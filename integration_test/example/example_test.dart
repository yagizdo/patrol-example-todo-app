import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol_example_todo/core/locator/app_locator.dart';
import 'package:patrol_example_todo/main.dart';

void main() {
  patrolSetUp(() {
    // Initialize GetIt before running tests
    // This ensures all dependencies are properly registered
    AppLocator.setup();
  });

  patrolTest(
      'Open native home screen and after notification and than back to app',
      // The fullyLive policy ensures animations run smoothly during the test
      // This is important for tests that interact with native UI elements
      framePolicy: LiveTestWidgetsFlutterBindingFramePolicy.fullyLive,
      (tester) async {
    /*
    PATROL INTEGRATION TEST GUIDE
    ============================
    
    UNDERSTANDING PUMP METHODS:
    --------------------------
    
    1. pump() - Triggers a single frame update
       - Advances time by the specified duration (or a single frame if not specified)
       - Does not automatically process microtasks or timers
       - Use for precise control over animation timing
       - Example: await tester.pump(Duration(milliseconds: 16)); // Advance one frame at 60fps
    
    2. pumpAndSettle() - Repeatedly calls pump() until the UI is stable
       - Waits for all animations, timers, and microtasks to complete
       - Has a default timeout (can be customized with duration parameter)
       - Will throw an exception if UI doesn't stabilize within the timeout
       - CRITICAL: Will hang indefinitely when app is backgrounded because the Flutter
         engine is paused, so animations never complete
       - Example: await tester.pumpAndSettle(duration: Duration(seconds: 5));
    
    3. pumpWidget() - Builds and renders a widget for testing
       - Creates a new widget tree with the provided widget as root
       - Does not wait for the UI to stabilize
       - Primarily used in widget tests rather than integration tests
       - Example: await tester.pumpWidget(MyWidget());
    
    4. pumpWidgetAndSettle() - Combines pumpWidget() and pumpAndSettle()
       - Creates a widget tree and waits for it to stabilize
       - Perfect for initial app launch in integration tests
       - Example: await tester.pumpWidgetAndSettle(const MyApp());
    
    NATIVE AUTOMATION BEST PRACTICES:
    -------------------------------
    
    1. App Backgrounding:
       - When app is backgrounded (pressHome), the Flutter engine is paused
       - Never use pumpAndSettle() when app is backgrounded
       - Use Future.delayed() instead for timing between native operations
       - Example: await Future.delayed(Duration(milliseconds: 500));
    
    2. Notifications:
       - Opening notifications (openNotifications) backgrounds your app
       - Closing notifications (closeNotifications) doesn't automatically return to your app
       - You must explicitly reopen your app with openApp()
       - Example: await tester.native.openApp(appId: 'com.example.myapp');
    
    3. App Bundle ID:
       - Must use the correct bundle ID format for each platform
       - Android: typically lowercase with underscores (com.example.my_app)
       - iOS: typically camelCase (com.example.myApp)
       - Incorrect bundle ID will cause openApp() to fail silently
    
    4. Verification:
       - After returning to the app, verify UI elements are visible
       - Use waitUntilVisible() instead of expectVisible() for more reliability
       - Example: await tester.waitUntilVisible(find.text('Welcome'));
    
    TROUBLESHOOTING COMMON ISSUES:
    ----------------------------
    
    1. Test hangs indefinitely:
       - Most likely using pumpAndSettle() when app is backgrounded
       - Solution: Replace with Future.delayed() or remove entirely
    
    2. Can't return to app after closing notifications:
       - Incorrect bundle ID or app not properly reopened
       - Solution: Verify bundle ID and ensure openApp() is called
    
    3. Flaky tests (sometimes pass, sometimes fail):
       - Timing issues with native operations
       - Solution: Add appropriate delays between operations
       - Solution: Use waitUntilVisible() instead of immediate assertions
    
    4. Permission dialogs interfering with test:
       - Add handling for permission dialogs
       - Example: if (await tester.native.isPermissionDialogVisible()) {
                    await tester.native.tapOnPermissionDialog(accept: true);
                  }
    */

    // STEP 1: LAUNCH THE APP
    // Launch the app and wait for it to be fully loaded and idle
    // This is the initial state of our test
    await tester.pumpWidgetAndSettle(const MyApp());

    // STEP 2: BACKGROUND THE APP
    // Press the home button to send the app to the background
    // This simulates the user pressing the home button on their device
    await tester.native.pressHome();

    // Add a small delay to ensure the home screen is fully visible
    // We use Future.delayed instead of pumpAndSettle because the app is backgrounded
    await Future.delayed(const Duration(milliseconds: 500));

    // STEP 3: OPEN NOTIFICATIONS
    // Pull down the notification shade
    // This simulates the user swiping down from the top of the screen
    await tester.native.openNotifications();

    // Add a small delay to ensure notifications are fully visible
    // Again, we use Future.delayed because the app is still backgrounded
    await Future.delayed(const Duration(milliseconds: 500));

    // STEP 4: CLOSE NOTIFICATIONS
    // Close the notification panel
    // This simulates the user swiping up or pressing back to dismiss notifications
    await tester.native.closeNotifications();

    // Add a small delay to ensure notifications are fully closed
    // The app is still backgrounded at this point
    await Future.delayed(const Duration(milliseconds: 500));

    // STEP 5: REOPEN THE APP
    // Determine the correct app ID based on the platform
    // This is critical for the openApp() method to work correctly
    final appId = Platform.isAndroid
        ? 'com.example.patrol_example_todo' // Android format (lowercase with underscores)
        : 'com.example.patrolExampleTodo'; // iOS format (camelCase)

    // Open the app using the correct bundle ID
    // This simulates the user tapping on the app icon from the home screen
    await tester.native.openApp(appId: appId);

    // STEP 6: VERIFY APP STATE
    // Now that we're back in the app, we can use pumpAndSettle()
    // This ensures the app is fully loaded before continuing
    await tester.pumpAndSettle(duration: const Duration(seconds: 2));

    // Verify we're back in the app by checking for UI elements
    // First approach: using standard Flutter test expectations
    expect(find.byType(AppBar), findsOneWidget,
        reason: 'AppBar should be visible');
    expect(find.text('Todo App'), findsOneWidget,
        reason: 'App title should be visible');

    // Second approach: using Patrol's waitUntilVisible
    // This is more reliable as it waits for the element to appear with a timeout
    await tester.waitUntilVisible(find.text('Todo App'));

    // Test is complete - we've successfully:
    // 1. Launched the app
    // 2. Backgrounded it
    // 3. Opened notifications
    // 4. Closed notifications
    // 5. Returned to the app
    // 6. Verified the app is in the expected state
  });
}

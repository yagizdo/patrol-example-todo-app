import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol_example_todo/main.dart';

void main() {
  patrolTest(
    'counter state is the same after going to home and switching apps',
    ($) async {
      await $.pumpWidgetAndSettle(
        const MyApp(),
      );

      expect($('app'), findsOneWidget);
      if (!Platform.isIOS) {
        await $.native.pressHome();
      }
    },
  );
}

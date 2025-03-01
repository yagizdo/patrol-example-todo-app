import 'package:patrol/patrol.dart';
import 'package:patrol_example_todo/main.dart';

void main() {
  patrolTest("Fetch Todo UI", (p) async {
    await p.pumpWidget(const MyApp());
  });
}

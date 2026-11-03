import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';

void main() {
  testWidgets('ExpLabApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpLabApp());
    expect(find.text('🎮 3D Raycasting Maze'), findsOneWidget);
  });
}

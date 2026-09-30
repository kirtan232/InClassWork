import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:in_class_06/main.dart';

void main() {
  testWidgets('Smiley app renders and mood slider updates label',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmileyApp());

    expect(find.text('CustomPainter Smiley Lab'), findsOneWidget);
    expect(find.text('Mood: 0.80 (Happy)'), findsOneWidget);

    // Drag the mood slider all the way left.
    await tester.drag(find.byType(Slider).first, const Offset(-1000, 0));
    await tester.pump();
    expect(find.text('Mood: 0.00 (Sad)'), findsOneWidget);
  });

  testWidgets('Face style buttons switch without errors',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmileyApp());
    for (final label in ['Sleepy', 'Surprised', 'Classic']) {
      await tester.tap(find.text(label));
      await tester.pump();
    }
    expect(tester.takeException(), isNull);
  });

  test('shouldRepaint only when inputs change', () {
    final a = SmileyPainter(mood: 0.5);
    expect(a.shouldRepaint(SmileyPainter(mood: 0.5)), isFalse);
    expect(a.shouldRepaint(SmileyPainter(mood: 0.9)), isTrue);
    expect(
      a.shouldRepaint(SmileyPainter(mood: 0.5, faceStyle: FaceStyle.sleepy)),
      isTrue,
    );
  });
}

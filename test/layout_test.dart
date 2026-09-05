import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localbite/core/utils/layout.dart';

void main() {
  group('gridColumnsFor', () {
    test('uses one column on a phone in portrait', () {
      expect(gridColumnsFor(360), 1);
      expect(gridColumnsFor(411), 1);
      expect(gridColumnsFor(599), 1);
    });

    test('uses two columns on a phone in landscape', () {
      expect(gridColumnsFor(600), 2);
      expect(gridColumnsFor(892), 2);
    });

    test('uses three columns on a tablet', () {
      expect(gridColumnsFor(900), 3);
      expect(gridColumnsFor(1024), 3);
    });
  });

  testWidgets('layout changes when the screen is resized', (tester) async {
    Future<void> pumpAt(Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          home: LayoutBuilder(
            builder: (context, constraints) {
              final columns = gridColumnsFor(constraints.maxWidth);
              return Text('$columns', textDirection: TextDirection.ltr);
            },
          ),
        ),
      );
    }

    addTearDown(tester.view.reset);

    await pumpAt(const Size(411, 891));
    expect(find.text('1'), findsOneWidget);

    await pumpAt(const Size(891, 411));
    expect(find.text('2'), findsOneWidget);

    await pumpAt(const Size(1024, 1366));
    expect(find.text('3'), findsOneWidget);
  });
}

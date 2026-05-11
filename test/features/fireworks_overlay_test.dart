import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autism_avc_flutter/features/items/fireworks_overlay.dart';

void main() {
  group('FireworksOverlay', () {
    testWidgets('renders a CustomPaint widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: FireworksOverlay(),
            ),
          ),
        ),
      );

      expect(find.byType(FireworksOverlay), findsOneWidget);
      // CustomPaint exists as a descendant of the overlay
      expect(
        find.descendant(
          of: find.byType(FireworksOverlay),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('animation progresses without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: FireworksOverlay(),
            ),
          ),
        ),
      );

      // Advance partially through the 5-second animation
      await tester.pump(const Duration(seconds: 2));
      expect(
        find.descendant(
          of: find.byType(FireworksOverlay),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );

      // Advance past the end
      await tester.pump(const Duration(seconds: 4));
      expect(find.byType(FireworksOverlay), findsOneWidget);
    });

    testWidgets('does not intercept touch events (IgnorePointer)',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: Stack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => tapped = true,
                    child: const SizedBox.expand(),
                  ),
                  const FireworksOverlay(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tapAt(const Offset(200, 400));
      expect(tapped, isTrue);
    });

    testWidgets('cleans up animation controller on dispose', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: FireworksOverlay(),
            ),
          ),
        ),
      );

      // Replace with empty widget — should dispose without errors
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      // No crash == success
    });
  });
}

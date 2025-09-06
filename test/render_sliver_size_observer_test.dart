import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_size_observer/sliver_size_observer.dart';

void main() {
  group('RenderSliverSizeObserver', () {
    test('creates render object without errors', () {
      final renderObject = RenderSliverSizeObserver();
      expect(renderObject, isA<RenderSliverSizeObserver>());
      expect(renderObject.onSizeChanged, isNull);
    });

    test('creates render object with callback', () {
      void callback(double size) {
        // Callback for testing
      }

      final renderObject = RenderSliverSizeObserver(onSizeChanged: callback);
      expect(renderObject, isA<RenderSliverSizeObserver>());
      expect(renderObject.onSizeChanged, equals(callback));
    });

    test('updates onSizeChanged callback', () {
      void callback1(double size) {
        // First callback for testing
      }

      void callback2(double size) {
        // Second callback for testing
      }

      final renderObject = RenderSliverSizeObserver(onSizeChanged: callback1);
      expect(renderObject.onSizeChanged, equals(callback1));

      renderObject.onSizeChanged = callback2;
      expect(renderObject.onSizeChanged, equals(callback2));

      renderObject.onSizeChanged = null;
      expect(renderObject.onSizeChanged, isNull);
    });

    testWidgets('performLayout calls callback with geometry', (
      WidgetTester tester,
    ) async {
      double? reportedSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    reportedSize = size;
                  },
                  sliver: SliverToBoxAdapter(
                    child: Container(height: 50, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(reportedSize, isNotNull);
      expect(reportedSize, greaterThan(0));
    });

    testWidgets('does not call callback when onSizeChanged is null', (
      WidgetTester tester,
    ) async {
      final renderObject = RenderSliverSizeObserver(onSizeChanged: null);

      // Create a simple sliver child
      final childRenderObject = RenderSliverToBoxAdapter(
        child: RenderConstrainedBox(
          additionalConstraints: BoxConstraints.tight(Size(100, 50)),
          child: RenderLimitedBox(maxHeight: 50),
        ),
      );

      renderObject.child = childRenderObject;

      // Setup constraints
      const constraints = SliverConstraints(
        axisDirection: AxisDirection.down,
        growthDirection: GrowthDirection.forward,
        userScrollDirection: ScrollDirection.idle,
        scrollOffset: 0.0,
        precedingScrollExtent: 0.0,
        overlap: 0.0,
        remainingPaintExtent: 600.0,
        crossAxisExtent: 400.0,
        crossAxisDirection: AxisDirection.right,
        viewportMainAxisExtent: 600.0,
        remainingCacheExtent: 850.0,
        cacheOrigin: 0.0,
      );

      renderObject.layout(constraints);

      // Allow post-frame callbacks to execute
      await tester.binding.delayed(Duration.zero);

      // Should not throw any errors even without callback
      expect(renderObject.geometry, isNotNull);
    });

    testWidgets('handles multiple layout calls', (WidgetTester tester) async {
      final List<double> reportedSizes = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    reportedSizes.add(size);
                  },
                  sliver: SliverToBoxAdapter(
                    child: Container(height: 50, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      // Trigger another layout by scrolling
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -10));
      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(reportedSizes.length, greaterThanOrEqualTo(1));
      expect(reportedSizes.every((size) => size > 0), isTrue);
    });
  });
}

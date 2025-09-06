import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_size_observer/sliver_size_observer.dart';

void main() {
  group('RenderInitialMeasurableSliver', () {
    test('creates render object without errors', () {
      final renderObject = RenderInitialMeasurableSliver();
      expect(renderObject, isA<RenderInitialMeasurableSliver>());
      expect(renderObject.onInitialSizeChanged, isNull);
    });

    test('creates render object with callback', () {
      void callback(double size) {
        // Callback for testing
      }

      final renderObject = RenderInitialMeasurableSliver(
        onInitialSizeChanged: callback,
      );
      expect(renderObject, isA<RenderInitialMeasurableSliver>());
      expect(renderObject.onInitialSizeChanged, equals(callback));
    });

    test('updates onInitialSizeChanged callback', () {
      void callback1(double size) {
        // First callback for testing
      }

      void callback2(double size) {
        // Second callback for testing
      }

      final renderObject = RenderInitialMeasurableSliver(
        onInitialSizeChanged: callback1,
      );
      expect(renderObject.onInitialSizeChanged, equals(callback1));

      renderObject.onInitialSizeChanged = callback2;
      expect(renderObject.onInitialSizeChanged, equals(callback2));

      renderObject.onInitialSizeChanged = null;
      expect(renderObject.onInitialSizeChanged, isNull);
    });

    testWidgets('performLayout calls callback only once', (
      WidgetTester tester,
    ) async {
      int callCount = 0;
      double? reportedSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverInitialSizeObserver(
                  onInitialSizeChanged: (size) {
                    callCount++;
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

      // Trigger additional layouts
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverInitialSizeObserver(
                  onInitialSizeChanged: (size) {
                    callCount++;
                    reportedSize = size;
                  },
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      height: 100, // Different height
                      color: Colors.red,
                    ),
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
      expect(callCount, equals(1)); // Should only be called once
    });

    testWidgets('does not call callback when onInitialSizeChanged is null', (
      WidgetTester tester,
    ) async {
      final renderObject = RenderInitialMeasurableSliver(
        onInitialSizeChanged: null,
      );

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

    testWidgets('handles zero-size geometry', (WidgetTester tester) async {
      double? reportedSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverInitialSizeObserver(
                  onInitialSizeChanged: (size) {
                    reportedSize = size;
                  },
                  sliver: SliverToBoxAdapter(
                    child: Container(height: 0, color: Colors.blue),
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
      expect(reportedSize, equals(0));
    });

    testWidgets('first frame tracking works correctly', (
      WidgetTester tester,
    ) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverInitialSizeObserver(
                  onInitialSizeChanged: (size) {
                    callCount++;
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

      // Force multiple rebuilds - should not trigger more callbacks
      await tester.pump();
      await tester.pump();
      await tester.binding.delayed(Duration.zero);

      expect(callCount, equals(1));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_size_observer/sliver_size_observer.dart';

void main() {
  group('SliverInitialSizeObserver', () {
    testWidgets('creates widget without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverInitialSizeObserver(
                  sliver: SliverToBoxAdapter(
                    child: Container(height: 100, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SliverInitialSizeObserver), findsOneWidget);
    });

    testWidgets('calls onInitialSizeChanged callback only once', (
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
                    child: Container(height: 100, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Allow first frame to complete
      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      // Trigger another layout
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
                      height: 150, // Different height
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
      // Should only be called once for initial measurement
      expect(callCount, equals(1));
    });

    testWidgets('works with null onInitialSizeChanged callback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverInitialSizeObserver(
                  onInitialSizeChanged: null,
                  sliver: SliverToBoxAdapter(
                    child: Container(height: 100, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not throw any errors
      expect(find.byType(SliverInitialSizeObserver), findsOneWidget);
    });

    testWidgets('reports initial size correctly for different sliver types', (
      WidgetTester tester,
    ) async {
      double? observedSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverInitialSizeObserver(
                  onInitialSizeChanged: (size) {
                    observedSize = size;
                  },
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                        height: 50,
                        color: Colors.blue,
                        child: Text('Item $index'),
                      ),
                      childCount: 5,
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

      expect(observedSize, isNotNull);
      expect(observedSize, greaterThan(0));
    });

    testWidgets('updates callback when onInitialSizeChanged property changes', (
      WidgetTester tester,
    ) async {
      double? firstCallback;
      double? secondCallback;

      // First build with first callback
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverInitialSizeObserver(
                  onInitialSizeChanged: (size) {
                    firstCallback = size;
                  },
                  sliver: SliverToBoxAdapter(
                    child: Container(height: 100, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      // Second build with different callback
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverInitialSizeObserver(
                  onInitialSizeChanged: (size) {
                    secondCallback = size;
                  },
                  sliver: SliverToBoxAdapter(
                    child: Container(height: 100, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(firstCallback, isNotNull);
      // Second callback should not be called since it's not the initial measurement
      expect(secondCallback, isNull);
    });

    testWidgets('handles zero-height slivers', (WidgetTester tester) async {
      double? observedSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverInitialSizeObserver(
                  onInitialSizeChanged: (size) {
                    observedSize = size;
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

      expect(observedSize, isNotNull);
      expect(observedSize, equals(0));
    });

    testWidgets('works with complex sliver hierarchies', (
      WidgetTester tester,
    ) async {
      double? observedSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(height: 50, color: Colors.red),
                ),
                SliverInitialSizeObserver(
                  onInitialSizeChanged: (size) {
                    observedSize = size;
                  },
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          Container(color: Colors.blue, child: Text('$index')),
                      childCount: 4,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(height: 50, color: Colors.green),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(observedSize, isNotNull);
      expect(observedSize, greaterThan(0));
    });
  });
}

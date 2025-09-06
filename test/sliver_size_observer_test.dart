import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_size_observer/sliver_size_observer.dart';

void main() {
  group('SliverSizeObserver', () {
    testWidgets('creates widget without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  sliver: SliverToBoxAdapter(
                    child: Container(height: 100, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SliverSizeObserver), findsOneWidget);
    });

    testWidgets('calls onSizeChanged callback when size changes', (
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
                    child: Container(height: 100, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Allow frames to process
      await tester.pumpAndSettle();

      // Wait for post-frame callback
      await tester.binding.delayed(Duration.zero);

      expect(reportedSize, isNotNull);
      expect(reportedSize, greaterThan(0));
    });

    testWidgets('updates callback when onSizeChanged property changes', (
      WidgetTester tester,
    ) async {
      double? observedSize;

      // First build with first callback
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    observedSize = size;
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

      expect(observedSize, isNotNull);
      final firstSize = observedSize!;

      // Build with different callback and different content size
      observedSize = null;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    observedSize = size;
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

      expect(observedSize, isNotNull);
      expect(
        observedSize,
        isNot(equals(firstSize)),
      ); // Should be different size
    });

    testWidgets('works with null onSizeChanged callback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: null,
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
      expect(find.byType(SliverSizeObserver), findsOneWidget);
    });

    testWidgets('handles size changes during scrolling', (
      WidgetTester tester,
    ) async {
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
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                        height: 50,
                        color: index.isEven ? Colors.blue : Colors.red,
                        child: Text('Item $index'),
                      ),
                      childCount: 20,
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

      // Scroll down
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(reportedSizes, isNotEmpty);
    });

    testWidgets('reports correct size for different sliver types', (
      WidgetTester tester,
    ) async {
      double? observedSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    observedSize = size;
                  },
                  sliver: SliverAppBar(
                    expandedHeight: 200,
                    title: Text('Test App Bar'),
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
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_size_observer/sliver_size_observer.dart';

void main() {
  group('Usage Examples', () {
    testWidgets('Basic SliverSizeObserver usage', (WidgetTester tester) async {
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
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.blue,
                      child: Center(
                        child: Text(
                          'Observed Content',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
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
      expect(observedSize, equals(200.0));
    });

    testWidgets('SliverInitialSizeObserver with dynamic content', (
      WidgetTester tester,
    ) async {
      double? initialSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return CustomScrollView(
                  slivers: [
                    SliverInitialSizeObserver(
                      onInitialSizeChanged: (size) {
                        initialSize = size;
                      },
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => ListTile(
                            title: Text('Item ${index + 1}'),
                            subtitle: Text('Description for item ${index + 1}'),
                          ),
                          childCount: 3, // Fixed count for consistent testing
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(initialSize, isNotNull);
      expect(initialSize, greaterThan(0));

      final firstSize = initialSize!;

      // Reset and rebuild with different content
      initialSize = null;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverInitialSizeObserver(
                  onInitialSizeChanged: (size) {
                    initialSize =
                        size; // This should not be called for a new instance
                  },
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ListTile(
                        title: Text('Item ${index + 1}'),
                        subtitle: Text('Description for item ${index + 1}'),
                      ),
                      childCount: 6, // More items
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

      // New widget instance should trigger callback with new size
      expect(initialSize, isNotNull);
      expect(
        initialSize,
        greaterThan(firstSize),
      ); // Should be larger with more items
    });

    testWidgets('Observing collapsible app bar', (WidgetTester tester) async {
      final List<double> sizeChanges = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    sizeChanges.add(size);
                  },
                  sliver: SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text('Collapsible App Bar'),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        ListTile(title: Text('Content Item ${index + 1}')),
                    childCount: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      final initialSizeCount = sizeChanges.length;
      expect(sizeChanges, isNotEmpty);

      // Scroll to collapse the app bar
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -150));
      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(sizeChanges.length, greaterThan(initialSizeCount));
    });

    testWidgets('Observing grid layout changes', (WidgetTester tester) async {
      double? gridSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    gridSize = size;
                  },
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Card(
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      childCount: 6,
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

      expect(gridSize, isNotNull);
      expect(gridSize, greaterThan(0));
    });

    testWidgets('Conditional sliver observation', (WidgetTester tester) async {
      double? observedSize;
      bool shouldObserve = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                Widget sliver = SliverToBoxAdapter(
                  child: Container(
                    height: 150,
                    color: Colors.green,
                    child: Center(child: Text('Content')),
                  ),
                );

                if (shouldObserve) {
                  sliver = SliverSizeObserver(
                    onSizeChanged: (size) {
                      observedSize = size;
                    },
                    sliver: sliver,
                  );
                }

                return CustomScrollView(slivers: [sliver]);
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(observedSize, isNotNull);
      expect(observedSize, equals(150.0));

      // Reset and rebuild without observer
      observedSize = null;
      shouldObserve = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    height: 150,
                    color: Colors.green,
                    child: Center(child: Text('Content')),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(observedSize, isNull);
    });

    testWidgets('Multiple observers on the same sliver', (
      WidgetTester tester,
    ) async {
      double? firstObserverSize;
      double? secondObserverSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    firstObserverSize = size;
                  },
                  sliver: SliverSizeObserver(
                    onSizeChanged: (size) {
                      secondObserverSize = size;
                    },
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        height: 100,
                        color: Colors.orange,
                        child: Center(child: Text('Nested Observers')),
                      ),
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

      expect(firstObserverSize, isNotNull);
      expect(secondObserverSize, isNotNull);
      expect(firstObserverSize, equals(secondObserverSize));
    });
  });
}

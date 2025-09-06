import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_size_observer/sliver_size_observer.dart';

void main() {
  group('Integration Tests', () {
    testWidgets(
      'SliverSizeObserver and SliverInitialSizeObserver work together',
      (WidgetTester tester) async {
        double? initialSize;
        final List<double> continuousSizes = [];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverInitialSizeObserver(
                    onInitialSizeChanged: (size) {
                      initialSize = size;
                    },
                    sliver: SliverSizeObserver(
                      onSizeChanged: (size) {
                        continuousSizes.add(size);
                      },
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Container(
                            height: 100,
                            color: index.isEven ? Colors.blue : Colors.red,
                            child: Text('Item $index'),
                          ),
                          childCount: 10,
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

        // Scroll down
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
        await tester.pumpAndSettle();
        await tester.binding.delayed(Duration.zero);

        expect(initialSize, isNotNull);
        expect(initialSize, greaterThan(0));
        expect(continuousSizes, isNotEmpty);
        expect(continuousSizes.first, equals(initialSize));
      },
    );

    testWidgets('nested sliver observers work correctly', (
      WidgetTester tester,
    ) async {
      double? outerSize;
      double? innerSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    outerSize = size;
                  },
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Container(height: 50, color: Colors.red),
                      SizedBox(
                        height: 200,
                        child: CustomScrollView(
                          slivers: [
                            SliverSizeObserver(
                              onSizeChanged: (size) {
                                innerSize = size;
                              },
                              sliver: SliverToBoxAdapter(
                                child: Container(
                                  height: 100,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 50, color: Colors.green),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(outerSize, isNotNull);
      expect(innerSize, isNotNull);
      expect(outerSize, greaterThan(innerSize!));
    });

    testWidgets('works with different sliver types in sequence', (
      WidgetTester tester,
    ) async {
      final List<double> sizes = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) => sizes.add(size),
                  sliver: SliverAppBar(
                    expandedHeight: 200,
                    title: Text('App Bar'),
                  ),
                ),
                SliverSizeObserver(
                  onSizeChanged: (size) => sizes.add(size),
                  sliver: SliverToBoxAdapter(
                    child: Container(height: 100, color: Colors.blue),
                  ),
                ),
                SliverSizeObserver(
                  onSizeChanged: (size) => sizes.add(size),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          Container(color: Colors.green, child: Text('$index')),
                      childCount: 4,
                    ),
                  ),
                ),
                SliverSizeObserver(
                  onSizeChanged: (size) => sizes.add(size),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(
                        height: 50,
                        color: Colors.red,
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

      expect(sizes.length, greaterThanOrEqualTo(4));
      expect(sizes.every((size) => size >= 0), isTrue);
    });

    testWidgets('handles rapid size changes correctly', (
      WidgetTester tester,
    ) async {
      final List<double> sizes = [];
      bool isExpanded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Text('Toggle'),
                    ),
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverSizeObserver(
                            onSizeChanged: (size) => sizes.add(size),
                            sliver: SliverToBoxAdapter(
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                height: isExpanded ? 200 : 100,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
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

      final initialSizeCount = sizes.length;

      // Tap to expand
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      // Tap to collapse
      await tester.tap(find.text('Toggle'));
      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(sizes.length, greaterThan(initialSizeCount));
      expect(sizes.every((size) => size >= 0), isTrue);
    });

    testWidgets('performance test with many observers', (
      WidgetTester tester,
    ) async {
      final List<double> allSizes = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: List.generate(
                20,
                (index) => SliverSizeObserver(
                  onSizeChanged: (size) => allSizes.add(size),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      height: 50,
                      color: Colors.primaries[index % Colors.primaries.length],
                      child: Text('Item $index'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);
      stopwatch.stop();

      expect(allSizes.length, greaterThanOrEqualTo(20));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(5000),
      ); // Should be reasonably fast
    });

    testWidgets('memory cleanup test', (WidgetTester tester) async {
      double? lastSize;

      // Build widget with observer
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    lastSize = size;
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

      expect(lastSize, isNotNull);

      // Replace with different widget (should cleanup properly)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Container(child: Text('Different widget'))),
        ),
      );

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      // Should not throw any errors during cleanup
      expect(find.text('Different widget'), findsOneWidget);
    });
  });
}

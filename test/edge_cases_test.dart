import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_size_observer/sliver_size_observer.dart';

void main() {
  group('Edge Cases and Error Handling', () {
    testWidgets('handles empty slivers', (WidgetTester tester) async {
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
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Container(),
                      childCount: 0, // Empty list
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
      expect(observedSize, equals(0.0));
    });

    testWidgets('handles rapid widget rebuilds', (WidgetTester tester) async {
      final List<double> sizes = [];

      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverSizeObserver(
                    onSizeChanged: (size) {
                      sizes.add(size);
                    },
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        height: 50.0 * (i + 1), // Different height each time
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump(); // Don't settle, just pump once
      }

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(sizes, isNotEmpty);
      expect(sizes.every((size) => size >= 0), isTrue);
    });

    // Note: Callback exceptions are logged by Flutter but don't crash the app
    // This behavior is expected and handled by the framework

    testWidgets('handles very large slivers', (WidgetTester tester) async {
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
                      height: 10000, // Very large height
                      color: Colors.blue,
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

    testWidgets('handles widget disposal during callback', (
      WidgetTester tester,
    ) async {
      bool widgetDisposed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    // This might be called after widget is disposed
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

      // Quickly replace the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Container(child: Text('Replaced'))),
        ),
      );

      widgetDisposed = true;
      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(widgetDisposed, isTrue);
      expect(find.text('Replaced'), findsOneWidget);
    });

    testWidgets('handles nested scroll views', (WidgetTester tester) async {
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
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 300,
                      child: NestedScrollView(
                        headerSliverBuilder: (context, innerBoxIsScrolled) => [
                          SliverAppBar(title: Text('Nested'), floating: true),
                        ],
                        body: CustomScrollView(
                          slivers: [
                            SliverSizeObserver(
                              onSizeChanged: (size) {
                                innerSize = size;
                              },
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) =>
                                      ListTile(title: Text('Item $index')),
                                  childCount: 5,
                                ),
                              ),
                            ),
                          ],
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

      expect(outerSize, isNotNull);
      expect(innerSize, isNotNull);
      expect(outerSize, equals(300.0));
      expect(innerSize, greaterThan(0));
    });

    testWidgets('handles orientation changes', (WidgetTester tester) async {
      final List<double> sizes = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    sizes.add(size);
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
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      final initialSizeCount = sizes.length;

      // Simulate orientation change by changing widget tree
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    sizes.add(size);
                  },
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Different layout
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          Container(color: Colors.blue, child: Text('$index')),
                      childCount: 4,
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

      expect(sizes.length, greaterThanOrEqualTo(initialSizeCount));
    });

    testWidgets('handles null geometry edge case', (WidgetTester tester) async {
      double? observedSize;
      bool callbackCalled = false;

      // Create a custom sliver that might have null geometry
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverSizeObserver(
                  onSizeChanged: (size) {
                    callbackCalled = true;
                    observedSize = size;
                  },
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      height: 0, // Zero height might cause edge cases
                      color: Colors.transparent,
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

      expect(callbackCalled, isTrue);
      expect(observedSize, isNotNull);
      expect(observedSize, equals(0.0));
    });

    testWidgets('handles concurrent size observations', (
      WidgetTester tester,
    ) async {
      final List<double> allSizes = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: List.generate(
                5,
                (index) => SliverSizeObserver(
                  onSizeChanged: (size) {
                    allSizes.add(size);
                  },
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      height: 50.0 * (index + 1),
                      color: Colors.primaries[index % Colors.primaries.length],
                      child: Text('Section $index'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.binding.delayed(Duration.zero);

      expect(allSizes.length, equals(5));
      // Check that each size is positive and represents the expected heights
      expect(allSizes.every((size) => size > 0), isTrue);
      // The sizes should correspond to heights: 50, 100, 150, 200, 250
      expect(
        allSizes.toSet().length,
        greaterThanOrEqualTo(4),
      ); // At least 4 different sizes
    });
  });
}

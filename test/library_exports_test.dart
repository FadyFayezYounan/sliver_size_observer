import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliver_size_observer/sliver_size_observer.dart';

void main() {
  group('Library Exports', () {
    test('exports SliverSizeObserver', () {
      expect(SliverSizeObserver, isA<Type>());
    });

    test('exports SliverInitialSizeObserver', () {
      expect(SliverInitialSizeObserver, isA<Type>());
    });

    test('exports RenderSliverSizeObserver', () {
      expect(RenderSliverSizeObserver, isA<Type>());
    });

    test('exports RenderInitialMeasurableSliver', () {
      expect(RenderInitialMeasurableSliver, isA<Type>());
    });

    test('can create SliverSizeObserver instance', () {
      final observer = SliverSizeObserver(sliver: const SizedBox());
      expect(observer, isA<SliverSizeObserver>());
    });

    test('can create SliverInitialSizeObserver instance', () {
      final observer = SliverInitialSizeObserver(sliver: const SizedBox());
      expect(observer, isA<SliverInitialSizeObserver>());
    });

    test('can create RenderSliverSizeObserver instance', () {
      final renderObject = RenderSliverSizeObserver();
      expect(renderObject, isA<RenderSliverSizeObserver>());
    });

    test('can create RenderInitialMeasurableSliver instance', () {
      final renderObject = RenderInitialMeasurableSliver();
      expect(renderObject, isA<RenderInitialMeasurableSliver>());
    });
  });
}

# Sliver Size Observer Tests

This directory contains comprehensive tests for the `sliver_size_observer` package.

## Test Files

1. **sliver_size_observer_test.dart** - Tests for the main `SliverSizeObserver` widget
2. **sliver_initial_size_observer_test.dart** - Tests for the `SliverInitialSizeObserver` widget
3. **render_sliver_size_observer_test.dart** - Tests for the `RenderSliverSizeObserver` render object
4. **render_initial_measurable_sliver_test.dart** - Tests for the `RenderInitialMeasurableSliver` render object
5. **integration_test.dart** - Integration tests that test multiple components working together
6. **library_exports_test.dart** - Tests that verify all public APIs are properly exported
7. **usage_examples_test.dart** - Tests that demonstrate common usage patterns
8. **edge_cases_test.dart** - Tests for edge cases and error handling

## Running Tests

To run all tests:

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/sliver_size_observer_test.dart
```

To run tests with coverage:

```bash
flutter test --coverage
```

## Test Coverage

The tests cover:

- Widget creation and basic functionality
- Callback triggering and size reporting
- Widget updates and property changes
- Render object behavior
- Edge cases (empty slivers, zero-height content, etc.)
- Integration scenarios
- Performance with multiple observers
- Memory cleanup
- Different sliver types (SliverList, SliverGrid, SliverAppBar, etc.)

## Dependencies

The tests use the following additional packages:

- `flutter_test` (included with Flutter)
- `mockito` (for mocking if needed)
- `build_runner` (for code generation)

These are automatically installed when running `flutter pub get`.

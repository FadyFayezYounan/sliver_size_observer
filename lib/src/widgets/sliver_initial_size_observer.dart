import 'package:flutter/widgets.dart'
    show
        SingleChildRenderObjectWidget,
        ValueChanged,
        Widget,
        BuildContext,
        RenderObject;

import '../renders/render_sliver_initial_size_observer.dart';

class SliverInitialSizeObserver extends SingleChildRenderObjectWidget {
  final ValueChanged<double>? onInitialSizeChanged;

  const SliverInitialSizeObserver({
    super.key,
    required Widget sliver,
    this.onInitialSizeChanged,
  }) : super(child: sliver);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderInitialMeasurableSliver(
      onInitialSizeChanged: onInitialSizeChanged,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderInitialMeasurableSliver renderObject,
  ) {
    renderObject.onInitialSizeChanged = onInitialSizeChanged;
  }
}

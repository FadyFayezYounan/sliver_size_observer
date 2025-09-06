import 'package:flutter/widgets.dart'
    show
        SingleChildRenderObjectWidget,
        ValueChanged,
        Widget,
        BuildContext,
        RenderObject;

import '../renders/render_sliver_size_observer.dart';

class SliverSizeObserver extends SingleChildRenderObjectWidget {
  final ValueChanged<double>? onSizeChanged;

  const SliverSizeObserver({
    super.key,
    required Widget sliver,
    this.onSizeChanged,
  }) : super(child: sliver);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverSizeObserver(onSizeChanged: onSizeChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderSliverSizeObserver renderObject,
  ) {
    renderObject.onSizeChanged = onSizeChanged;
  }
}

import 'package:flutter/rendering.dart' show RenderProxySliver, ValueChanged;
import 'package:flutter/scheduler.dart' show SchedulerBinding;

class RenderSliverSizeObserver extends RenderProxySliver {
  ValueChanged<double>? onSizeChanged;

  RenderSliverSizeObserver({this.onSizeChanged});

  @override
  void performLayout() {
    super.performLayout();

    // Report the geometry after layout
    if (onSizeChanged != null && geometry != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        onSizeChanged!(geometry!.paintExtent);
      });
    }
  }
}

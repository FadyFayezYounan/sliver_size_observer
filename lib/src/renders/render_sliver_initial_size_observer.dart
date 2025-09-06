import 'package:flutter/rendering.dart' show RenderProxySliver, ValueChanged;
import 'package:flutter/scheduler.dart' show SchedulerBinding;

class RenderInitialMeasurableSliver extends RenderProxySliver {
  ValueChanged<double>? onInitialSizeChanged;
  bool _isFirstFrame = true;
  bool _hasReported = false;

  RenderInitialMeasurableSliver({this.onInitialSizeChanged});

  @override
  void performLayout() {
    super.performLayout();

    if (_isFirstFrame &&
        !_hasReported &&
        onInitialSizeChanged != null &&
        geometry != null) {
      _hasReported = true;

      // Wait for the first frame to complete
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _isFirstFrame = false;
        if (geometry != null) {
          onInitialSizeChanged!(geometry!.paintExtent);
        }
      });
    }
  }
}

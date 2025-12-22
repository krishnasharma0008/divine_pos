import 'package:flutter/widgets.dart';

class ScaleSize {
  static final double _physicalWidth =
      WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
  static final double _devicePixelRatio =
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
  static final double _aspectratio =
      (_physicalWidth / _devicePixelRatio) / 1280; // 834;

  //static double get getDeviceWidth => _physicalWidth;

  static double get aspectRatio => _aspectratio;

  static double get appBarHeight => 76.0 * _aspectratio;

  // static String get getDeviceType {
  //   final MediaQueryData data = MediaQueryData.fromView(
  //     WidgetsBinding.instance.platformDispatcher.views.single,
  //   );
  //   return data.size.shortestSide < 600 ? 'phone' : 'tablet';
  // }
}

import 'package:flutter/widgets.dart';

class Gradients {
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment(0.5, 0.89162),
    end: Alignment(0.5, 0),
    stops: [
      0,
      0.5215,
      0.68723,
      1,
    ],
    colors: [
      Color.fromARGB(230, 6, 46, 84),
      Color.fromARGB(204, 6, 47, 84),
      Color.fromARGB(0, 0, 0, 0),
      Color.fromARGB(0, 0, 0, 0),
    ],
  );
}

class Shadows {
  static const BoxShadow primaryShadow = BoxShadow(
    color: Color.fromARGB(26, 0, 0, 0),
    offset: Offset(0, 2),
    blurRadius: 20,
  );
  static const BoxShadow secondaryShadow = BoxShadow(
    color: Color.fromARGB(26, 0, 0, 0),
    offset: Offset(0, 2),
    blurRadius: 34,
  );
}

class Radii {
  static const BorderRadiusGeometry k16pxRadius =
      BorderRadius.all(Radius.circular(16));
}

class Device {
  static bool get isTablet =>
      MediaQueryData.fromWindow(WidgetsBinding.instance.window)
          .size
          .shortestSide >=
      600;
}

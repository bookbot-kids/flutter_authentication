import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AuthenticationThemeSettings {
  final TextStyle emailTextFieldStyle;
  final TextStyle emailLabelTextStyle;
  final TextStyle emailTitleTextStyle;
  final Color emailBoxColor;
  final TextStyle emailButtonStyle;
  final Widget background;
  final Color backgroundColor;
  final String emailPlaceholder;
  final String emailButtonText;
  final String emailTitleText;
  final String emailLabelText;
  final double emailBoxSize;

  const AuthenticationThemeSettings({
    this.emailTextFieldStyle,
    this.emailLabelTextStyle,
    this.emailTitleTextStyle = const TextStyle(
      fontSize: 20,
    ),
    this.background,
    this.emailBoxColor = Colors.white,
    this.emailButtonStyle,
    this.backgroundColor = Colors.blue,
    this.emailPlaceholder = 'Enter email',
    this.emailButtonText = 'Continue',
    this.emailLabelText = 'Email',
    this.emailTitleText =
        'To Sign In or Register, please enter your email address below. Then we will send you a passcode to enter in the next screen.',
    this.emailBoxSize = 400,
  });
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

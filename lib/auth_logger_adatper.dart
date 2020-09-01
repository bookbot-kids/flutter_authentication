import 'package:logger/logger.dart';

/// An adapter to set [Logger] for this package
///
/// [Logger]:(https://pub.dev/packages/logger)
class AuthLogAdapter {
  AuthLogAdapter._privateConstructor();
  static AuthLogAdapter shared = AuthLogAdapter._privateConstructor();

  /// Logger instance to write log, must be set before using
  Logger logger;
}

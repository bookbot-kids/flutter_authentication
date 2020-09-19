import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_authentication/authentication_widget.dart';
import 'package:flutter_authentication/input_email_widget.dart';
import 'package:flutter_authentication/input_token_widget.dart';
import 'package:flutter_authentication/themes.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:logger/logger.dart';
import 'package:robust_http/robust_http.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class Notifier extends ChangeNotifier {
  String message;
  void notify(String eventMessage) {
    message = eventMessage;
    notifyListeners();
  }
}

class AuthenticationService {
  AuthenticationService._privateConstructor();
  static AuthenticationService shared =
      AuthenticationService._privateConstructor();

  String _azureKey;

  final successNotifier = Notifier();
  Logger logger;
  HTTP _http;
  String b2cUrl;
  Future dialogTask;

  void init(Logger logger, Map<String, dynamic> config) {
    _azureKey = config['azureKey'];
    this.logger = logger;
    _http = HTTP(config['azureBaseUrl']);
    b2cUrl = config['azureB2CAuthUrl'];
  }

  Future<String> startAuthentication(BuildContext context,
      {AuthenticationThemeSettings theme =
          const AuthenticationThemeSettings()}) async {
    dialogTask ??= showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return Container(
            child: InputEmailWidget(
              themes: theme,
            ),
          );
        });

    await dialogTask;
    return successNotifier.message;
  }

  Future<void> startPasscodeScreen(BuildContext context, String email,
      {AuthenticationThemeSettings theme =
          const AuthenticationThemeSettings()}) async {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      // ignore: unawaited_futures
      Navigator.push(
          context,
          platformPageRoute(
            context: context,
            builder: (rootContext) =>
                AuthenticationWidget(email: email, theme: theme),
          ));
    } else {
      await url_launcher.launch(b2cUrl);
      // ignore: unawaited_futures
      Navigator.push(
          context,
          platformPageRoute(
            context: context,
            builder: (rootContext) => InputTokenWidget(themes: theme),
          ));
    }
  }

  Future<dynamic> verifyEmail(String email) async {
    try {
      var response = await _http.get('/CheckAccount',
          parameters: {'code': _azureKey, 'email': email});
      if (response['success'] == true) {
        return response;
      }
    } catch (error, stacktrace) {
      logger?.e('CheckAccount error $error', error, stacktrace);
    }

    return null;
  }
}

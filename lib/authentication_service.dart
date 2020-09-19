import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_authentication/authentication_widget.dart';
import 'package:flutter_authentication/input_email_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:logger/logger.dart';
import 'package:robust_http/robust_http.dart';

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

  void init(Logger logger, Map<String, dynamic> config) {
    _azureKey = config['azureKey'];
    this.logger = logger;
    _http = HTTP(config['azureBaseUrl']);
    b2cUrl = config['azureB2CAuthUrl'];
  }

  void startAuthentication(BuildContext context) {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return Container(
            child: InputEmailWidget(),
          );
        });
  }

  void startPasscodeScreen(BuildContext context, String email) {
    Navigator.push(
        context,
        platformPageRoute(
          context: context,
          builder: (rootContext) => AuthenticationWidget(email: email),
        ));
  }

  void showErrorModal(BuildContext context, String message,
      {String buttonText = 'OK'}) {
    showPlatformDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text(message),
              actions: [
                FlatButton(
                  child: Text(buttonText),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ));
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

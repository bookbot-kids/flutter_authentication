import 'package:flutter/material.dart';
import 'package:flutter_authentication/authentication_widget.dart';
import 'package:flutter_authentication/input_email_widget.dart';
import 'package:flutter_authentication/input_token_widget.dart';
import 'package:flutter_authentication/starting_widget.dart';
import 'package:flutter_authentication/themes.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:logger/logger.dart';
import 'package:robust_http/robust_http.dart';
import 'package:singleton/singleton.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class AuthenticateNotifier extends ChangeNotifier {
  String? message;
  void notify(String eventMessage) {
    message = eventMessage;
    notifyListeners();
  }
}

class AuthenticationService {
  factory AuthenticationService() =>
      Singleton.lazy(() => AuthenticationService._privateConstructor());
  AuthenticationService._privateConstructor();
  static AuthenticationService shared = AuthenticationService();

  late String _azureKey;

  final successNotifier = AuthenticateNotifier();
  Logger? logger;
  late HTTP _http;
  late String b2cUrl;
  late Future dialogTask;
  late Future passcodeDialogTask;

  void init(Logger logger, Map<String, dynamic> config) {
    _azureKey = config['azureKey'];
    this.logger = logger;
    _http = HTTP(config['azureBaseUrl']);
    b2cUrl = config['azureB2CAuthUrl'];
  }

  Future<String?> startAuthentication(BuildContext context,
      {AuthenticationThemeSettings theme = const AuthenticationThemeSettings(),
      bool withoutEmail = false}) async {
    dialogTask = showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return Container(
            child: withoutEmail
                ? StartingWidget(themes: theme)
                : InputEmailWidget(
                    themes: theme,
                  ),
          );
        });

    await dialogTask;
    return successNotifier.message;
  }

  Future<String?> startPasscodeScreen(
    BuildContext context,
    String email, {
    AuthenticationThemeSettings theme = const AuthenticationThemeSettings(),
    bool modalMode = false,
  }) async {
    if (!(UniversalPlatform.isAndroid || UniversalPlatform.isIOS)) {
      await url_launcher.launch(b2cUrl);
    }

    if (modalMode) {
      passcodeDialogTask = showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: Colors.black45,
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (BuildContext buildContext, Animation animation,
              Animation secondaryAnimation) {
            return Container(
              child: AuthenticationWidget(email: email, theme: theme),
            );
          });

      await passcodeDialogTask;
    } else {
      await Navigator.push(
          context,
          platformPageRoute(
            context: context,
            builder: (rootContext) => InputTokenWidget(themes: theme),
          ));
    }

    return successNotifier.message;
  }

  Future<dynamic> verifyEmail(String email, {String? countryCode}) async {
    try {
      final params = <String, dynamic>{'code': _azureKey, 'email': email};
      if (countryCode?.isNotEmpty == true) {
        params['country'] = countryCode;
      }

      final response = await _http.get('/CheckAccount', parameters: params);
      if (response['success'] == true) {
        return response;
      }
    } catch (error, stacktrace) {
      logger?.e('CheckAccount error $error', error, stacktrace);
    }

    return null;
  }
}

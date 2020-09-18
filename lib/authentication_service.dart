import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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

  String _azureCode;

  final errorNotifier = Notifier();
  final successNotifier = Notifier();
  Logger logger;
  HTTP _http;
  String b2cUrl;

  void init(Logger logger, Map<String, dynamic> config) {
    _azureCode = config["azure_code"];
    this.logger = logger;
    _http = HTTP(config["azureBaseUrl"]);
    b2cUrl = config["azureB2CAuthUrl"];
  }

  void startAuthenticationModal(BuildContext context) {
    showPlatformDialog(
        context: context,
        builder: (_) {
          return InputEmailWidget();
        });
  }

  Future<dynamic> verifyEmail(String email) async {
    try {
      var response = await _http.get('/CheckAccount',
          parameters: {'code': _azureCode, 'email': email});
      if (response['success'] == true) {
        return response;
      }
    } catch (error, stacktrace) {
      logger?.e('CheckAccount error $error', error, stacktrace);
    }

    return null;
  }
}

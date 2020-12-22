import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_authentication/authentication_service.dart';
import 'package:flutter_authentication/view_helper.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

class B2CWebviewWidget extends StatefulWidget {
  B2CWebviewWidget({
    Key key,
    @required this.email,
    @required this.loadingCallback,
  }) : super(key: key);
  final String email;
  final Function(bool) loadingCallback;

  @override
  _B2CWebviewWidgetState createState() => _B2CWebviewWidgetState();
}

enum AuthenticateState { init, verifyCode, confirm }

class _B2CWebviewWidgetState extends State<B2CWebviewWidget> {
  final _userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1';
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool hasInjectedJS = false;
  Timer _timer;
  Timer _timeoutTimer;
  AuthenticateState screenState = AuthenticateState.init;
  int _injectFailedCount = 0;
  double loginTimeout = 30000;
  int _retry = 0;
  bool _siteLoaded = false;
  DateTime _start;

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: AuthenticationService.shared.b2cUrl,
      javascriptMode: JavascriptMode.unrestricted,
      // user iphone user agent to make the webview responsive
      userAgent: _userAgent,
      onWebViewCreated: (WebViewController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
        }
      },
      navigationDelegate: (NavigationRequest request) {
        getToken(request.url, context);
        return NavigationDecision.navigate;
      },
      onPageFinished: (String url) {
        AuthenticationService.shared.logger?.i('onPageFinished $url');
        _siteLoaded = true;
        if (_timer == null) {
          startTimer();
        }
      },
      onWebResourceError: (WebResourceError error) {
        AuthenticationService.shared.logger
            ?.i('onWebResourceError ${error.description}');
      },
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{}
        ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()
          ..onTapDown = (tap) {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          })),
    );
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 1000), detectWebviewState);
  }

  Future<Timer> detectWebviewState(Timer timer) async {
    if (!mounted) {
      return null;
    }

    var controller = await _controller.future;
    switch (screenState) {
      case AuthenticateState.init:
        detectSendButtonVisible(controller);
        break;
      case AuthenticateState.verifyCode:
        detectVerifyButtonVisible(controller);
        break;
      case AuthenticateState.confirm:
        detectEditEmailButtonVisible(controller);
        break;
    }

    return null;
  }

  /// check for send button visible
  void detectSendButtonVisible(WebViewController controller) {
    controller
        .evaluateJavascript(
            "document.getElementById('email_ver_but_send') !== null && document.getElementById('email_ver_but_send').offsetParent !== null")
        .then((s) async {
      AuthenticationService.shared.logger
          ?.i('email_ver_but_send is visible $s');
      // button is visible, then inject click
      if (screenState != AuthenticateState.verifyCode &&
          (s == '1' || s == 'true')) {
        await injectSendEmail();
        screenState = AuthenticateState.verifyCode;
      }
    }).catchError((e) {
      AuthenticationService.shared.logger?.e(e.toString());
      // can't inject to send email, let user do it
      if (_injectFailedCount > 10) {
        screenState = AuthenticateState.verifyCode;
      } else {
        _injectFailedCount++;
      }
    });
  }

  /// check if verify code button visible to change next state
  void detectVerifyButtonVisible(WebViewController controller) {
    controller
        .evaluateJavascript(
            "document.getElementById('email_ver_but_verify') !== null && document.getElementById('email_ver_but_verify').offsetParent !== null")
        .then((s) async {
      AuthenticationService.shared.logger
          ?.i('email_ver_but_verify is visible $s');
      if (s == '1' || s == 'true') {
        screenState = AuthenticateState.confirm;
      }
    }).catchError((e) {
      AuthenticationService.shared.logger?.e(e.toString());
    });
  }

  // check for edit email button is visible. If it does, it means user already verified pass code
  void detectEditEmailButtonVisible(WebViewController controller) {
    controller
        .evaluateJavascript(
            "document.getElementById('email_ver_but_edit') !== null && document.getElementById('email_ver_but_edit').offsetParent !== null")
        .then((s) async {
      AuthenticationService.shared.logger
          ?.i('email_ver_but_edit is visible $s');
      // button is visible
      if (s == '1' || s == 'true') {
        // show progress loading & inject click continue button
        widget.loadingCallback(true);
        // ignore: unawaited_futures
        controller
            .evaluateJavascript(
                'document.getElementById(\"continue\").click();')
            .then((s) async {})
            .catchError((e) {
          AuthenticationService.shared.logger?.e(e.toString());
        });

        // stop timer now
        _timer.cancel();
      }
    }).catchError((e) {
      AuthenticationService.shared.logger?.e(e.toString());
    });
  }

  Future injectSendEmail() async {
    var controller = await _controller.future;
    if (hasInjectedJS) {
      return;
    }

    // ignore: unawaited_futures
    controller
        .evaluateJavascript(
            'document.getElementById(\"email\").value=\"${widget.email}\"')
        .then((s) {
      controller
          .evaluateJavascript(
              'document.getElementById(\"email_ver_but_send\").click();')
          .then((s) async {
        hasInjectedJS = true;
        await Future.delayed(const Duration(milliseconds: 1500));
        widget.loadingCallback(false);
      }).catchError((e) {
        widget.loadingCallback(false);
      });
    }).catchError((e) {
      widget.loadingCallback(false);
    });
  }

  Future getToken(String url, BuildContext context) async {
    if (screenState != AuthenticateState.confirm) {
      return;
    }
    AuthenticationService.shared.logger?.i('handleUrl $url');
    // get id token after user sign in
    if (url.contains('#id_token=')) {
      // close keyboard
      FocusScope.of(context).requestFocus(FocusNode());
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
      widget.loadingCallback(true);
      // get the id token after user sign in
      var idToken = url.split('#id_token=')[1];
      AuthenticationService.shared.successNotifier.notify(idToken);
    } else {
      ViewHelper.showModal(context, 'Can not get token');
    }
  }

  void checkingTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      if (_siteLoaded) {
        timer.cancel();
        AuthenticationService.shared.logger?.i('site is loaded. Stop timer');
        return;
      }

      var now = DateTime.now();
      var diff = now.difference(_start).inMilliseconds;
      AuthenticationService.shared.logger?.i('checkingTimeout $diff');
      if (diff >= loginTimeout) {
        if (_retry < 3) {
          ++_retry;
          AuthenticationService.shared.logger?.i('timeout. retry $_retry');
          _start = DateTime.now();
          // ignore: unawaited_futures
          reload();
        } else {
          timer.cancel();
          AuthenticationService.shared.logger?.i('retried 3 times. Stop timer');
          ViewHelper.showModal(context, 'Cannot load authentication');
        }
      }
    });
  }

  Future<void> reload() async {
    var controller = await _controller.future;
    await controller?.loadUrl(AuthenticationService.shared.b2cUrl);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();
    checkingTimeout();
  }
}

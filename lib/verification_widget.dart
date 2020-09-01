import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_authentication/auth_logger_adatper.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum ScreenState { init, verifyCode, confirm }

class VerificationWidget extends StatefulWidget {
  final String email;
  final String b2cUrl;
  final Function(String) callback;
  final Function errorCallback;

  VerificationWidget({
    Key key,
    @required this.email,
    @required this.b2cUrl,
    @required this.callback,
    @required this.errorCallback,
  });

  @override
  State<StatefulWidget> createState() => VerificationState();
}

class VerificationState extends State<VerificationWidget> {
  final _userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1';
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool hasInjectedJS = false;
  bool showLoading = true;
  Timer _timer;
  Timer _timeoutTimer;
  ScreenState screenState;
  int _retry = 0;
  bool _siteLoaded = false;
  DateTime _start;
  int _injectFailedCount = 0;
  final loginTimeout = 30000;

  void onItemPressed(BuildContext context) => Navigator.pop(context);

  Widget _buildWebview(BuildContext context) {
    return WebView(
      initialUrl: widget.b2cUrl,
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
        AuthLogAdapter.shared.logger?.i("onPageFinished $url");
        _siteLoaded = true;
        if (_timer == null) {
          startTimer();
        }
      },
      onWebResourceError: (WebResourceError error) {
        AuthLogAdapter.shared.logger
            ?.i("onWebResourceError ${error.description}");
      },
      gestureRecognizers: Set()
        ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()
          ..onTapDown = (tap) {
            SystemChannels.textInput.invokeMethod(
                'TextInput.hide'); //This will hide keyboard ontapdown
          })),
    );
  }

  void showHideLoading(bool isShowing) {
    if (!mounted) {
      return;
    }

    setState(() {
      showLoading = isShowing;
    });
  }

  void checkingTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      if (_siteLoaded) {
        timer.cancel();
        AuthLogAdapter.shared.logger?.i('site is loaded. Stop timer');
        return;
      }

      var now = DateTime.now();
      int diff = now.difference(_start).inMilliseconds;
      AuthLogAdapter.shared.logger?.i('checkingTimeout $diff');
      if (diff >= loginTimeout) {
        if (_retry < 3) {
          ++_retry;
          AuthLogAdapter.shared.logger?.i('timeout. retry $_retry');
          _start = DateTime.now();
          reload().then((value) => null);
        } else {
          timer.cancel();
          AuthLogAdapter.shared.logger?.i('retried 3 times. Stop timer');
          widget.errorCallback();
        }
      }
    });
  }

  Future<void> reload() async {
    var controller = await _controller.future;
    controller?.loadUrl(widget.b2cUrl);
  }

  @override
  void initState() {
    super.initState();
    screenState = ScreenState.init;
    _start = DateTime.now();
    checkingTimeout();
  }

  /// check for send button visible
  void detectSendButtonVisible(WebViewController controller) {
    controller
        .evaluateJavascript(
            "document.getElementById('email_ver_but_send') !== null && document.getElementById('email_ver_but_send').offsetParent !== null")
        .then((s) async {
      AuthLogAdapter.shared.logger?.i("email_ver_but_send is visible $s");
      // button is visible, then inject click
      if (screenState != ScreenState.verifyCode && (s == '1' || s == 'true')) {
        injectSendEmail();
        screenState = ScreenState.verifyCode;
      }
    }).catchError((e) {
      AuthLogAdapter.shared.logger?.e(e.toString());
      // can't inject to send email, let user do it
      if (_injectFailedCount > 10) {
        screenState = ScreenState.verifyCode;
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
      AuthLogAdapter.shared.logger?.i("email_ver_but_verify is visible $s");
      if (s == '1' || s == 'true') {
        screenState = ScreenState.confirm;
      }
    }).catchError((e) {
      AuthLogAdapter.shared.logger?.e(e.toString());
    });
  }

  // check for edit email button is visible. If it does, it means user already verified pass code
  void detectEditEmailButtonVisible(WebViewController controller) {
    controller
        .evaluateJavascript(
            "document.getElementById('email_ver_but_edit') !== null && document.getElementById('email_ver_but_edit').offsetParent !== null")
        .then((s) async {
      AuthLogAdapter.shared.logger?.i("email_ver_but_edit is visible $s");
      // button is visible
      if (s == '1' || s == 'true') {
        // show progress loading & inject click continue button
        showHideLoading(true);
        controller
            .evaluateJavascript(
                "document.getElementById(\"continue\").click();")
            .then((s) async {})
            .catchError((e) {
          AuthLogAdapter.shared.logger?.e(e.toString());
        });

        // stop timer now
        _timer.cancel();
      }
    }).catchError((e) {
      AuthLogAdapter.shared.logger?.e(e.toString());
    });
  }

  Future<Timer> detectWebviewState(Timer timer) async {
    if (!mounted) {
      return null;
    }

    var controller = await _controller.future;
    switch (screenState) {
      case ScreenState.init:
        detectSendButtonVisible(controller);
        break;
      case ScreenState.verifyCode:
        detectVerifyButtonVisible(controller);
        break;
      case ScreenState.confirm:
        detectEditEmailButtonVisible(controller);
        break;
    }

    return null;
  }

  void startTimer() {
    _timer =
        new Timer.periodic(Duration(milliseconds: 1000), detectWebviewState);
  }

  Future injectSendEmail() async {
    var controller = await _controller.future;
    if (hasInjectedJS) {
      return;
    }

    controller
        .evaluateJavascript(
            "document.getElementById(\"email\").value=\"${widget.email}\"")
        .then((s) {
      controller
          .evaluateJavascript(
              "document.getElementById(\"email_ver_but_send\").click();")
          .then((s) async {
        hasInjectedJS = true;
        await Future.delayed(const Duration(milliseconds: 1500));
        showHideLoading(false);
      }).catchError((e) {
        showHideLoading(false);
      });
    }).catchError((e) {
      showHideLoading(false);
    });
  }

  Future getToken(String url, BuildContext context) async {
    AuthLogAdapter.shared.logger?.i("handleUrl $url");
    // get id token after user sign in
    if (url.startsWith("https://jwt.ms/#id_token=")) {
      // close keyboard
      FocusScope.of(context).requestFocus(new FocusNode());
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      showHideLoading(true);
      // get the id token after user sign in
      String idToken = url.replaceAll("https://jwt.ms/#id_token=", "");
      widget.callback(idToken);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Widget _buildBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Positioned(
                child: AnimatedOpacity(
              opacity: showLoading ? 0.0 : 1.0,
              duration: Duration(milliseconds: 500),
              child: SingleChildScrollView(
                child: Container(
                  height: 390,
                  child: Container(
                      width: 320,
                      height: 450,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(26, 0, 0, 0),
                              offset: Offset(0, 2),
                              blurRadius: 20,
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                                child: _buildWebview(context),
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            )),
            Positioned.fill(
                child: Container(
              child: AnimatedOpacity(
                opacity: showLoading ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: PlatformCircularProgressIndicator(),
              ),
            ))
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      material: (_, target) =>
          MaterialScaffoldData(resizeToAvoidBottomInset: false),
      cupertino: (_, target) =>
          CupertinoPageScaffoldData(resizeToAvoidBottomInset: false),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(left: 0, top: 0, right: 0, bottom: 0, child: Container()),
          Positioned(
            child: AppBar(
                centerTitle: true,
                elevation: 0.0,
                backgroundColor: Colors.transparent),
          ),
          Positioned(child: SafeArea(child: _buildBox())),
        ],
      ),
    );
  }
}

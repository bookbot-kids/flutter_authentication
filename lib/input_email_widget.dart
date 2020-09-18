import 'package:auto_size_text/auto_size_text.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_authentication/authentication_service.dart';
import 'package:flutter_authentication/authentication_widget.dart';
import 'package:flutter_authentication/themes.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class InputEmailTheme {
  final TextStyle textFieldStyle;
  final TextStyle labelTextStyle;
  final Color background;
  final TextStyle buttonStyle;

  const InputEmailTheme({
    this.textFieldStyle,
    this.labelTextStyle,
    this.background = const Color.fromARGB(255, 255, 255, 255),
    this.buttonStyle,
  });
}

class InputEmailWidget extends StatefulWidget {
  final String placeholder;
  final String buttonText;
  final String titleText;
  final String dialogActionText;
  final InputEmailTheme theme;

  const InputEmailWidget({
    Key key,
    this.placeholder = 'Email',
    this.theme = const InputEmailTheme(),
    this.buttonText = 'Continue',
    this.titleText = 'Welcome',
    this.dialogActionText = 'OK',
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => InputEmailState();
}

class InputEmailState extends State<InputEmailWidget> {
  final textController = TextEditingController();
  bool showLoading = false;
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future onContinuePressed(BuildContext context) async {
    var email = textController.text;
    email = email?.toLowerCase()?.trim();
    if (email.isEmpty || !RegexUtil.isEmail(email)) {
      AuthenticationService.shared.errorNotifier.notify('Email is invalid');
      return;
    }

    var response = await AuthenticationService.shared.verifyEmail(email);
    if (response != null) {
      Navigator.push(
          context,
          platformPageRoute(
            context: context,
            builder: (rootContext) => AuthenticationWidget(email: email),
          ));
    } else {
      AuthenticationService.shared.errorNotifier.notify('Verify email error');
    }
  }

  Widget _buildBox(bool isTablet) {
    return Column(
      mainAxisAlignment:
          isTablet ? MainAxisAlignment.center : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: isTablet ? 450 : 320,
            height: 500,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  top: 31,
                  right: -1,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.theme.background,
                      boxShadow: [
                        Shadows.primaryShadow,
                      ],
                      borderRadius: Radii.k16pxRadius,
                    ),
                    child: Container(),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 0,
                  right: 20,
                  bottom: 21,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(left: 4, top: 6, right: 4),
                          child: Center(
                            child: AutoSizeText(
                              widget.titleText,
                              textAlign: TextAlign.center,
                              maxLines: 6,
                              style: widget.theme.labelTextStyle,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 78,
                        margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 15,
                              margin:
                                  EdgeInsets.only(left: 18, top: 6, right: 10),
                              child: AutoSizeText(widget.placeholder,
                                  textAlign: TextAlign.left,
                                  maxLines: 1,
                                  minFontSize: 0,
                                  style: widget.theme.labelTextStyle),
                            ),
                            Spacer(),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 255, 255),
                                border: Border.all(
                                  width: 1.5,
                                  color: Color.fromARGB(255, 97, 197, 229),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(13, 0, 0, 0),
                                    offset: Offset(0, 5),
                                    blurRadius: 30,
                                  ),
                                ],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                              child: PlatformTextField(
                                controller: textController,
                                material: (_, target) => MaterialTextFieldData(
                                  decoration: InputDecoration(
                                    hintText: widget.placeholder,
                                    contentPadding: EdgeInsets.only(
                                        left: 18, top: 0, right: 18, bottom: 0),
                                    border: InputBorder.none,
                                  ),
                                ),
                                cupertino: (_, target) =>
                                    CupertinoTextFieldData(
                                  placeholder: widget.placeholder,
                                  padding: EdgeInsets.only(
                                      left: 18, top: 0, right: 18, bottom: 0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.0, style: BorderStyle.none),
                                  ),
                                ),
                                style: widget.theme.textFieldStyle,
                                maxLines: 1,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.send,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          height: 50,
                          child: Stack(children: <Widget>[
                            Positioned(
                                child: AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: showLoading ? 0.0 : 1.0,
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: FlatButton(
                                  onPressed: () =>
                                      this.onContinuePressed(context),
                                  color: Color.fromARGB(255, 110, 203, 242),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  textColor: Color.fromARGB(255, 255, 255, 255),
                                  padding: EdgeInsets.all(0),
                                  child: AutoSizeText(
                                    widget.buttonText,
                                    maxLines: 1,
                                    minFontSize: 0,
                                    textAlign: TextAlign.center,
                                    style: widget.theme.buttonStyle,
                                  ),
                                ),
                              ),
                            )),
                            Positioned(
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 300),
                                opacity: showLoading ? 1.0 : 0.0,
                                child: Center(
                                    child: PlatformCircularProgressIndicator()),
                              ),
                            )
                          ]))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQueryData.fromWindow(WidgetsBinding.instance.window)
            .size
            .shortestSide >=
        600;
    return PlatformScaffold(
        body: InkWell(
            onTap: () {
              //  hide soft keyboard
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Material(
              child: Container(
                constraints: BoxConstraints.expand(),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 67, 117, 163),
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              height: 700,
                              decoration: BoxDecoration(
                                gradient: Gradients.primaryGradient,
                              ),
                              child: Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        left: 0,
                        right: 0,
                        top: isTablet ? 14 : null,
                        bottom: 14,
                        child: _buildBox(isTablet)),
                  ],
                ),
              ),
            )));
  }
}

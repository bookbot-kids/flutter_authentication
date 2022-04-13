import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authentication/authentication_service.dart';
import 'package:flutter_authentication/themes.dart';
import 'package:flutter_authentication/view_helper.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class InputEmailWidget extends StatefulWidget {
  final AuthenticationThemeSettings themes;
  const InputEmailWidget(
      {Key? key, this.themes = const AuthenticationThemeSettings()})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => InputEmailState();
}

class InputEmailState extends State<InputEmailWidget> {
  /// Regex of email.
  static const String regexEmail =
      '^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$';
  final textController = TextEditingController();
  bool showLoading = false;
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future onContinuePressed(BuildContext context) async {
    var email = textController.text;
    email = email.toLowerCase().trim();
    if (email.isEmpty || !RegExp(regexEmail).hasMatch(email)) {
      ViewHelper.showModal(context, 'Email is invalid');
      return;
    }

    setState(() {
      showLoading = true;
    });
    var response = await AuthenticationService.shared.verifyEmail(email);

    setState(() {
      showLoading = false;
    });

    if (response != null) {
      await AuthenticationService.shared.startPasscodeScreen(context, email);
    } else {
      ViewHelper.showModal(
          context, 'Can not verify your email. Please try again');
    }
  }

  Widget _buildBox() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: widget.themes.emailBoxSize,
            height: widget.themes.emailBoxSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.themes.emailBoxColor,
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
                  top: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Center(
                            child: AutoSizeText(
                              widget.themes.emailTitleText,
                              textAlign: TextAlign.center,
                              style: widget.themes.emailTitleTextStyle,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 90,
                        margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 15,
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              child: Text(widget.themes.emailLabelText,
                                  textAlign: TextAlign.left,
                                  style: widget.themes.emailLabelTextStyle),
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
                                    hintText: widget.themes.emailPlaceholder,
                                    contentPadding: EdgeInsets.only(
                                        left: 18, top: 0, right: 18, bottom: 0),
                                    border: InputBorder.none,
                                  ),
                                ),
                                cupertino: (_, target) =>
                                    CupertinoTextFieldData(
                                  placeholder: widget.themes.emailPlaceholder,
                                  padding: EdgeInsets.only(
                                      left: 18, top: 0, right: 18, bottom: 0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.0, style: BorderStyle.none),
                                  ),
                                ),
                                style: widget.themes.emailTextFieldStyle,
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
                                  onPressed: () => onContinuePressed(context),
                                  color: Color.fromARGB(255, 110, 203, 242),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  textColor: Color.fromARGB(255, 255, 255, 255),
                                  padding: EdgeInsets.all(0),
                                  child: AutoSizeText(
                                    widget.themes.emailButtonText,
                                    maxLines: 1,
                                    minFontSize: 0,
                                    textAlign: TextAlign.center,
                                    style: widget.themes.emailButtonStyle,
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
    return PlatformScaffold(
        body: Material(
            child: InkWell(
      onTap: () => ViewHelper.closeKeyboard(context),
      child: Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          children: [
            Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
                child: widget.themes.backgroundImage != null
                    ? Image.asset(widget.themes.backgroundImage!)
                    : Container(
                        color: widget.themes.backgroundColor,
                      )),
            Positioned(child: _buildBox()),
          ],
        ),
      ),
    )));
  }
}

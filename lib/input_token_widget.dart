import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authentication/authentication_service.dart';
import 'package:flutter_authentication/themes.dart';
import 'package:flutter_authentication/view_helper.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class InputTokenWidget extends StatelessWidget {
  final AuthenticationThemeSettings themes;
  const InputTokenWidget(
      {Key? key, this.themes = const AuthenticationThemeSettings()})
      : super(key: key);

  void onButtonPressed(BuildContext context, String token) {
    AuthenticationService.shared.successNotifier.notify(token);
    // pop this screen
    Navigator.pop(context);
    // close modal
    Navigator.pop(context);
  }

  Widget _buildBox(BuildContext context) {
    final controller = TextEditingController();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: themes.emailBoxSize,
            height: themes.emailBoxSize,
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
                      color: themes.emailBoxColor,
                      boxShadow: [
                        Shadows.primaryShadow,
                      ],
                      borderRadius: Radii.k16pxRadius,
                    ),
                    child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              themes.enterTokenText,
                              style: themes.emailTitleTextStyle,
                            ),
                            Expanded(
                              child: Center(
                                child: Container(
                                  height: 300,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        boxShadow: [
                                          BoxShadow(
                                              color: const Color(0x00000000),
                                              offset: Offset.zero,
                                              blurRadius: 0.0)
                                        ]),
                                    child: PlatformTextField(
                                      controller: controller,
                                      style: themes.emailTextFieldStyle,
                                      autocorrect: false,
                                      keyboardType: TextInputType.multiline,
                                      maxLength: null,
                                      maxLines: null,
                                      expands: true,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: FlatButton(
                                onPressed: () =>
                                    onButtonPressed(context, controller.text),
                                color: Color.fromARGB(255, 110, 203, 242),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8)),
                                ),
                                textColor: Color.fromARGB(255, 255, 255, 255),
                                padding: EdgeInsets.all(0),
                                child: AutoSizeText(
                                  themes.enterTokenButtonText,
                                  maxLines: 1,
                                  minFontSize: 0,
                                  textAlign: TextAlign.center,
                                  style: themes.emailButtonStyle,
                                ),
                              ),
                            )
                          ],
                        )),
                  ),
                ),
                Positioned(
                    left: 20,
                    top: 20,
                    right: 20,
                    bottom: 20,
                    child: Container()),
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
                child: themes.backgroundImage != null
                    ? Image.asset(themes.backgroundImage!)
                    : Container(
                        color: themes.backgroundColor,
                      )),
            Positioned(child: _buildBox(context)),
          ],
        ),
      ),
    )));
  }
}

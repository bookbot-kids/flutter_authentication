import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_authentication/authentication_service.dart';
import 'package:flutter_authentication/themes.dart';
import 'package:flutter_authentication/view_helper.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class StartingWidget extends StatefulWidget {
  final AuthenticationThemeSettings themes;
  const StartingWidget(
      {Key key, this.themes = const AuthenticationThemeSettings()})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StartingState();
}

class StartingState extends State<StartingWidget> {
  final textController = TextEditingController();
  bool showLoading = false;
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future onContinuePressed(BuildContext context) async {
    await AuthenticationService.shared.startPasscodeScreen(context, null);
  }

  Widget _buildBox() {
    return Container(
      alignment: Alignment.center,
      child: Container(
          height: 100,
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () => onContinuePressed(context),
            style: TextButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 97, 197, 229),
              textStyle: TextStyle(
                color: Colors.white,
              ),
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            child: AutoSizeText(
              widget.themes.signInText,
              maxLines: 1,
              minFontSize: 0,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )),
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
                    ? Image.asset(widget.themes.backgroundImage)
                    : Container(
                        color: widget.themes.backgroundColor,
                      )),
            Positioned.fill(child: _buildBox()),
          ],
        ),
      ),
    )));
  }
}

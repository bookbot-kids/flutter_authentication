import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class InputEmailWidget extends StatefulWidget {
  final String placeholder;
  final TextStyle textFieldStyle;
  final String buttonText;
  final TextStyle buttonStyle;
  final Function(String) callback;

  const InputEmailWidget({
    Key key,
    this.placeholder = 'Email',
    this.textFieldStyle,
    this.buttonText = 'Continue',
    this.buttonStyle,
    @required this.callback,
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
    widget.callback(email);
  }

  Widget _buildBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          child: PlatformTextField(
            controller: textController,
            material: (_, target) => MaterialTextFieldData(
              decoration: InputDecoration(
                hintText: widget.placeholder,
                contentPadding:
                    EdgeInsets.only(left: 18, top: 0, right: 18, bottom: 0),
                border: InputBorder.none,
              ),
            ),
            cupertino: (_, target) => CupertinoTextFieldData(
              placeholder: widget.placeholder,
              padding: EdgeInsets.only(left: 18, top: 0, right: 18, bottom: 0),
              decoration: BoxDecoration(
                border: Border.all(width: 0.0, style: BorderStyle.none),
              ),
            ),
            style: widget.textFieldStyle,
            maxLines: 1,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
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
                    onPressed: () => this.onContinuePressed(context),
                    color: Color.fromARGB(255, 110, 203, 242),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    textColor: Color.fromARGB(255, 255, 255, 255),
                    padding: EdgeInsets.all(0),
                    child: Text(
                      widget.buttonText,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: widget.buttonStyle,
                    ),
                  ),
                ),
              )),
              Positioned(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: showLoading ? 1.0 : 0.0,
                  child: Center(child: PlatformCircularProgressIndicator()),
                ),
              ),
            ]))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        body: InkWell(
      onTap: () {
        //  hide soft keyboard
        FocusScope.of(context).requestFocus(new FocusNode());
      },
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
              child: Container(),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: _buildBox(),
            ),
          ],
        ),
      ),
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ViewHelper {
  static void closeKeyboard(BuildContext context) {
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    FocusManager.instance.primaryFocus?.unfocus();
  }

  static void showModal(BuildContext context, String message,
      {String buttonText = 'OK', String title}) {
    showPlatformDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: title == null ? null : Text(title),
              content: Text(message),
              actions: [
                FlatButton(
                  child: Text(buttonText),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ));
  }
}

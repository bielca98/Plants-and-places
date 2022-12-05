import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(
  BuildContext context, {
  String title = "",
  String message = "",
  String confirmText = "Confirmeu",
  String cancelText = "Canceleu",
  Function confirmFunction,
  Function cancelFunction,
}) {
  Widget cancelButton = FlatButton(
    child: Text(cancelText),
    onPressed: cancelFunction != null
        ? cancelFunction
        : () => Navigator.pop(context, false),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
  );

  Widget confirmButton = FlatButton(
    child: Text(confirmText),
    onPressed: confirmFunction != null
        ? confirmFunction
        : () => Navigator.pop(context, true),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    actions: [
      cancelButton,
      confirmButton,
    ],
  );

  return showDialog(
    context: context,
    builder: (BuildContext context) => alert,
  );
}

Future<bool> showErrorDialog(
  BuildContext context, {
  String title = "",
  String message = "",
}) {
  Widget cancelButton = FlatButton(
    child: Text("Continuar"),
    onPressed: () => Navigator.pop(context, false),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(
      message,
      textAlign: TextAlign.left,
      style: TextStyle(),
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    actions: [
      cancelButton,
    ],
  );

  return showDialog(
    context: context,
    builder: (BuildContext context) => alert,
  );
}

Future<bool> showSuccessDialog(
  BuildContext context, {
  String title = "",
  String message = "",
}) {
  Widget cancelButton = FlatButton(
    child: Text("Continuar"),
    onPressed: () => Navigator.pop(context, false),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(
      message,
      textAlign: TextAlign.left,
      style: TextStyle(),
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
    actions: [
      cancelButton,
    ],
  );

  return showDialog(
    context: context,
    builder: (BuildContext context) => alert,
  );
}

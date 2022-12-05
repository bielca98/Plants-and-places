import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

ProgressDialog buildProgressDialog(BuildContext context) {
  final ProgressDialog loadingDialog = ProgressDialog(context);
  loadingDialog.style(
      borderRadius: 12.0,
      backgroundColor: Colors.white,
      progressWidget: CircularProgressIndicator(),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progressTextStyle: TextStyle(
          color: Theme.of(context).accentColor,
          fontSize: 13.0,
          fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Theme.of(context).accentColor,
          fontSize: 19.0,
          fontWeight: FontWeight.w600));
  return loadingDialog;
}

import 'package:flutter/material.dart';

class DefaultLoading extends StatelessWidget {
  const DefaultLoading({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor:
              new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}

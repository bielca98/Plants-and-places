import 'package:flutter/material.dart';

InputDecoration customDecoration(var context, String hintText, IconData icon) =>
    InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: BorderSide(
          color: Colors.redAccent,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 2.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: BorderSide(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );

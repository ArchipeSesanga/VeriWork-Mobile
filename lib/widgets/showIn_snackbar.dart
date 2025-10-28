import 'package:flutter/material.dart';

void showInSnackBar(String value, Color bgColor, context) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        value,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary),
      ),
      backgroundColor: bgColor,
    ),
  );
}

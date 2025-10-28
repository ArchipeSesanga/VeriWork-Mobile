import 'package:flutter/material.dart'
    show Color, FontWeight, ScaffoldMessenger, SnackBar, Text, TextStyle, Theme;

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

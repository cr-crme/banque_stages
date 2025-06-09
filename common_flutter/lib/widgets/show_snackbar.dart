import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 5),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      duration: duration,
    ),
  );
}

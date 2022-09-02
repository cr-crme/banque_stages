import 'package:flutter/material.dart';

abstract class FormService {
  static bool validateForm(GlobalKey<FormState> formKey) {
    if (formKey.currentContext == null || formKey.currentState == null) {
      return false;
    }

    ScaffoldMessenger.of(formKey.currentContext!).clearSnackBars();
    if (formKey.currentState!.validate()) return true;

    ScaffoldMessenger.of(formKey.currentContext!).showSnackBar(
      const SnackBar(
        content: Text("Assurez vous que tous les champs soient valides"),
      ),
    );
    return false;
  }
}

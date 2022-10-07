import 'package:flutter/material.dart';

abstract class FormService {
  static bool validateForm(GlobalKey<FormState> formKey) {
    if (formKey.currentContext == null || formKey.currentState == null) {
      return false;
    }

    ScaffoldMessenger.of(formKey.currentContext!).clearSnackBars();

    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(formKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text("Assurez vous que tous les champs soient valides"),
        ),
      );
      return false;
    }

    return true;
  }

  static String? textNotEmptyValidator(String? text) {
    if (text!.isEmpty) {
      return "Le champ ne peut pas être vide";
    }
    return null;
  }

  static String? neqValidator(String? neq) {
    if (neq == null) return null;
    if (neq.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(neq)) {
      return "Le NEQ est composé de 10 chiffres";
    }
    return null;
  }

  static String? phoneValidator(String? phone) {
    if (phone!.isEmpty) {
      return "Le champ ne peut pas être vide";
    } else if (!RegExp(
            r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$')
        .hasMatch(phone)) {
      return "Le numéro entré n'est pas valide";
    }
    return null;
  }

  static String? emailValidator(String? email) {
    if (email == null || email.isEmpty) {
      return "Please enter an email";
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      return "Please enter a valid email";
    }
    return null;
  }

  static String? usernameValidator(String? username) {
    if (username == null || username.isEmpty) {
      return "Please enter a username";
    }
    return null;
  }

  static String? passwordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return "Please enter a password";
    }
    return null;
  }

  static String? passwordConfirmationValidator(
    String? confirmPassword,
    String? password,
  ) {
    if (password == null || password.isEmpty || confirmPassword == null) {
      return null;
    }
    if (confirmPassword != password) {
      return "Passwords don't match";
    }
    return null;
  }
}

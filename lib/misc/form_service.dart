import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      return _localizations.emptyFieldError;
    }
    return null;
  }

  static String? neqValidator(String? neq) {
    if (neq == null) return null;
    if (neq.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(neq)) {
      return _localizations.invalidNeqError;
    }
    return null;
  }

  static String? phoneValidator(String? phone) {
    if (phone!.isEmpty) {
      return _localizations.emptyPhoneError;
    } else if (!RegExp(
            r"^(?:\+\d{1,3})?\s?\(?\d{3}(?:[-.\)\s]|\)\s)?\d{3}[-.\s]?\d{4,6}(?:\s(?:poste)?\s\d{1,6})?$")
        .hasMatch(phone)) {
      return _localizations.invalidPhoneError;
    }
    return null;
  }

  static String? emailValidator(String? email) {
    if (email == null || email.isEmpty) {
      return _localizations.emptyEmailError;
    }
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$")
        .hasMatch(email)) {
      return _localizations.invalidEmailError;
    }
    return null;
  }

  static String? usernameValidator(String? username) {
    if (username == null || username.isEmpty) {
      return _localizations.emptyUsernameError;
    }
    return null;
  }

  static String? passwordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return _localizations.emptyFieldError;
    } else if (password.length < 8) {
      return _localizations.invalidPasswordError;
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
      return _localizations.passwordMatchError;
    }
    return null;
  }

  static late BuildContext _context;
  static set setContext(BuildContext context) => _context = context;
  static AppLocalizations get _localizations => AppLocalizations.of(_context)!;
}

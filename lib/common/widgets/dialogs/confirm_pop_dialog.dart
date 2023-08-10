import 'package:flutter/material.dart';

class ConfirmExitDialog {
  static Future<bool> show(
    BuildContext context, {
    required String message,
    bool? isEditing,
  }) async {
    if (isEditing != null && !isEditing) return true;

    ScaffoldMessenger.of(context).clearSnackBars();

    return await showDialog<bool>(
            context: context,
            builder: (context) => _ConfirmExitDialog(message: message)) ??
        false;
  }
}

class _ConfirmExitDialog extends StatelessWidget {
  const _ConfirmExitDialog({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Voulez-vous quitter?'),
          content: SingleChildScrollView(child: Text(message)),
          actions: [
            OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Non')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Quitter'))
          ],
        ));
  }
}

import 'package:flutter/material.dart';

class ConfirmExitDialog {
  static Future<bool> show(
    BuildContext context, {
    required Widget content,
    bool? isEditing,
  }) async {
    if (isEditing != null && !isEditing) return true;

    ScaffoldMessenger.of(context).clearSnackBars();

    return await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => _ConfirmExitDialog(content: content)) ??
        false;
  }
}

class _ConfirmExitDialog extends StatelessWidget {
  const _ConfirmExitDialog({required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Voulez-vous quitter?'),
          content: SingleChildScrollView(child: content),
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

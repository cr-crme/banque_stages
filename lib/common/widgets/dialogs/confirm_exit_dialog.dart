import 'package:flutter/material.dart';

class ConfirmExitDialog extends StatelessWidget {
  const ConfirmExitDialog({super.key, required this.content});

  final Widget content;

  // coverage:ignore-start
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
            builder: (context) => ConfirmExitDialog(content: content)) ??
        false;
  }
  // coverage:ignore-end

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false, // coverage:ignore-line
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

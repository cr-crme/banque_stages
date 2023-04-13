import 'package:flutter/material.dart';

class ConfirmPopDialog extends StatelessWidget {
  const ConfirmPopDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Voulez-vous vraiment quitter?'),
          content: const SingleChildScrollView(
              child: Text('Vous allez perdre toutes vos modifications.')),
          actions: [
            OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Non')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Oui'))
          ],
        ));
  }

  static Future<bool> show(BuildContext context, {bool? editing}) async {
    if (editing != null && !editing) return true;

    ScaffoldMessenger.of(context).clearSnackBars();

    return await showDialog(
        context: context, builder: (context) => const ConfirmPopDialog());
  }
}

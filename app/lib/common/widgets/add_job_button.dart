import 'package:flutter/material.dart';

class AddJobButton extends StatelessWidget {
  const AddJobButton({
    super.key,
    required this.onPressed,
    this.style,
  });

  final VoidCallback onPressed;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        key: key,
        onPressed: onPressed,
        style: style,
        icon: const Icon(Icons.business_center_rounded),
        label: const Text('Ajouter un métier'));
  }
}

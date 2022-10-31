import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
    required this.onPressed,
    this.visualDensity,
    this.padding = const EdgeInsets.all(8.0),
    this.alignment = Alignment.center,
    this.focusNode,
    this.autofocus = false,
  });

  final void Function()? onPressed;
  final VisualDensity? visualDensity;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: key,
      onPressed: onPressed,
      visualDensity: visualDensity,
      padding: padding,
      alignment: alignment,
      focusNode: focusNode,
      autofocus: autofocus,
      tooltip: "Supprimer",
      icon: const Icon(Icons.delete_forever),
      color: Theme.of(context).colorScheme.error,
    );
  }
}

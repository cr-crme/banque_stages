import 'package:flutter/material.dart';

class AddTextDialog extends StatefulWidget {
  const AddTextDialog({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<AddTextDialog> createState() => _AddTextDialogState();
}

class _AddTextDialogState extends State<AddTextDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _comment;

  void _showInvalidFieldsSnakBar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Assurez vous que tous les champs soient valides")));
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) {
      _showInvalidFieldsSnakBar();
      return;
    }

    _formKey.currentState!.save();
    Navigator.pop(context, _comment);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          onSaved: (text) => _comment = text,
          validator: (text) {
            if (text!.isEmpty) return "Veuillez écrire quelque chose.";

            return null;
          },
          keyboardType: TextInputType.multiline,
          minLines: 4,
          maxLines: null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _onCancel,
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: _onConfirm,
          child: const Text("Ajouter"),
        ),
      ],
    );
  }
}

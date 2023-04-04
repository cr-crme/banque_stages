import 'package:flutter/material.dart';

import '/misc/form_service.dart';

class AddTextDialog extends StatefulWidget {
  const AddTextDialog({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<AddTextDialog> createState() => _AddTextDialogState();
}

class _AddTextDialogState extends State<AddTextDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _comment;

  void _onCancel() {
    Navigator.pop(context);
  }

  void _onConfirm() {
    if (FormService.validateForm(_formKey, save: true)) {
      Navigator.pop(context, _comment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          onSaved: (text) => _comment = text,
          validator: FormService.textNotEmptyValidator,
          keyboardType: TextInputType.multiline,
          minLines: 4,
          maxLines: null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _onCancel,
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _onConfirm,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/providers/activity_types_provider.dart';

class ActivityTypesSelectorDialog extends StatefulWidget {
  const ActivityTypesSelectorDialog({Key? key}) : super(key: key);

  @override
  State<ActivityTypesSelectorDialog> createState() =>
      _ActivityTypesSelectorDialogState();
}

class _ActivityTypesSelectorDialogState
    extends State<ActivityTypesSelectorDialog> {
  final _formKey = GlobalKey<FormState>();

  void _close() {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Type d'activités"),
        content: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Consumer<ActivityTypesProvider>(
                builder: (context, provider, child) => Column(
                    children: provider.activityTypes.keys
                        .map((key) => CheckboxListTile(
                            title: Text(key.humanName),
                            value: provider.activityTypes[key],
                            onChanged: (value) => provider.update(key, value!)))
                        .toList()),
              )),
        ),
        actions: [
          TextButton(onPressed: () => _close(), child: const Text("Ok")),
        ]);
  }
}

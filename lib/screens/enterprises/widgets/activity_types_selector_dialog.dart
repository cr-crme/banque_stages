import 'package:flutter/material.dart';

import '/common/models/activity_types.dart';

class ActivityTypesSelectorDialog extends StatefulWidget {
  const ActivityTypesSelectorDialog({Key? key, required this.activityTypes})
      : super(key: key);

  final Map<ActivityTypes, bool> activityTypes;

  @override
  State<ActivityTypesSelectorDialog> createState() =>
      _ActivityTypesSelectorDialogState();
}

class _ActivityTypesSelectorDialogState
    extends State<ActivityTypesSelectorDialog> {
  final _formKey = GlobalKey<FormState>();

  Map<ActivityTypes, bool> get _activityTypes => super.widget.activityTypes;

  void _close() {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    Navigator.pop(context, _activityTypes);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Type d'activités"),
        content: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Column(
                  children: _activityTypes.keys
                      .map((key) => CheckboxListTile(
                          title: Text(key.humanName),
                          value: _activityTypes[key],
                          onChanged: (value) =>
                              setState(() => _activityTypes[key] = value!)))
                      .toList())),
        ),
        actions: [
          TextButton(onPressed: () => _close(), child: const Text("Ok")),
        ]);
  }
}

import 'package:flutter/material.dart';

import '/common/models/activity_type.dart';

class ActivityTypesSelectorDialog extends StatefulWidget {
  const ActivityTypesSelectorDialog({Key? key}) : super(key: key);

  @override
  State<ActivityTypesSelectorDialog> createState() =>
      _ActivityTypesSelectorDialogState();
}

class _ActivityTypesSelectorDialogState
    extends State<ActivityTypesSelectorDialog> {
  final _formKey = GlobalKey<FormState>();

  late Set<ActivityType> activityTypes =
      ModalRoute.of(context)!.settings.arguments as Set<ActivityType>;

  void _close() {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    Navigator.pop(context, activityTypes);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _close();
        return true;
      },
      child: AlertDialog(
          title: const Text("Type d'activités"),
          content: SingleChildScrollView(
              child: Form(
            key: _formKey,
            child: Column(
                children: ActivityType.values
                    .map((activityType) => CheckboxListTile(
                        title: Text(activityType.toString()),
                        value: activityTypes.contains(activityType),
                        onChanged: (value) => setState(() {
                              if (value!) {
                                activityTypes.add(activityType);
                              } else {
                                activityTypes.remove(activityType);
                              }
                            })))
                    .toList()),
          )),
          actions: [
            TextButton(onPressed: () => _close(), child: const Text("Ok")),
          ]),
    );
  }
}

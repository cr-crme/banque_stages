import 'package:flutter/material.dart';

import '/common/models/activity_type.dart';

class ActivityTypesSelectorDialog extends StatefulWidget {
  const ActivityTypesSelectorDialog({Key? key, required this.initialValue})
      : super(key: key);

  final Set<ActivityType> initialValue;

  @override
  State<ActivityTypesSelectorDialog> createState() =>
      _ActivityTypesSelectorDialogState();
}

class _ActivityTypesSelectorDialogState
    extends State<ActivityTypesSelectorDialog> {
  final _formKey = GlobalKey<FormState>();

  Set<ActivityType>? _activityTypes;

  void _close() {
    _formKey.currentState!.save();

    Navigator.pop(context, _activityTypes);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _close();
        return false;
      },
      child: AlertDialog(
          title: const Text("Type d'activités"),
          content: Form(
            key: _formKey,
            child: ActivityTypesFormField(
              initialValue: widget.initialValue,
              onSaved: (Set<ActivityType>? activityTypes) =>
                  _activityTypes = activityTypes,
            ),
          ),
          actions: [
            TextButton(onPressed: () => _close(), child: const Text("Ok")),
          ]),
    );
  }
}

class ActivityTypesFormField extends FormField<Set<ActivityType>> {
  const ActivityTypesFormField(
      {Key? key,
      required Set<ActivityType> initialValue,
      FormFieldSetter<Set<ActivityType>>? onSaved,
      FormFieldValidator<Set<ActivityType>>? validator,
      AutovalidateMode? autovalidateMode})
      : super(
            key: key,
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            autovalidateMode: autovalidateMode,
            builder: _builder);

  static Widget _builder(FormFieldState<Set<ActivityType>> state) {
    return SizedBox(
      width: 200,
      height: 300,
      child: ListView.builder(
          itemCount: ActivityType.values.length,
          itemBuilder: (context, index) {
            ActivityType activityType = ActivityType.values[index];

            return CheckboxListTile(
                title: Text(activityType.toString()),
                value: state.value!.contains(activityType),
                onChanged: (value) {
                  // Set<ActivityType> set = Set.of(state.value!);

                  if (value!) {
                    // set.add(activityType);
                    state.value!.add(activityType);
                  } else {
                    // set.remove(activityType);
                    state.value!.remove(activityType);
                  }

                  // state.didChange(set);
                  state.didChange(state.value);
                });
          }),
    );
  }
}

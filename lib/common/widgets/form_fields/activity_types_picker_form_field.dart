import 'package:flutter/material.dart';

import '/common/models/enterprise.dart';
import '/common/widgets/activity_type_cards.dart';

class ActivityTypesPickerFormField extends FormField<Set<String>> {
  ActivityTypesPickerFormField({
    Key? key,
    Set<String>? initialValue,
    void Function(Set<String>? activityTypes)? onSaved,
    String? Function(Set<String>? activityTypes)? validator,
  }) : super(
          key: key,
          initialValue: initialValue ?? {},
          onSaved: onSaved,
          validator: validator ?? _validator,
          builder: _builder,
        );

  static String? _validator(Set<String>? activityTypes) {
    if (activityTypes!.isEmpty) return "Il faut au moins un type d'activité";

    return null;
  }

  static Widget _builder(FormFieldState<Set<String>> state) {
    late TextEditingController textFieldController;
    late FocusNode textFieldFocusNode;

    return Column(
      children: [
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            return activityTypes.where(
              (activity) =>
                  activity.contains(textEditingValue.text) &&
                  !state.value!.contains(activity),
            );
          },
          onSelected: (activityType) {
            state.value!.add(activityType);
            state.didChange(state.value);
            textFieldController.text = "";
            textFieldFocusNode.unfocus();
          },
          fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
            textFieldController = controller;
            textFieldFocusNode = focusNode;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onSubmitted: (_) {
                onSubmitted();
                controller.text = "";
              },
              decoration: InputDecoration(
                labelText: "* Types d'activité",
                errorText: state.errorText,
              ),
            );
          },
        ),
        Visibility(
          visible: state.value!.isNotEmpty,
          child: const SizedBox(height: 8),
        ),
        ActivityTypeCards(
          activityTypes: state.value!,
          onDeleted: (activityType) {
            state.value!.remove(activityType);
            state.didChange(state.value);
          },
        ),
      ],
    );
  }
}

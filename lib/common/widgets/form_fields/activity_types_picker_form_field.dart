import 'package:flutter/material.dart';

import '/common/models/enterprise.dart';
import '/common/widgets/activity_type_cards.dart';
import '/common/widgets/autocomplete_options_builder.dart';

class ActivityTypesPickerFormField extends FormField<Set<String>> {
  ActivityTypesPickerFormField({
    super.key,
    Set<String>? initialValue,
    void Function(Set<String>? activityTypes)? onSaved,
    String? Function(Set<String>? activityTypes)? validator,
  }) : super(
          initialValue: initialValue ?? {},
          onSaved: onSaved,
          validator: validator ?? _validator,
          builder: _builder,
        );

  static String? _validator(Set<String>? activityTypes) {
    if (activityTypes!.isEmpty) return 'Ajouter au moins un type d\'activité.';

    return null;
  }

  static Widget _builder(FormFieldState<Set<String>> state) {
    late TextEditingController textFieldController;
    late FocusNode textFieldFocusNode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text == '') return [];

            return activityTypes.where(
              (activity) =>
                  activity
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()) &&
                  !state.value!.contains(activity),
            );
          },
          optionsViewBuilder: (context, onSelected, options) =>
              OptionsBuilderForAutocomplete(
                  onSelected: onSelected,
                  options: options,
                  optionToString: (String e) => e),
          onSelected: (activityType) {
            state.value!.add(activityType);
            state.didChange(state.value);
            textFieldController.text = '';
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
                controller.text = '';
              },
              decoration: InputDecoration(
                  labelText: '* Types d\'activité',
                  errorText: state.errorText,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.text = '',
                  )),
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

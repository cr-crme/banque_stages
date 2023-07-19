import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/widgets/activity_type_cards.dart';
import 'package:crcrme_banque_stages/common/widgets/autocomplete_options_builder.dart';

class ActivityTypesPickerFormField extends FormField<Set<String>> {
  ActivityTypesPickerFormField({
    super.key,
    Set<String>? initialValue,
    void Function(Set<String>? activityTypes)? onSaved,
    String? Function(Set<String>? activityTypes)? validator,
    required this.activityTabAtTop,
  }) : super(
          initialValue: initialValue ?? {},
          onSaved: onSaved,
          validator: validator ?? _validator,
          builder: _builder,
        );

  final bool activityTabAtTop;

  static String? _validator(Set<String>? activityTypes) {
    if (activityTypes!.isEmpty) return 'Ajouter au moins un type d\'activité.';

    return null;
  }

  static Widget _builder(FormFieldState<Set<String>> state) {
    late TextEditingController textFieldController;
    late FocusNode textFieldFocusNode;
    final activityTabAtTop =
        (state.widget as ActivityTypesPickerFormField).activityTabAtTop;

    final activityTabs = ActivityTypeCards(
      activityTypes: state.value!,
      onDeleted: (activityType) {
        state.value!.remove(activityType);
        state.didChange(state.value);
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activityTabAtTop) activityTabs,
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            return activityTypes.where(
              (activity) =>
                  activity
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase().trim()) &&
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
                  labelText: '* Type d\'activité de l\'entreprise',
                  errorText: state.errorText,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      if (focusNode.hasFocus) focusNode.nextFocus();

                      controller.text = '';
                    },
                  )),
            );
          },
        ),
        if (!activityTabAtTop) const SizedBox(height: 8),
        if (!activityTabAtTop) activityTabs,
      ],
    );
  }
}

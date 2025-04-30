import 'package:common/models/enterprises/enterprise.dart';
import 'package:crcrme_banque_stages/common/widgets/activity_type_cards.dart';
import 'package:crcrme_banque_stages/common/widgets/autocomplete_options_builder.dart';
import 'package:flutter/material.dart';

class ActivityTypesPickerFormField extends FormField<Set<ActivityTypes>> {
  ActivityTypesPickerFormField({
    super.key,
    Set<ActivityTypes>? initialValue,
    super.onSaved,
    String? Function(Set<ActivityTypes>? activityTypes)? validator,
    required this.activityTabAtTop,
  }) : super(
          initialValue: initialValue ?? {},
          validator: validator ?? _validator,
          builder: _builder,
        );

  final bool activityTabAtTop;

  static String? _validator(Set<ActivityTypes>? activityTypes) {
    if (activityTypes!.isEmpty) return 'Choisir au moins un type d\'activité.';

    return null;
  }

  static Widget _builder(FormFieldState<Set<ActivityTypes>> state) {
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
            return ActivityTypes.values.map<String>((e) => e.name).where(
                  (activity) =>
                      activity.toLowerCase().contains(
                          textEditingValue.text.toLowerCase().trim()) &&
                      !state.value!
                          .contains(ActivityTypes.fromString(activity)),
                );
          },
          optionsViewBuilder: (context, onSelected, options) =>
              OptionsBuilderForAutocomplete(
                  onSelected: onSelected,
                  options: options,
                  optionToString: (String e) => e),
          onSelected: (activityType) {
            state.value!.add(ActivityTypes.fromString(activityType));
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

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
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
    final GlobalKey<AutoCompleteTextFieldState<String>> autoCompleteKey =
        GlobalKey();

    return Column(
      children: [
        AutoCompleteTextField<String>(
          decoration: InputDecoration(
              labelText: "* Types d'activité", errorText: state.errorText),
          key: autoCompleteKey,
          itemSubmitted: (activityType) {
            state.value!.add(activityType);
            state.didChange(state.value);
          },
          suggestions: activityTypes,
          itemBuilder: (context, suggestion) =>
              ListTile(title: Text(suggestion.toString())),
          itemSorter: (a, b) => a.toString().compareTo(b.toString()),
          itemFilter: (suggestion, query) =>
              !state.value!.contains(suggestion) &&
              suggestion
                  .toString()
                  .toLowerCase()
                  .startsWith(query.toLowerCase()),
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

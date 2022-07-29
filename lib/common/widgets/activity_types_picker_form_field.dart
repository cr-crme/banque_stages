import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';

import '/common/models/activity_type.dart';
import '/common/widgets/activity_type_cards.dart';

class ActivityTypesPickerFormField extends FormField<Set<ActivityType>> {
  const ActivityTypesPickerFormField({
    Key? key,
    Set<ActivityType> initialValue = const {},
    void Function(Set<ActivityType>?)? onSaved,
    String? Function(Set<ActivityType>?)? validator,
  }) : super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator ?? _validator,
          builder: _builder,
        );

  static String? _validator(Set<ActivityType>? activityTypes) {
    if (activityTypes!.isEmpty) return "Il faut au moins un type d'activité";

    return null;
  }

  static Widget _builder(FormFieldState<Set<ActivityType>> state) {
    final GlobalKey<AutoCompleteTextFieldState<ActivityType>> autoCompleteKey =
        GlobalKey();

    return ListTile(
      title: Column(
        children: [
          AutoCompleteTextField<ActivityType>(
            decoration: InputDecoration(
                labelText: "* Types d'activité", errorText: state.errorText),
            key: autoCompleteKey,
            itemSubmitted: (activityType) {
              try {
                state.value!.add(activityType);
                state.didChange(state.value);
              } catch (e) {
                var value = Set.of(state.value!);
                value.add(activityType);
                state.didChange(value);
              }
            },
            suggestions: ActivityType.values,
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
      ),
    );
  }
}

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '/common/widgets/autocomplete_options_builder.dart';

const List<String> shareWithSuggestions = [
  'Tout le monde',
  'Personne',
  'Mon service scolaire',
  'Mon école'
];

class ShareWithPickerFormField extends FormField<String> {
  const ShareWithPickerFormField({
    super.key,
    String initialValue = 'Tout le monde',
    void Function(String? shareWith)? onSaved,
    String? Function(String? shareWith)? validator,
  }) : super(
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator ?? _validator,
          builder: _builder,
        );

  static String? _validator(String? input) {
    if (!shareWithSuggestions.contains(input)) {
      return 'Entrez une valeur valide';
    }

    return null;
  }

  static Widget _builder(FormFieldState<String> state) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: state.value ?? ''),
      optionsBuilder: (textEditingValue) {
        return shareWithSuggestions.where(
          (activity) => activity.contains(textEditingValue.text),
        );
      },
      optionsViewBuilder: (context, onSelected, options) =>
          OptionsBuilderForAutocomplete(
        onSelected: onSelected,
        options: options,
        optionToString: (String e) => e,
      ),
      onSelected: (item) => state.didChange(item),
      fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onSubmitted: (_) => onSubmitted(),
          onChanged: (text) {
            state.didChange(shareWithSuggestions
                .firstWhereOrNull((suggestion) => suggestion == text));
          },
          decoration: InputDecoration(
            labelText: '* Partager l\'entreprise avec',
            errorText: state.errorText,
          ),
        );
      },
    );
  }
}

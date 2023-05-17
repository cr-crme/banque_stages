import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/widgets/autocomplete_options_builder.dart';

const List<String> shareWithSuggestions = [
  'Mon centre de services scolaire',
  'Enseignants PFAE de l\'école',
  'Enseignants FMS de l\'école',
  'Enseignants FPT de l\'école',
  'Aucun partage',
];

class ShareWithPickerFormField extends FormField<String> {
  const ShareWithPickerFormField({
    super.key,
    String initialValue = 'Enseignants PFAE de l\'école',
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
        return shareWithSuggestions;
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
            if (!shareWithSuggestions.contains(text)) {
              controller.text = '';
              return;
            }
            state.didChange(shareWithSuggestions
                .firstWhereOrNull((suggestion) => suggestion == text));
          },
          decoration: InputDecoration(
              labelText: '* Sélectionner avec qui partager l\'entreprise',
              errorText: state.errorText,
              suffixIcon: const Icon(Icons.expand_more, color: Colors.black)),
        );
      },
    );
  }
}

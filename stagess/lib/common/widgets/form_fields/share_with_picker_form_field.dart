import 'package:flutter/material.dart';
import 'package:stagess_common_flutter/widgets/autocomplete_options_builder.dart';

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
    String super.initialValue = 'Enseignants PFAE de l\'école',
    super.onSaved,
    String? Function(String? shareWith)? validator,
  }) : super(
          validator: validator ?? _validator,
          builder: _builder,
        );

  static String? _validator(String? input) {
    if (!shareWithSuggestions.contains(input)) {
      return 'Sélectionner avec qui partager';
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
          readOnly: true,
          decoration: InputDecoration(
              labelText: '* Partager l\'entreprise avec',
              errorText: state.errorText,
              suffixIcon: IconButton(
                  onPressed: () {
                    if (focusNode.hasFocus) {
                      focusNode.previousFocus();
                    }

                    controller.text = '';
                    state.didChange(null);
                  },
                  icon: const Icon(Icons.clear))),
        );
      },
    );
  }
}

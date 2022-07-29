import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';

const List<String> shareWithSuggestions = [
  "Tout le monde",
  "Personne",
  "Mon service scolaire",
  "Mon école"
];

class ShareWithPickerFormField extends FormField<String> {
  const ShareWithPickerFormField({
    Key? key,
    String initialValue = "Tout le monde",
    void Function(String? text)? onSaved,
    String? Function(String? text)? validator,
  }) : super(
          key: key,
          initialValue: initialValue,
          onSaved: onSaved,
          validator: validator ?? _validator,
          builder: _builder,
        );

  static String? _validator(String? input) {
    if (!shareWithSuggestions.contains(input)) {
      return "Entrez une valeur valide";
    }

    return null;
  }

  static Widget _builder(FormFieldState<String> state) {
    return ListTile(
      title: AutoCompleteTextField<String>(
        key: GlobalKey(),
        controller: TextEditingController(text: state.value),
        decoration: InputDecoration(
          labelText: "* Partager l'entreprise avec",
          errorText: state.errorText,
        ),
        textSubmitted: (item) => state.didChange(item),
        itemSubmitted: (item) => state.didChange(item),
        clearOnSubmit: false,
        suggestions: shareWithSuggestions,
        itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion)),
        itemSorter: (a, b) => a.compareTo(b),
        minLength: 0,
        itemFilter: (suggestion, query) =>
            suggestion.toString().toLowerCase().startsWith(query.toLowerCase()),
      ),
    );
  }
}

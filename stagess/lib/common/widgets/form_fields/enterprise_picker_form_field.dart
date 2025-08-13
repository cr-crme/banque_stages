import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:stagess_common/models/enterprises/enterprise.dart';
import 'package:stagess_common_flutter/widgets/autocomplete_options_builder.dart';

class EnterprisePickerFormField extends StatelessWidget {
  const EnterprisePickerFormField({
    super.key,
    required this.enterprises,
    this.initialValue,
    this.onSaved,
    this.onSelect,
    this.validator,
  });

  final Enterprise? initialValue;
  final List<Enterprise> enterprises;
  final void Function(Enterprise? enterprise)? onSaved;
  final String? Function(Enterprise? enterprise)? validator;
  final void Function(Enterprise? enterprise)? onSelect;

  static String? _validator(Enterprise? enterprise) {
    return enterprise == null ? 'Sélectionner une entreprise.' : null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Enterprise>(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: validator ?? _validator,
      builder: (state) => Column(
        children: [
          Autocomplete<Enterprise>(
            displayStringForOption: (enterprise) => enterprise.name,
            initialValue: TextEditingValue(text: initialValue?.name ?? ''),
            optionsBuilder: (input) {
              return {...enterprises}
                  .sorted((a, b) => a.name.compareTo(b.name))
                  .where(
                    (s) =>
                        s.name.toLowerCase().contains(input.text.toLowerCase()),
                  );
            },
            optionsViewBuilder: (context, onSelected, options) =>
                OptionsBuilderForAutocomplete(
              onSelected: onSelected,
              options: options,
              optionToString: (Enterprise e) => e.name,
            ),
            onSelected: (enterprise) {
              FocusManager.instance.primaryFocus?.unfocus();
              state.didChange(enterprise);
              onSelect == null ? null : onSelect!(enterprise);
            },
            fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onSubmitted: (_) => onSubmitted(),
                decoration: InputDecoration(
                  labelText: '* Entreprise',
                  hintText: 'Saisir le nom de l\'entreprise',
                  errorText: state.errorText,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/widgets/autocomplete_options_builder.dart';

class StudentPickerFormField extends StatelessWidget {
  const StudentPickerFormField({
    super.key,
    required this.students,
    this.initialValue,
    this.onSaved,
    this.onSelect,
    this.validator,
  });

  final Student? initialValue;
  final List<Student> students;
  final void Function(Student? student)? onSaved;
  final String? Function(Student? student)? validator;
  final void Function(Student?)? onSelect;

  static String? _validator(Student? student) {
    return student == null ? 'Sélectionner un élève.' : null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Student>(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: validator ?? _validator,
      builder: (state) => Column(
        children: [
          Autocomplete<Student>(
            displayStringForOption: (student) => student.fullName,
            initialValue: TextEditingValue(text: initialValue?.fullName ?? ''),
            optionsBuilder: (input) {
              return {...students}
                  .sorted((a, b) => a.lastName.compareTo(b.lastName))
                  .where(
                    (s) => s.fullName
                        .toLowerCase()
                        .contains(input.text.toLowerCase()),
                  );
            },
            optionsViewBuilder: (context, onSelected, options) =>
                OptionsBuilderForAutocomplete(
              onSelected: onSelected,
              options: options,
              optionToString: (Student e) => e.fullName,
            ),
            onSelected: (student) {
              FocusManager.instance.primaryFocus?.unfocus();
              state.didChange(student);
              onSelect == null ? null : onSelect!(student);
            },
            fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onSubmitted: (_) => onSubmitted(),
                decoration: InputDecoration(
                    labelText: '* Élève',
                    hintText: 'Saisir le nom de l\'élève',
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
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '/common/models/student.dart';

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
    return student == null ? "Ce champ est obligatoire" : null;
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
            initialValue: TextEditingValue(text: initialValue?.fullName ?? ""),
            optionsBuilder: (input) {
              return students.where(
                (s) =>
                    s.fullName.toLowerCase().contains(input.text.toLowerCase()),
              );
            },
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
                  labelText: "* Élève",
                  hintText: 'Saisir le nom de l\'élève',
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

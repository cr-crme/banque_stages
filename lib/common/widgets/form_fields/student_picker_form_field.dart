import 'package:flutter/material.dart';

import '/common/models/student.dart';

class StudentPickerFormField extends StatelessWidget {
  const StudentPickerFormField({
    super.key,
    required this.students,
    this.initialValue,
    this.onSaved,
    this.validator,
  });

  final Student? initialValue;
  final List<Student> students;
  final void Function(Student? student)? onSaved;
  final String? Function(Student? student)? validator;

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
            displayStringForOption: (student) => student.name,
            initialValue: TextEditingValue(text: initialValue?.name ?? ""),
            optionsBuilder: (input) {
              return students.where(
                (s) => s.name.toLowerCase().contains(input.text.toLowerCase()),
              );
            },
            onSelected: (student) => state.didChange(student),
            fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onSubmitted: (_) => onSubmitted(),
                decoration: InputDecoration(
                  labelText: "* Élève",
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

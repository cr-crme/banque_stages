import 'package:admin_app/providers/teachers_provider.dart';
import 'package:admin_app/widgets/autocomplete_options_builder.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:flutter/material.dart';

class TeacherPickerController {
  Teacher _selection;
  Teacher get teacher => _selection;
  set teacher(Teacher value) {
    _selection = value;
    // TODO Add a call to state.didChange(value) if this is a FormField
  }

  TeacherPickerController({required Teacher? initial})
    : _selection = initial ?? Teacher.empty;

  void dispose() {}
}

class TeacherPickerTile extends StatelessWidget {
  const TeacherPickerTile({
    super.key,
    required this.controller,
    required this.editMode,
  });

  final TeacherPickerController controller;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return FormField(
      initialValue: controller._selection.fullName,
      validator: (input) => _validator(context, input),
      builder: (field) => _builder(context, field),
      enabled: editMode,
    );
  }

  String? _validator(BuildContext context, String? input) {
    final teachers = TeachersProvider.of(context, listen: false);
    final selectedTeacher = teachers.firstWhereOrNull(
      (teacher) => teacher.fullName == input,
    );

    controller._selection = selectedTeacher ?? Teacher.empty;

    if (selectedTeacher == null) {
      return 'Sélectionner l\'enseignant·e ayant démarché l\'entreprise';
    }

    return null;
  }

  Widget _builder(BuildContext context, FormFieldState<String> state) {
    final teachers = TeachersProvider.of(context, listen: true);

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: state.value ?? ''),
      optionsBuilder: (textEditingValue) {
        return teachers.map((teacher) => teacher.fullName).where((
          String option,
        ) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      optionsViewBuilder:
          (context, onSelected, options) => OptionsBuilderForAutocomplete(
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
          enabled: editMode,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: 'Enseignant·e ayant démarché l\'entreprise',
            labelStyle: const TextStyle(color: Colors.black),
            errorText: state.errorText,
            suffixIcon: IconButton(
              onPressed: () {
                if (focusNode.hasFocus) {
                  focusNode.previousFocus();
                }

                controller.text = '';
                state.didChange(null);
              },
              icon: const Icon(Icons.clear),
            ),
          ),
        );
      },
    );
  }
}

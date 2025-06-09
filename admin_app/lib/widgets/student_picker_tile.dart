import 'package:admin_app/widgets/autocomplete_options_builder.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/utils.dart';
import 'package:common_flutter/providers/students_provider.dart';
import 'package:flutter/material.dart';

class StudentPickerController {
  TextEditingController? _textController;

  Student _selection;
  Student get student => _selection;
  set student(Student value) {
    _selection = value;
    _textController?.text = value.fullName;
    _formKey.currentState?.didChange(value.fullName);
  }

  StudentPickerController({required Student? initial})
    : _selection = initial ?? Student.empty;

  final _formKey = GlobalKey<FormFieldState<String>>();

  void dispose() {
    // Since _textController is managed by the FormField, we don't need to
    // dispose of it here.
  }
}

class StudentPickerTile extends StatelessWidget {
  const StudentPickerTile({
    super.key,
    this.title,
    required this.schoolBoardId,
    required this.controller,
    required this.editMode,
  });

  final String? title;
  final StudentPickerController controller;
  final String schoolBoardId;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return FormField<Student>(
      key: controller._formKey,
      initialValue: controller._selection,
      builder: (field) => _builder(context, field),
      enabled: editMode,
    );
  }

  Widget _builder(BuildContext context, FormFieldState<Student> state) {
    final students = StudentsProvider.of(
      context,
      listen: true,
    ).where((student) => student.schoolBoardId == schoolBoardId);

    return Autocomplete<Student>(
      initialValue: TextEditingValue(text: controller._selection.fullName),
      optionsBuilder: (textEditingValue) {
        // We kind of hijack this builder to test the current status of the text.
        // If it fits a student, or if it is empty, we set that value to the
        // current selection.
        if (textEditingValue.text.isEmpty) {
          controller._selection = Student.empty;
        } else {
          final selectedStudent = students.firstWhereOrNull(
            (student) =>
                student.fullName.toLowerCase() ==
                textEditingValue.text.toLowerCase(),
          );
          if (selectedStudent != null) {
            controller._selection = selectedStudent;
          }
        }

        // We show everything if there is no text. Otherwise, we show only if
        // the names containing that approach the text.
        if (textEditingValue.text.isEmpty) return students;
        return students.where(
          (student) =>
              student.fullName.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ) &&
              student.fullName.toLowerCase() !=
                  textEditingValue.text.toLowerCase(),
        );
      },
      optionsViewBuilder:
          (context, onSelected, options) => OptionsBuilderForAutocomplete(
            onSelected: onSelected,
            options: options,
            optionToString: (Student e) => e.fullName,
          ),
      onSelected: (item) => controller.student = item,
      fieldViewBuilder: (_, textController, focusNode, onSubmitted) {
        controller._textController = textController;

        return TextField(
          controller: controller._textController,
          focusNode: focusNode,
          readOnly: false,
          enabled: editMode,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: title ?? 'Sélectionner un·e élève',
            labelStyle: const TextStyle(color: Colors.black),
            errorText: state.errorText,
            suffixIcon: IconButton(
              onPressed: () {
                if (focusNode.hasFocus) focusNode.previousFocus();
                controller.student = Student.empty;
                textController.clear();
                state.didChange(Student.empty);
              },
              icon: const Icon(Icons.clear),
            ),
          ),
        );
      },
    );
  }
}

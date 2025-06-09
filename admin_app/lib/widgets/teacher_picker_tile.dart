import 'package:admin_app/widgets/autocomplete_options_builder.dart';
import 'package:collection/collection.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:flutter/material.dart';

class TeacherPickerController {
  TextEditingController? _textController;

  Teacher _selection;
  Teacher get teacher => _selection;
  set teacher(Teacher value) {
    _selection = value;
    _textController?.text = value.fullName;
    _formKey.currentState?.didChange(value.fullName);
  }

  TeacherPickerController({required Teacher? initial})
    : _selection = initial ?? Teacher.empty;

  final _formKey = GlobalKey<FormFieldState<String>>();

  void dispose() {
    // Since _textController is managed by the FormField, we don't need to
    // dispose of it here.
  }
}

class TeacherPickerTile extends StatelessWidget {
  const TeacherPickerTile({
    super.key,
    this.title,
    required this.schoolBoardId,
    required this.controller,
    required this.editMode,
  });

  final String? title;
  final TeacherPickerController controller;
  final String schoolBoardId;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return FormField<Teacher>(
      key: controller._formKey,
      initialValue: controller._selection,
      builder: (field) => _builder(context, field),
      enabled: editMode,
    );
  }

  Widget _builder(BuildContext context, FormFieldState<Teacher> state) {
    final teachers = TeachersProvider.of(
      context,
      listen: true,
    ).where((teacher) => teacher.schoolBoardId == schoolBoardId);

    return Autocomplete<Teacher>(
      initialValue: TextEditingValue(text: controller._selection.fullName),
      optionsBuilder: (textEditingValue) {
        // We kind of hijack this builder to test the current status of the text.
        // If it fits a teacher, or if it is empty, we set that value to the
        // current selection.
        if (textEditingValue.text.isEmpty) {
          controller._selection = Teacher.empty;
        } else {
          final selectedTeacher = teachers.firstWhereOrNull(
            (teacher) =>
                teacher.fullName.toLowerCase() ==
                textEditingValue.text.toLowerCase(),
          );
          if (selectedTeacher != null) {
            controller._selection = selectedTeacher;
          }
        }

        // We show everything if there is no text. Otherwise, we show only if
        // the names containing that approach the text.
        if (textEditingValue.text.isEmpty) return teachers;
        return teachers.where(
          (teacher) =>
              teacher.fullName.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ) &&
              teacher.fullName.toLowerCase() !=
                  textEditingValue.text.toLowerCase(),
        );
      },
      optionsViewBuilder:
          (context, onSelected, options) => OptionsBuilderForAutocomplete(
            onSelected: onSelected,
            options: options,
            optionToString: (Teacher e) => e.fullName,
          ),
      onSelected: (item) => controller.teacher = item,
      fieldViewBuilder: (_, textController, focusNode, onSubmitted) {
        controller._textController = textController;

        return TextField(
          controller: controller._textController,
          focusNode: focusNode,
          readOnly: false,
          enabled: editMode,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: title ?? 'Sélectionner un·e enseignant·e',
            labelStyle: const TextStyle(color: Colors.black),
            errorText: state.errorText,
            suffixIcon: IconButton(
              onPressed: () {
                if (focusNode.hasFocus) focusNode.previousFocus();
                controller.teacher = Teacher.empty;
                textController.clear();
                state.didChange(Teacher.empty);
              },
              icon: const Icon(Icons.clear),
            ),
          ),
        );
      },
    );
  }
}

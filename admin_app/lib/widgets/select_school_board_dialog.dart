import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class SelectSchoolBoardDialog extends StatefulWidget {
  const SelectSchoolBoardDialog({super.key});

  @override
  State<SelectSchoolBoardDialog> createState() =>
      _SelectSchoolBoardDialogState();
}

class _SelectSchoolBoardDialogState extends State<SelectSchoolBoardDialog> {
  final _formKey = GlobalKey<FormState>();

  String _selectedSchoolBoardId = '';

  Future<void> _onClickedConfirm() async {
    // Validate the form
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    Navigator.of(context).pop(_selectedSchoolBoardId);
  }

  void _onClickedCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final schoolBoards = SchoolBoardsProvider.of(context, listen: false);

    return AlertDialog(
      content: Form(
        key: _formKey,
        child: FormBuilderRadioGroup(
          name: 'School board selection',
          orientation: OptionsOrientation.vertical,
          decoration: InputDecoration(
            labelText: 'Sélectionner une commission scolaire',
          ),
          onChanged:
              (value) => setState(() => _selectedSchoolBoardId = value ?? '-1'),
          validator: (_) {
            return _selectedSchoolBoardId == ''
                ? 'Sélectionner une commission scolaire'
                : null;
          },
          options:
              schoolBoards
                  .map(
                    (e) => FormBuilderFieldOption(
                      value: e.id,
                      child: Text(e.name),
                    ),
                  )
                  .toList(),
        ),
      ),
      actions: [
        OutlinedButton(onPressed: _onClickedCancel, child: Text('Annuler')),
        TextButton(onPressed: _onClickedConfirm, child: Text('Confirmer')),
      ],
    );
  }
}

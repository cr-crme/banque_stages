import 'package:flutter/material.dart';

import '/common/widgets/form_fields/activity_types_picker_form_field.dart';
import '/common/widgets/form_fields/share_with_picker_form_field.dart';
import '/misc/form_service.dart';

class InformationsPage extends StatefulWidget {
  const InformationsPage({super.key});

  @override
  State<InformationsPage> createState() => InformationsPageState();
}

class InformationsPageState extends State<InformationsPage> {
  final _formKey = GlobalKey<FormState>();

  String? name;
  String? neq;

  Set<String> activityTypes = {};

  String? shareWith;

  bool validate() {
    _formKey.currentState!.save();
    return _formKey.currentState!.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(labelText: '* Nom'),
                validator: FormService.textNotEmptyValidator,
                onSaved: (name) => this.name = name,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(labelText: '* NEQ'),
                validator: FormService.neqValidator,
                onSaved: (neq) => this.neq = neq,
                keyboardType: TextInputType.number,
              ),
            ),
            ListTile(
              title: ActivityTypesPickerFormField(
                onSaved: (Set<String>? activityTypes) =>
                    setState(() => this.activityTypes = activityTypes!),
              ),
            ),
            ListTile(
              title: ShareWithPickerFormField(
                onSaved: (String? shareWith) =>
                    setState(() => this.shareWith = shareWith),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

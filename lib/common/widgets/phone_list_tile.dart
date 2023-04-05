import 'package:flutter/material.dart';

import '/common/models/phone_number.dart';
import '/misc/form_service.dart';

class PhoneListTile extends StatefulWidget {
  const PhoneListTile({
    super.key,
    this.title = 'Téléphone',
    this.initialValue,
    this.icon = Icons.phone,
    required this.onSaved,
    required this.isMandatory,
    required this.enabled,
  });

  final String title;
  final PhoneNumber? initialValue;
  final IconData icon;
  final Function(String?) onSaved;
  final bool isMandatory;
  final bool enabled;

  @override
  State<PhoneListTile> createState() => _PhoneListTileState();
}

class _PhoneListTileState extends State<PhoneListTile> {
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _phoneController.text = widget.initialValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          // On loose focus, call the phone number validator
          final newNumber =
              PhoneNumber.fromString(_phoneController.text).toString();
          if (newNumber != '') {
            setState(() => _phoneController.text = newNumber);
          }
        }
      },
      child: ListTile(
        title: TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            icon: Icon(widget.icon),
            labelText: '${widget.isMandatory ? '* ' : ''}${widget.title}',
            disabledBorder: InputBorder.none,
          ),
          validator: (value) {
            if (!widget.enabled) return null;

            if (!widget.isMandatory && (value == '' || value == null)) {
              return null;
            }
            return FormService.phoneValidator(value);
          },
          enabled: widget.enabled,
          onSaved: widget.onSaved,
          keyboardType: TextInputType.phone,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/phone_number.dart';
import 'package:crcrme_banque_stages/misc/form_service.dart';

class PhoneListTile extends StatefulWidget {
  const PhoneListTile({
    super.key,
    this.title = 'Téléphone',
    this.initialValue,
    this.icon = Icons.phone,
    required this.onSaved,
    required this.isMandatory,
    required this.enabled,
    this.controller,
  });

  final String title;
  final PhoneNumber? initialValue;
  final IconData icon;
  final Function(String?) onSaved;
  final bool isMandatory;
  final bool enabled;
  final TextEditingController? controller;

  @override
  State<PhoneListTile> createState() => _PhoneListTileState();
}

class _PhoneListTileState extends State<PhoneListTile> {
  late final _phoneController = widget.controller ?? TextEditingController();

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
      child: TextFormField(
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
    );
  }
}

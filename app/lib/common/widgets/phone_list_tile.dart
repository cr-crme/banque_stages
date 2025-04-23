import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/phone_number.dart';
import 'package:crcrme_banque_stages/misc/form_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneListTile extends StatefulWidget {
  const PhoneListTile({
    super.key,
    this.title = 'Téléphone',
    this.titleStyle,
    this.contentStyle,
    this.initialValue,
    this.icon = Icons.phone,
    this.onSaved,
    required this.isMandatory,
    required this.enabled,
    this.canCall = true,
    this.controller,
  });

  final String title;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final PhoneNumber? initialValue;
  final IconData icon;
  final Function(String?)? onSaved;
  final bool isMandatory;
  final bool enabled;
  final TextEditingController? controller;
  final bool canCall;

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

  // coverage:ignore-start
  _call() async => await launchUrl(Uri.parse('tel:${_phoneController.text}'));
  // coverage:ignore-end

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
      child: InkWell(
        onTap: widget.enabled || _phoneController.text == '' ? null : _call,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                icon: const SizedBox(width: 30),
                labelText: '${widget.isMandatory ? '* ' : ''}${widget.title}',
                labelStyle: widget.titleStyle,
                disabledBorder: InputBorder.none,
              ),
              validator: (value) {
                if (!widget.enabled) return null;

                if (!widget.isMandatory && (value == null || value == '')) {
                  return null;
                }
                return FormService.phoneValidator(value);
              },
              style: widget.contentStyle,
              enabled: widget.enabled,
              onSaved: widget.onSaved,
              keyboardType: TextInputType.phone,
            ),
            InkWell(
              onTap: widget.canCall ? _call : null,
              borderRadius: BorderRadius.circular(25),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  widget.icon,
                  color: widget.canCall
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

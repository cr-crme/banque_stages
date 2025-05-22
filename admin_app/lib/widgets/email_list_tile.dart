import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class EmailListTile extends StatefulWidget {
  const EmailListTile({
    super.key,
    this.title = 'Courriel',
    this.titleStyle,
    this.contentStyle,
    this.initialValue,
    this.icon = Icons.mail,
    this.onSaved,
    this.isMandatory = false,
    this.enabled = true,
    this.canMail = true,
    this.controller,
  });

  final String title;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final String? initialValue;
  final IconData icon;
  final Function(String?)? onSaved;
  final bool isMandatory;
  final bool enabled;
  final TextEditingController? controller;
  final bool canMail;

  @override
  State<EmailListTile> createState() => _EmailListTileState();
}

class _EmailListTileState extends State<EmailListTile> {
  late final _emailController = widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _emailController.text = widget.initialValue.toString();
    }
  }

  // coverage:ignore-start
  _email() async =>
      await launchUrl(Uri.parse('mailto:${_emailController.text}'));
  // coverage:ignore-end

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.enabled || _emailController.text == '' ? null : _email,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              icon: const SizedBox(width: 30),
              labelText: '${widget.isMandatory ? '* ' : ''}${widget.title}',
              labelStyle:
                  widget.titleStyle ?? const TextStyle(color: Colors.black),
              disabledBorder: InputBorder.none,
            ),
            style: widget.contentStyle ?? const TextStyle(color: Colors.black),
            validator: (value) {
              if (!widget.enabled) return null;

              if (!widget.isMandatory && (value == '' || value == null)) {
                return null;
              }

              if (value == null || value.isEmpty) {
                return 'Une adresse courriel est obligatoire.';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'L\'adresse courriel n\'est pas valide.';
              }
              return null;
            },
            enabled: widget.enabled,
            onSaved: widget.onSaved,
            keyboardType: TextInputType.emailAddress,
          ),
          InkWell(
            onTap: widget.canMail ? _email : null,
            borderRadius: BorderRadius.circular(25),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                widget.icon,
                color:
                    widget.canMail
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

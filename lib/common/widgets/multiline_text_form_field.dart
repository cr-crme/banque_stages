import 'package:flutter/material.dart';

class MultilineTextFormField extends StatelessWidget {
  const MultilineTextFormField(
      {Key? key, this.initialValue, this.onSaved, this.enabled})
      : super(key: key);

  final String? initialValue;
  final void Function(String?)? onSaved;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
        initialValue: initialValue,
        onSaved: onSaved,
        enabled: enabled,
        keyboardType: TextInputType.multiline,
        minLines: 4,
        maxLines: null,
      ),
    );
  }
}

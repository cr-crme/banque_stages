import 'package:flutter/material.dart';

class CheckboxWithOther<T> extends StatefulWidget {
  const CheckboxWithOther({
    super.key,
    required this.title,
    required this.elements,
    this.errorMessageOther = 'Préciser au moins un élément',
  });

  final String title;
  final List<T> elements;
  final String errorMessageOther;

  @override
  State<CheckboxWithOther<T>> createState() => CheckboxWithOtherState<T>();
}

class CheckboxWithOtherState<T> extends State<CheckboxWithOther<T>> {
  final Map<T, bool> _elementValues = {};
  bool _hasOther = false;
  String? _other;

  List<String> get values {
    final List<String> out = [];
    for (final e in _elementValues.keys) {
      if (_elementValues[e]!) {
        out.add(e.toString());
      }
    }
    if (_hasOther && _other != null) out.add(_other!);
    return out;
  }

  @override
  void initState() {
    super.initState();
    for (final e in widget.elements) {
      _elementValues[e] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        ..._elementValues.keys
            .map((element) => _buildElementTile(element))
            .toList(),
        CheckboxListTile(
          visualDensity: VisualDensity.compact,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            'Autre',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          value: _hasOther,
          onChanged: (newValue) => setState(() => _hasOther = newValue!),
        ),
        Visibility(
          visible: _hasOther,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Préciser\u00a0:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextFormField(
                  onChanged: (text) => _other = text,
                  minLines: 1,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  validator: (value) => _hasOther &&
                          (value == null ||
                              !RegExp('[a-zA-Z0-9]').hasMatch(value))
                      ? widget.errorMessageOther
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  CheckboxListTile _buildElementTile(element) {
    return CheckboxListTile(
      visualDensity: VisualDensity.compact,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        element.toString(),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      value: _elementValues[element],
      onChanged: (newValue) =>
          setState(() => _elementValues[element] = newValue!),
    );
  }
}

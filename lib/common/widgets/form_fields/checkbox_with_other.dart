import 'package:flutter/material.dart';

class CheckboxWithOther<T> extends StatefulWidget {
  const CheckboxWithOther({
    super.key,
    required this.title,
    this.titleStyle,
    required this.elements,
    this.initialValues,
    this.hasNotApplicableOption = false,
    this.showOtherOption = true,
    this.errorMessageOther = 'Préciser au moins un élément',
    this.onOptionWasSelected,
    this.childSubquestion,
  });

  final String title;
  final TextStyle? titleStyle;
  final List<T> elements;
  final List<String>? initialValues;
  final bool showOtherOption;
  final bool hasNotApplicableOption;
  final String errorMessageOther;
  final Function(List<String>)? onOptionWasSelected;
  final Widget? childSubquestion;

  @override
  State<CheckboxWithOther<T>> createState() => CheckboxWithOtherState<T>();
}

class CheckboxWithOtherState<T> extends State<CheckboxWithOther<T>> {
  final Map<T, bool> _elementValues = {};
  bool _isNotApplicable = false;
  bool _hasOther = false;
  String? _other;

  bool get hasSubquestion => _hasSubquestion;
  bool _hasSubquestion = false;

  bool get _showSubquestion =>
      widget.childSubquestion != null && _hasSubquestion;

  ///
  /// This returns all the selected elements except for everything related to
  /// others
  List<T> get selected {
    final List<T> out = [];
    for (final e in _elementValues.keys) {
      if (_elementValues[e]!) {
        out.add(e);
      }
    }
    return out;
  }

  ///
  /// This returns all the element in the form of a list of String
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

  void _checkForShowingChild() {
    _hasSubquestion = _elementValues.values.any((e) => e) || _hasOther;
  }

  @override
  void initState() {
    super.initState();

    // Initialize all elements from the initial value
    for (final e in widget.elements) {
      _elementValues[e] = widget.initialValues?.contains(e.toString()) ?? false;
    }

    // But initial values may contains "other" element which must be parsed too
    if (widget.initialValues != null) {
      final elementsAsString = widget.elements.map((e) => e.toString());
      for (final initial in widget.initialValues!) {
        if (initial.isNotEmpty && !elementsAsString.contains(initial)) {
          _hasOther = true;
          _other = _other == null ? initial : '$_other\n$initial';
        }
      }
    }

    _checkForShowingChild();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: widget.titleStyle ?? Theme.of(context).textTheme.titleSmall,
        ),
        ..._elementValues.keys
            .map(
              (element) => CheckboxListTile(
                visualDensity: VisualDensity.compact,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  element.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                enabled: !_isNotApplicable,
                value: _elementValues[element]!,
                onChanged: (newValue) {
                  _elementValues[element] = newValue!;
                  _checkForShowingChild();
                  setState(() {});
                  if (widget.onOptionWasSelected != null) {
                    widget.onOptionWasSelected!(values);
                  }
                },
              ),
            )
            .toList(),
        if (widget.hasNotApplicableOption)
          CheckboxListTile(
            visualDensity: VisualDensity.compact,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              'Ne s\'applique pas',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            value: _isNotApplicable,
            onChanged: (newValue) {
              _isNotApplicable = newValue!;
              if (_isNotApplicable) {
                for (final e in _elementValues.keys) {
                  _elementValues[e] = false;
                }
                _hasOther = false;
                _checkForShowingChild();
              }
              setState(() {});
              if (widget.onOptionWasSelected != null) {
                widget.onOptionWasSelected!(values);
              }
            },
          ),
        if (widget.showOtherOption)
          CheckboxListTile(
            visualDensity: VisualDensity.compact,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              'Autre',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            value: _hasOther,
            enabled: !_isNotApplicable,
            onChanged: (newValue) {
              _hasOther = newValue!;
              _checkForShowingChild();
              setState(() {});
              if (widget.onOptionWasSelected != null) {
                widget.onOptionWasSelected!(values);
              }
            },
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
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  minLines: 1,
                  maxLines: null,
                  style: Theme.of(context).textTheme.bodyMedium,
                  initialValue: _other,
                  keyboardType: TextInputType.multiline,
                  onChanged: (text) {
                    _other = text;
                    if (widget.onOptionWasSelected != null) {
                      widget.onOptionWasSelected!(values);
                    }
                  },
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
        if (_showSubquestion && widget.showOtherOption)
          const SizedBox(height: 12),
        if (_showSubquestion) widget.childSubquestion!,
      ],
    );
  }
}

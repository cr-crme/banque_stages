import 'package:flutter/material.dart';

class CheckboxWithOther<T> extends StatefulWidget {
  const CheckboxWithOther({
    super.key,
    this.title,
    this.titleStyle,
    required this.elements,
    this.initialValues,
    this.subWidgetBuilder,
    this.hasNotApplicableOption = false,
    this.showOtherOption = true,
    this.errorMessageOther = 'Préciser au moins un élément',
    this.onOptionSelected,
    this.followUpChild,
    this.enabled = true,
  });

  final String? title;
  final TextStyle? titleStyle;
  final List<T> elements;
  final List<String>? initialValues;
  final Widget Function(T element, bool isSelected)? subWidgetBuilder;
  final bool showOtherOption;
  final bool hasNotApplicableOption;
  final String errorMessageOther;
  final Function(List<String>)? onOptionSelected;
  final Widget? followUpChild;
  final bool enabled;

  @override
  State<CheckboxWithOther<T>> createState() => CheckboxWithOtherState<T>();
}

class CheckboxWithOtherState<T> extends State<CheckboxWithOther<T>> {
  final Map<T, bool> _elementValues = {};
  bool _isNotApplicable = false;

  final _otherTextController = TextEditingController();
  bool _hasOther = false;

  bool get hasFollowUp => _hasFollowUp;
  bool _hasFollowUp = false;

  bool get _showFollowUp => widget.followUpChild != null && _hasFollowUp;

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
    if (_isNotApplicable) return ['__NOT_APPLICABLE_INTERNAL__'];

    final List<String> out = [];

    for (final e in _elementValues.keys) {
      if (_elementValues[e]!) {
        out.add(e.toString());
      }
    }
    if (_hasOther && _otherTextController.text.isNotEmpty) {
      out.add(_otherTextController.text);
    }
    return out;
  }

  void _checkForShowingChild() {
    _hasFollowUp = _elementValues.values.any((e) => e) || _hasOther;
  }

  @override
  void initState() {
    super.initState();

    // Initialize all elements from the initial value
    for (final e in widget.elements) {
      _elementValues[e] = widget.initialValues?.contains(e.toString()) ?? false;
    }

    // But initial values may contains "other" element which must be parsed too
    if (widget.hasNotApplicableOption &&
        widget.initialValues != null &&
        widget.initialValues!.length == 1 &&
        widget.initialValues![0] == '__NOT_APPLICABLE_INTERNAL__') {
      _isNotApplicable = true;
      return;
    }

    if (widget.initialValues != null) {
      final elementsAsString = widget.elements.map((e) => e.toString());
      for (final initial in widget.initialValues!) {
        if (initial.isNotEmpty && !elementsAsString.contains(initial)) {
          _hasOther = true;
          _otherTextController.text =
              _otherTextController.text.isEmpty
                  ? initial
                  : '${_otherTextController.text}\n$initial';
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
        if (widget.title != null)
          Text(
            widget.title!,
            style: widget.titleStyle ?? Theme.of(context).textTheme.titleSmall,
          ),
        ..._elementValues.keys.map(
          (element) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                visualDensity: VisualDensity.compact,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  element.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                enabled: widget.enabled && !_isNotApplicable,
                value: _elementValues[element]!,
                onChanged: (newValue) {
                  _elementValues[element] = newValue!;
                  _checkForShowingChild();
                  setState(() {});
                  if (widget.onOptionSelected != null) {
                    widget.onOptionSelected!(values);
                  }
                },
              ),
              if (widget.subWidgetBuilder != null)
                widget.subWidgetBuilder!(element, _elementValues[element]!),
            ],
          ),
        ),
        if (widget.hasNotApplicableOption)
          CheckboxListTile(
            visualDensity: VisualDensity.compact,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              'Ne s\'applique pas',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            enabled: widget.enabled,
            value: _isNotApplicable,
            onChanged: (newValue) {
              _isNotApplicable = newValue!;
              if (_isNotApplicable) {
                for (final e in _elementValues.keys) {
                  _elementValues[e] = false;
                }
                _hasOther = false;
                _otherTextController.text = '';
                _checkForShowingChild();
              }
              setState(() {});
              if (widget.onOptionSelected != null) {
                widget.onOptionSelected!(values);
              }
            },
          ),
        if (widget.showOtherOption)
          CheckboxListTile(
            visualDensity: VisualDensity.compact,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text('Autre', style: Theme.of(context).textTheme.bodyMedium),
            value: _hasOther,
            enabled: widget.enabled && !_isNotApplicable,
            onChanged: (newValue) {
              _hasOther = newValue!;
              _checkForShowingChild();
              setState(() {});
              if (widget.onOptionSelected != null) {
                widget.onOptionSelected!(values);
              }
            },
          ),
        Visibility(
          visible: _hasOther,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Préciser\u00a0:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextFormField(
                  controller: _otherTextController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  minLines: 1,
                  maxLines: null,
                  style: Theme.of(context).textTheme.bodyMedium,
                  keyboardType: TextInputType.multiline,
                  onChanged: (text) {
                    if (widget.onOptionSelected != null) {
                      widget.onOptionSelected!(values);
                    }
                  },
                  enabled: widget.enabled,
                  validator:
                      (value) =>
                          _hasOther &&
                                  (value == null ||
                                      !RegExp('[a-zA-Z0-9]').hasMatch(value))
                              ? widget.errorMessageOther
                              : null,
                ),
              ],
            ),
          ),
        ),
        if (_showFollowUp && widget.showOtherOption) const SizedBox(height: 12),
        if (_showFollowUp) widget.followUpChild!,
      ],
    );
  }
}

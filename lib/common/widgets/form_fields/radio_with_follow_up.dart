import 'package:flutter/material.dart';

class RadioWithFollowUp<T> extends StatefulWidget {
  const RadioWithFollowUp({
    super.key,
    this.title,
    this.initialValue,
    required this.elements,
    this.elementsThatShowChild,
    this.followUpChild,
    this.onChanged,
  });

  final String? title;
  final T? initialValue;
  final List<T> elements;
  final List<T>? elementsThatShowChild;
  final Widget? followUpChild;
  final Function(T? values)? onChanged;

  @override
  State<RadioWithFollowUp<T>> createState() => RadioWithFollowUpState<T>();
}

class RadioWithFollowUpState<T> extends State<RadioWithFollowUp<T>> {
  late T? _current = widget.initialValue;

  bool get hasFollowUp => _hasFollowUp;
  bool _hasFollowUp = false;

  bool get _showFollowUp => widget.followUpChild != null && _hasFollowUp;

  T? get value => _current;

  @override
  void initState() {
    super.initState();
    _checkShowFollowUp();
  }

  void _checkShowFollowUp() {
    _hasFollowUp = widget.elementsThatShowChild?.contains(_current) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Text(
            widget.title!,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ...widget.elements
            .map((element) => _buildElementTile(element))
            .toList(),
        if (_showFollowUp) widget.followUpChild!,
      ],
    );
  }

  RadioListTile<T> _buildElementTile(T element) {
    return RadioListTile<T>(
      groupValue: _current,
      visualDensity: VisualDensity.compact,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        element.toString(),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      value: element,
      onChanged: (newValue) {
        _current = newValue;
        _checkShowFollowUp();
        setState(() {});
        if (widget.onChanged != null) widget.onChanged!(value);
      },
    );
  }
}

import 'package:flutter/material.dart';

class RadioWithChildSubquestion<T> extends StatefulWidget {
  const RadioWithChildSubquestion({
    super.key,
    this.title,
    this.initialValue,
    required this.elements,
    this.elementsThatShowChild,
    this.childSubquestion,
    this.onChanged,
  });

  final String? title;
  final T? initialValue;
  final List<T> elements;
  final List<T>? elementsThatShowChild;
  final Widget? childSubquestion;
  final Function(T? values)? onChanged;

  @override
  State<RadioWithChildSubquestion<T>> createState() =>
      RadioWithChildSubquestionState<T>();
}

class RadioWithChildSubquestionState<T>
    extends State<RadioWithChildSubquestion<T>> {
  late T? _current = widget.initialValue;

  bool get hasSubquestion => _hasSubquestion;
  bool _hasSubquestion = false;

  bool get _showSubquestion =>
      widget.childSubquestion != null && _hasSubquestion;

  T? get value => _current;

  @override
  void initState() {
    super.initState();
    _checkShowSubquestion();
  }

  void _checkShowSubquestion() {
    _hasSubquestion = widget.elementsThatShowChild?.contains(_current) ?? false;
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
        if (_showSubquestion) widget.childSubquestion!,
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
        _checkShowSubquestion();
        setState(() {});
        if (widget.onChanged != null) widget.onChanged!(value);
      },
    );
  }
}

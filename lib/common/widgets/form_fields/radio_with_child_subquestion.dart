import 'package:flutter/material.dart';

class RadioWithChildSubquestion<T> extends StatefulWidget {
  const RadioWithChildSubquestion({
    super.key,
    required this.title,
    required this.elements,
    this.elementsThatShowChild,
    this.childSubquestion,
  });

  final String title;
  final List<T> elements;
  final List<T>? elementsThatShowChild;
  final Widget? childSubquestion;

  @override
  State<RadioWithChildSubquestion<T>> createState() =>
      RadioWithChildSubquestionState<T>();
}

class RadioWithChildSubquestionState<T>
    extends State<RadioWithChildSubquestion<T>> {
  T? _current;

  bool get hasSubquestion => _hasSubquestion;
  bool _hasSubquestion = false;

  bool get _showSubquestion =>
      widget.childSubquestion != null && _hasSubquestion;

  T? get value => _current;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.bodyLarge,
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
        setState(() {
          _current = newValue;
          _hasSubquestion =
              widget.elementsThatShowChild?.contains(element) ?? false;
        });
      },
    );
  }
}

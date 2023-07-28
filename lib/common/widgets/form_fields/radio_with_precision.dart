import 'package:flutter/material.dart';

class RadioWithChild<T> extends StatefulWidget {
  const RadioWithChild({
    super.key,
    required this.title,
    required this.elements,
    required this.elementsThatShowChild,
    required this.child,
  });

  final String title;
  final List<T> elements;
  final List<T> elementsThatShowChild;
  final Widget child;

  @override
  State<RadioWithChild<T>> createState() => RadioWithChildState<T>();
}

class RadioWithChildState<T> extends State<RadioWithChild<T>> {
  T? _current;

  bool get hasOther => _hasOther;
  bool _hasOther = false;

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
        if (_hasOther) widget.child,
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
          _hasOther = widget.elementsThatShowChild.contains(element);
        });
      },
    );
  }
}

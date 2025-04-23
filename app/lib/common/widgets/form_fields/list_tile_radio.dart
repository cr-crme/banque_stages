import 'package:flutter/material.dart';

class ListTileRadio<T> extends StatelessWidget {
  const ListTileRadio({
    required this.titleLabel,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.dense = true,
    super.key,
  });

  final String titleLabel;

  final T value;
  final T groupValue;
  final void Function(T? value) onChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: ListTile(
        dense: dense,
        visualDensity: dense ? VisualDensity.compact : null,
        leading: Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        title: Text(titleLabel),
      ),
    );
  }
}

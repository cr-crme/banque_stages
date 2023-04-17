import 'package:flutter/material.dart';

class ListTileRadio<T> extends StatelessWidget {
  const ListTileRadio({
    required this.titleLabel,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  final String titleLabel;

  final T value;
  final T groupValue;
  final void Function(T? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: ListTile(
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

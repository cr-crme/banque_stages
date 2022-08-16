import 'package:flutter/material.dart';

class DisponibilityCircle extends StatelessWidget {
  const DisponibilityCircle({
    Key? key,
    required this.availableSlots,
    required this.occupiedSlots,
  }) : super(key: key);

  final int availableSlots;
  final int occupiedSlots;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.circle,
      color: availableSlots > occupiedSlots ? Colors.green : Colors.red,
      size: 16,
    );
  }
}

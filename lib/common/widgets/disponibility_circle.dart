import 'package:flutter/material.dart';

class DisponibilityCircle extends StatelessWidget {
  const DisponibilityCircle({
    super.key,
    required this.positionsOffered,
    required this.positionsOccupied,
  });

  final int positionsOffered;
  final int positionsOccupied;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.circle,
      color: positionsOffered > positionsOccupied ? Colors.green : Colors.red,
      size: 16,
    );
  }
}

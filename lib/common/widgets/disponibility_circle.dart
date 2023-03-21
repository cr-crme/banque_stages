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
    int remainning = positionsOffered - positionsOccupied;
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.circle,
          color: remainning > 0 ? Colors.green[900] : Colors.red[900],
          size: 35,
        ),
        Text(
          remainning.toString(),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

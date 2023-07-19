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
    return Tooltip(
      message: 'Nombre de places disponibles dans l\'entreprise',
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black, offset: Offset(2, 2), blurRadius: 4)
                ]),
            child: const Icon(
              Icons.circle,
              color: Colors.white70,
              size: 30,
            ),
          ),
          const Icon(
            Icons.circle,
            color: Colors.white70,
            size: 38,
          ),
          Icon(
            Icons.circle,
            color: remainning > 0 ? Colors.green[800] : Colors.red[800],
            size: 30,
          ),
          Text(
            remainning.toString(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

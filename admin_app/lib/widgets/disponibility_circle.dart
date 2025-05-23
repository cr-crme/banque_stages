import 'package:admin_app/widgets/numbered_tablet.dart';
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
      message: 'Nombre de places disponibles pour ce métier',
      child: NumberedTablet(
        number: remainning,
        color: remainning > 0 ? Colors.green[800] : Colors.red[800],
      ),
    );
  }
}

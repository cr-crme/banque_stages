import 'package:flutter/material.dart';

import '../models/waypoints.dart';
import '../../../common/models/visiting_priority.dart';

class WaypointCard extends StatelessWidget {
  const WaypointCard({
    Key? key,
    required this.name,
    required this.waypoint,
    this.onTap,
    this.onDelete,
    this.canMove = true,
  }) : super(key: key);

  final String name;
  final Waypoint waypoint;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool canMove;

  MaterialColor _getWaypointColor(VisitingPriority priority) {
    switch (priority) {
      case (VisitingPriority.none):
        return Colors.deepPurple;
      case (VisitingPriority.low):
        return Colors.green;
      case (VisitingPriority.mid):
        return Colors.orange;
      case (VisitingPriority.high):
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        key: key,
        contentPadding: const EdgeInsets.all(10),
        onTap: onTap,
        leading: Icon(Icons.flag, color: _getWaypointColor(waypoint.priority)),
        tileColor: canMove ? Colors.white : Colors.grey[300],
        title: Text(
          name,
          style: const TextStyle(color: Colors.black),
        ),
        subtitle: Text(waypoint.toString(),
            style: const TextStyle(color: Colors.blueGrey)),
        trailing: IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: onDelete),
      ),
    );
  }
}

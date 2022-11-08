import 'package:flutter/material.dart';

import '../models/waypoints.dart';

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

  @override
  Widget build(BuildContext context) {
    final color = waypoint.priority == Priority.low
        ? Colors.green
        : waypoint.priority == Priority.mid
            ? Colors.orange
            : waypoint.priority == Priority.high
                ? Colors.red
                : Colors.deepPurple;
    return Card(
      child: ListTile(
        key: key,
        contentPadding: const EdgeInsets.all(10),
        onTap: onTap,
        leading: Icon(Icons.flag, color: color),
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

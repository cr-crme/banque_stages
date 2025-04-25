import 'package:crcrme_banque_stages/common/models/visiting_priorities_extension.dart';
import 'package:crcrme_banque_stages/common/models/waypoints.dart';
import 'package:flutter/material.dart';

class WaypointCard extends StatelessWidget {
  const WaypointCard({
    super.key,
    required this.name,
    required this.waypoint,
    this.onTap,
    this.onDelete,
    this.canMove = true,
  });

  final String name;
  final Waypoint waypoint;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool canMove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        key: key,
        contentPadding: const EdgeInsets.all(10),
        onTap: onTap,
        leading: Icon(waypoint.priority.icon, color: waypoint.priority.color),
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

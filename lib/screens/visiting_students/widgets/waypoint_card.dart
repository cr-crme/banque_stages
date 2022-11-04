import 'package:flutter/material.dart';

import '../models/waypoints.dart';

class WaypointCard extends StatelessWidget {
  const WaypointCard({
    Key? key,
    required this.name,
    required this.waypoint,
    this.onTap,
    this.canMove = true,
  }) : super(key: key);

  final String name;
  final Waypoint waypoint;
  final VoidCallback? onTap;
  final bool canMove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        key: key,
        contentPadding: const EdgeInsets.all(10),
        onTap: onTap,
        leading: const CircleAvatar(backgroundColor: Colors.amber),
        tileColor: canMove ? Colors.white : Colors.grey[300],
        title: Text(
          name,
          style: TextStyle(
              color: waypoint.isActivated ? Colors.black : Colors.grey),
        ),
        subtitle: Text(waypoint.toString(),
            style: TextStyle(
                color: waypoint.isActivated ? Colors.blueGrey : Colors.grey)),
      ),
    );
  }
}

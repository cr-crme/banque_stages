import 'package:flutter/material.dart';

import '/common/models/activity_type.dart';

class ActivityTypeCards extends StatelessWidget {
  const ActivityTypeCards({
    Key? key,
    required this.activityTypes,
    this.onDeleted,
  }) : super(key: key);

  final Set<ActivityType> activityTypes;
  final void Function(ActivityType)? onDeleted;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      children: activityTypes
          .map(
            (activityType) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Chip(
                  visualDensity: VisualDensity.compact,
                  deleteIcon: const Icon(Icons.delete),
                  deleteIconColor: Theme.of(context).colorScheme.onPrimary,
                  label: Text(activityType.toString()),
                  onDeleted: onDeleted != null
                      ? () => onDeleted!(activityType)
                      : null),
            ),
          )
          .toList(),
    );
  }
}

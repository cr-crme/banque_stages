import 'package:flutter/material.dart';

class ActivityTypeCards extends StatelessWidget {
  const ActivityTypeCards({
    super.key,
    required this.activityTypes,
    this.onDeleted,
  });

  final Set<String> activityTypes;
  final void Function(String activityType)? onDeleted;

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

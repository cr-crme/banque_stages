import 'package:admin_app/widgets/disponibility_circle.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:flutter/material.dart';

extension JobExtension on Job {
  // TODO Update this
  int positionsOccupied(context) => 2;
  // InternshipsProvider.of(context, listen: false)
  //     .where((e) => e.jobId == id && e.isActive)
  //     .length;

  // TODO Update this
  int positionsRemaining(context) => 3;
  // positionsOffered - positionsOccupied(context);
}

class AvailablePlaceListTile extends StatelessWidget {
  const AvailablePlaceListTile({
    super.key,
    required this.initial,
    required this.editMode,
    required this.onChanged,
  });

  final Map<Job, int> initial;
  final bool editMode;
  final Function(Job job, int newValue) onChanged;

  @override
  Widget build(BuildContext context) {
    final jobs = initial.keys.toList();
    jobs.sort(
      (a, b) => a.specialization.name.toLowerCase().compareTo(
        b.specialization.name.toLowerCase(),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Places de stage disponibles'),
        Column(
          children:
              jobs.isEmpty
                  ? [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12.0,
                        top: 8.0,
                        bottom: 4.0,
                      ),
                      child: Text('Aucun stage proposé pour le moment.'),
                    ),
                  ]
                  : jobs.map((job) {
                    final positionsRemaining = job.positionsRemaining(context);
                    final int positionsOffered = initial[job]!;

                    return ListTile(
                      visualDensity: VisualDensity.compact,
                      leading: DisponibilityCircle(
                        positionsOffered: positionsOffered,
                        positionsOccupied: job.positionsOccupied(context),
                      ),
                      title: Text(job.specialization.idWithName),
                      trailing:
                          editMode
                              ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed:
                                        positionsOffered == 0
                                            ? null
                                            : () => onChanged(
                                              job,
                                              positionsOffered - 1,
                                            ),
                                    icon: Icon(
                                      Icons.remove,
                                      color:
                                          positionsRemaining == 0
                                              ? Colors.grey
                                              : Colors.black,
                                    ),
                                  ),
                                  Text(positionsOffered.toString()),
                                  IconButton(
                                    onPressed:
                                        () => onChanged(
                                          job,
                                          positionsOffered + 1,
                                        ),
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              )
                              : Text(
                                '${job.positionsRemaining(context)} / $positionsOffered',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                    );
                  }).toList(),
        ),
      ],
    );
  }
}

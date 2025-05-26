import 'package:admin_app/providers/internships_provider.dart';
import 'package:admin_app/widgets/disponibility_circle.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:flutter/material.dart';

class AvailablePlacesListController {
  final _key = GlobalKey<_AvailablePlaceListTileState>();
  AvailablePlacesListController();

  int positionsOffered(String jobId) {
    return _key.currentState?._positionsOffered[jobId] ?? 0;
  }
}

class AvailablePlaceListTile extends StatefulWidget {
  AvailablePlaceListTile({
    required this.controller,
    required this.jobList,
    required this.editMode,
  }) : super(key: controller._key);

  final AvailablePlacesListController controller;
  final JobList jobList;
  final bool editMode;

  @override
  State<AvailablePlaceListTile> createState() => _AvailablePlaceListTileState();
}

class _AvailablePlaceListTileState extends State<AvailablePlaceListTile> {
  final Map<String, int> _positionsOffered = {};
  final Map<String, int> _positionsOccupied = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final internships = InternshipsProvider.of(context, listen: true);
    for (final job in widget.jobList) {
      _positionsOffered[job.id] = job.positionsOffered;
      _positionsOccupied[job.id] = internships.fold(
        0,
        (sum, e) => e.jobId == job.id && e.isActive ? sum + 1 : sum,
      );
    }
  }

  void _updatePositions(String jobId, int newCount) {
    setState(() {
      _positionsOffered[jobId] = newCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Places de stage disponibles'),
        Column(
          children:
              widget.jobList.isEmpty
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
                  : widget.jobList.map((job) {
                    final positionOccupied = _positionsOccupied[job.id] ?? 0;
                    final positionsOffered = _positionsOffered[job.id] ?? 0;
                    final positionsRemaining =
                        positionsOffered - positionOccupied;

                    return ListTile(
                      visualDensity: VisualDensity.compact,
                      leading: DisponibilityCircle(
                        positionsOffered: positionsOffered,
                        positionsOccupied: positionOccupied,
                      ),
                      title: Text(job.specialization.idWithName),
                      trailing:
                          widget.editMode
                              ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed:
                                        positionsOffered == 0
                                            ? null
                                            : () => _updatePositions(
                                              job.id,
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
                                        () => _updatePositions(
                                          job.id,
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
                                '$positionsRemaining / $positionsOffered',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                    );
                  }).toList(),
        ),
      ],
    );
  }
}

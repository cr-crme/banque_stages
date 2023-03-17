import 'package:flutter/material.dart';

import '/common/models/visiting_priority.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/students_provider.dart';

class SupervisionStudentDetailsScreen extends StatelessWidget {
  const SupervisionStudentDetailsScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    final student = StudentsProvider.of(context).fromId(studentId);
    final internships = InternshipsProvider.of(context).byStudentId(studentId);

    final enterpriseName = internships.isNotEmpty
        ? EnterprisesProvider.of(context, listen: false)
            .fromId(internships.last.enterpriseId)
            .name
        : 'Aucun stage';

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          student.avatar,
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student.fullName),
              Text(
                enterpriseName,
                style: const TextStyle(fontSize: 14),
              )
            ],
          ),
        ]),
      ),
      body: _VisitingPriority(studentId: studentId),
    );
  }
}

class _VisitingPriority extends StatefulWidget {
  const _VisitingPriority({required this.studentId});

  final String studentId;

  @override
  State<_VisitingPriority> createState() => _VisitingPriorityState();
}

class _VisitingPriorityState extends State<_VisitingPriority> {
  final _visibilityFilters = [
    VisitingPriority.low,
    VisitingPriority.mid,
    VisitingPriority.high
  ];

  void _updatePriority(VisitingPriority newPriority) {
    final interships = InternshipsProvider.of(context, listen: false);
    final studentInternships = interships.byStudentId(widget.studentId);
    if (studentInternships.isEmpty) return;
    interships.replacePriority(widget.studentId, newPriority);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final internship = InternshipsProvider.of(context, listen: false)
        .byStudentId(widget.studentId)
        .last;
    final flags = _visibilityFilters.map<Widget>((priority) {
      return InkWell(
        onTap: () => _updatePriority(priority),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
                value: priority == internship.visitingPriority,
                onChanged: (value) => _updatePriority(priority)),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Icon(priority.icon, color: priority.color),
            )
          ],
        ),
      );
    }).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: flags,
    );
  }
}

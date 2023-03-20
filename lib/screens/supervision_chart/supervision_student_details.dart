import 'package:flutter/material.dart';

import '../../misc/job_data_file_service.dart';
import '/common/models/internship.dart';
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
    final internship = internships.isNotEmpty ? internships.last : null;

    final enterprise = internship != null
        ? EnterprisesProvider.of(context, listen: false)
            .fromId(internship.enterpriseId)
        : null;

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
                enterprise?.name ?? 'Aucun stage',
                style: const TextStyle(fontSize: 14),
              )
            ],
          ),
        ]),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VisitingPriority(studentId: studentId),
            _Specialization(internship: internship),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _PersonalNotes(internship: internship),
            ),
          ],
        ),
      ),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Niveau de priorité pour les visites',
            style: Theme.of(context).textTheme.headline6,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: flags,
          ),
        ],
      ),
    );
  }
}

class _Specialization extends StatelessWidget {
  const _Specialization({required this.internship});

  final Internship? internship;

  @override
  Widget build(BuildContext context) {
    final specialization = internship != null
        ? JobDataFileService.specializationById(internship!.jobId)!
        : null;

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Niveau de priorité pour les visites',
              style: Theme.of(context).textTheme.headline6,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 8.0),
              child: Text(specialization?.idWithName ?? 'Aucun stage'),
            ),
          ],
        ));
  }
}

class _PersonalNotes extends StatefulWidget {
  const _PersonalNotes({required this.internship});

  final Internship? internship;

  @override
  State<_PersonalNotes> createState() => _PersonalNotesState();
}

class _PersonalNotesState extends State<_PersonalNotes> {
  late final _focusNode = FocusNode()..addListener(_sendComments);
  late final _textController = TextEditingController()
    ..text = widget.internship!.teacherNotes;

  void _sendComments() {
    final interships = InternshipsProvider.of(context, listen: false);
    interships.replace(
        widget.internship!.copyWith(teacherNotes: _textController.text));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Particularités du stage à connaitre',
              style: Theme.of(context).textTheme.headline6,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text(
                  '(ex. entrer par la porte 5 réservée au personnel, ...)'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 4 / 5,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 4,
                    maxLines: null,
                    focusNode: _focusNode,
                    controller: _textController,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

import 'package:flutter/material.dart';

import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/models/schedule.dart';
import '/common/models/visiting_priority.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/students_provider.dart';
import '../../misc/job_data_file_service.dart';

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
            _PersonalNotes(internship: internship),
            _Contact(enterprise: enterprise, internship: internship),
            _Schedule(internship: internship),
            _EnterpriseRequirements(enterprise: enterprise),
            _MoreInfoButton(studentId: studentId),
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
              'Métier',
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
        padding: const EdgeInsets.only(top: 16, left: 8.0, right: 8.0),
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

class _Contact extends StatelessWidget {
  const _Contact({required this.enterprise, required this.internship});

  final Enterprise? enterprise;
  final Internship? internship;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact',
              style: Theme.of(context).textTheme.headline6,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.home,
                    color: Colors.black,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        'Adresse complète :\n${enterprise?.address ?? 'Aucun stage'}'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.phone,
                    color: Colors.black,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('Superviseur du stage :\n'
                        '${internship?.supervisor.phone ?? 'Aucun téléphone enregistré'}'),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

class _Schedule extends StatelessWidget {
  const _Schedule({required this.internship});

  final Internship? internship;

  Widget _scheduleBuilder(BuildContext context, List<Schedule> schedule) {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Table(
        columnWidths: {
          0: FixedColumnWidth(MediaQuery.of(context).size.width / 5),
          1: FixedColumnWidth(MediaQuery.of(context).size.width / 6),
          2: FixedColumnWidth(MediaQuery.of(context).size.width / 6),
        },
        children: schedule
            .map<TableRow>((e) => TableRow(
                  children: [
                    Text(e.dayOfWeek.name),
                    Text(
                        textAlign: TextAlign.end,
                        '${e.start.hour}h${e.start.minute.toString().padLeft(2, '0')}'),
                    Text(
                        textAlign: TextAlign.end,
                        '${e.end.hour}h${e.end.minute.toString().padLeft(2, '0')}'),
                  ],
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Horaire de stage',
              style: Theme.of(context).textTheme.headline6,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 8.0),
              child: internship != null
                  ? _scheduleBuilder(context, internship!.schedule)
                  : const Text('Aucun stage'),
            ),
          ],
        ));
  }
}

class _EnterpriseRequirements extends StatelessWidget {
  const _EnterpriseRequirements({required this.enterprise});

  final Enterprise? enterprise;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exigences de l\'entreprise',
              style: Theme.of(context).textTheme.headline6,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25.0, top: 8.0),
              child: Text('EPI requis :',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25.0),
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod',
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25.0, top: 8.0),
              child: Text('Uniforme requis :',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 25.0),
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod',
              ),
            ),
          ],
        ));
  }
}

class _MoreInfoButton extends StatelessWidget {
  const _MoreInfoButton({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0, bottom: 40),
      child: Center(
        child: ElevatedButton(
            onPressed: () {},
            child: const Text('Plus de détails sur le stage')),
      ),
    );
  }
}

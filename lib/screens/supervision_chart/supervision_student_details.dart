import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/models/protections.dart';
import '/common/models/schedule.dart';
import '/common/models/student.dart';
import '/common/models/visiting_priority.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/students_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/common/widgets/sub_title.dart';
import '/router.dart';
import '/screens/supervision_chart/widgets/transfer_dialog.dart';

class SupervisionStudentDetailsScreen extends StatelessWidget {
  const SupervisionStudentDetailsScreen({super.key, required this.studentId});

  final String studentId;

  void _transferStudent(BuildContext context) async {
    final internships = InternshipsProvider.of(context, listen: false);
    final teachers =
        TeachersProvider.of(context, listen: false).map((e) => e).toList();
    teachers.sort(
        (a, b) => a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase()));
    final student = StudentsProvider.of(context, listen: false)[studentId];

    final answer = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) =>
          TransferDialog(students: [student], teachers: teachers),
    );

    if (answer == null) return;
    internships.transferStudent(studentId: answer[0], newTeacherId: answer[1]);
  }

  @override
  Widget build(BuildContext context) {
    late Student student;
    try {
      student = StudentsProvider.of(context).fromId(studentId);
    } catch (e) {
      return Container();
    }
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
        actions: [
          IconButton(
              onPressed: () => _transferStudent(context),
              icon: const Icon(Icons.transfer_within_a_station)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (internship == null)
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child:
                    Center(child: Text('Aucun stage pour cet\u00b7te élève')),
              ),
            if (internship != null) _VisitingPriority(studentId: studentId),
            if (internship != null) _Specialization(internship: internship),
            if (internship != null) _PersonalNotes(internship: internship),
            if (internship != null)
              _Contact(enterprise: enterprise!, internship: internship),
            if (internship != null) _Schedule(internship: internship),
            if (internship != null) _Requirements(internship: internship),
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
    VisitingPriority.high,
    VisitingPriority.mid,
    VisitingPriority.low
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
    final internships = InternshipsProvider.of(context, listen: false)
        .byStudentId(widget.studentId);
    if (internships.isEmpty) return Container();
    final internship = internships.last;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Niveau de priorité pour les visites'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: flags,
        ),
      ],
    );
  }
}

class _Specialization extends StatelessWidget {
  const _Specialization({required this.internship});

  final Internship? internship;

  @override
  Widget build(BuildContext context) {
    final specialization = internship == null
        ? null
        : EnterprisesProvider.of(context, listen: false)
            .fromId(internship!.enterpriseId)
            .jobs
            .fromId(internship!.jobId)
            .specialization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Métier'),
        Padding(
          padding: const EdgeInsets.only(left: 25.0, top: 8.0),
          child: Text(specialization?.idWithName ?? 'Aucun stage'),
        ),
      ],
    );
  }
}

class _PersonalNotes extends StatefulWidget {
  const _PersonalNotes({required this.internship});

  final Internship internship;

  @override
  State<_PersonalNotes> createState() => _PersonalNotesState();
}

class _PersonalNotesState extends State<_PersonalNotes> {
  late final _focusNode = FocusNode()..addListener(_sendComments);
  late final _textController = TextEditingController()
    ..text = widget.internship.teacherNotes;

  void _sendComments() {
    final interships = InternshipsProvider.of(context, listen: false);
    interships.replace(
        widget.internship.copyWith(teacherNotes: _textController.text));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Particularités du stage à connaitre'),
        const Padding(
          padding: EdgeInsets.only(left: 32.0, bottom: 8),
          child: Text('(ex. entrer par la porte 5 réservée au personnel, ...)'),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 5 / 6,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
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
      ],
    );
  }
}

class _Contact extends StatelessWidget {
  const _Contact({required this.enterprise, required this.internship});

  final Enterprise enterprise;
  final Internship internship;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Contact'),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 8.0),
          child: Row(
            children: [
              const Icon(
                Icons.home,
                color: Colors.black,
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(enterprise.address == null
                      ? 'Aucune adresse'
                      : '${enterprise.address!.civicNumber} ${enterprise.address!.street}\n'
                          '${enterprise.address!.city}\n'
                          '${enterprise.address!.postalCode}'),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 8.0),
          child: Row(
            children: [
              const Icon(
                Icons.phone,
                color: Colors.black,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('${internship.supervisor.fullName}\n'
                    '${internship.supervisor.phone.toString() == '' ? 'Aucun téléphone enregistré' : internship.supervisor.phone}'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Schedule extends StatelessWidget {
  const _Schedule({required this.internship});

  final Internship? internship;

  Widget _scheduleBuilder(
      BuildContext context, List<WeeklySchedule> schedules) {
    return Column(
        children: schedules.asMap().keys.map((index) {
      final weeklySchedule = schedules[index];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (schedules.length > 1)
            Text(
              'Période ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          Padding(
            padding: EdgeInsets.only(
                bottom: index != schedules.length - 1 ? 8 : 0, right: 40),
            child: Table(
              columnWidths: {
                0: FixedColumnWidth(MediaQuery.of(context).size.width / 3),
                1: FixedColumnWidth(MediaQuery.of(context).size.width / 6),
                2: FixedColumnWidth(MediaQuery.of(context).size.width / 6),
              },
              children: weeklySchedule.schedule
                  .map<TableRow>((e) => TableRow(
                        children: [
                          Text(e.dayOfWeek.name),
                          Text(
                              textAlign: TextAlign.end,
                              e.start.format(context)),
                          Text(textAlign: TextAlign.end, e.end.format(context)),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ],
      );
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Horaire de stage'),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: internship != null
              ? _scheduleBuilder(context, internship!.weeklySchedules)
              : const Text('Aucun stage'),
        ),
      ],
    );
  }
}

class _Requirements extends StatelessWidget {
  const _Requirements({required this.internship});

  final Internship internship;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Exigences de l\'entreprise'),
        const Padding(
          padding: EdgeInsets.only(left: 32.0),
          child: Text('EPI requis :',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: internship.protections.status == ProtectionsStatus.none
                ? const Text('Aucun')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: internship.protections.protections
                        .map((e) => Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('\u2022 '),
                                Flexible(child: Text(e)),
                              ],
                            ))
                        .toList(),
                  )),
        const Padding(
          padding: EdgeInsets.only(left: 32.0, top: 8.0),
          child: Text('Uniforme requis :',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: internship.uniform.isEmpty
              ? const Text('Aucun')
              : Text(internship.uniform),
        ),
      ],
    );
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
            onPressed: () => GoRouter.of(context).pushNamed(
                  Screens.student,
                  params: Screens.params(studentId),
                  queryParams: Screens.queryParams(pageIndex: "1"),
                ),
            child: const Text('Plus de détails sur le stage')),
      ),
    );
  }
}

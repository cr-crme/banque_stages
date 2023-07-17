import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/protections.dart';
import 'package:crcrme_banque_stages/common/models/schedule.dart';
import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/models/uniform.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/phone_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_banque_stages/screens/supervision_chart/widgets/transfer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _navigateToStudentIntership(BuildContext context) {
    GoRouter.of(context).pushNamed(
      Screens.student,
      params: Screens.params(studentId),
      queryParams: Screens.queryParams(pageIndex: '1'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final internships = InternshipsProvider.of(context).byStudentId(studentId);
    final internship = internships.isNotEmpty && internships.last.isActive
        ? internships.last
        : null;

    final enterprise = internship != null
        ? EnterprisesProvider.of(context, listen: false)
            .fromId(internship.enterpriseId)
        : null;

    return FutureBuilder<Student?>(
        future: StudentsProvider.fromLimitedId(context, studentId: studentId),
        builder: (context, snapshot) {
          final student = snapshot.hasData ? snapshot.data : null;

          return Scaffold(
            appBar: AppBar(
              title: student == null
                  ? const Text('En attente des données')
                  : Row(children: [
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
              child: student == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (internship == null)
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: Center(
                                child: Text('Aucun stage pour l\'élève')),
                          ),
                        if (internship != null)
                          _VisitingPriority(
                            studentId: studentId,
                            onTapGoToInternship: () =>
                                _navigateToStudentIntership(context),
                          ),
                        if (internship != null)
                          _StudentInformation(student: student),
                        if (internship != null)
                          _Specialization(internship: internship),
                        if (internship != null)
                          _PersonalNotes(internship: internship),
                        if (internship != null)
                          _Contact(
                              enterprise: enterprise!, internship: internship),
                        if (internship != null)
                          _Schedule(internship: internship),
                        if (internship != null)
                          _Requirements(internship: internship),
                        _MoreInfoButton(
                          studentId: studentId,
                          onTap: () => _navigateToStudentIntership(context),
                        ),
                      ],
                    ),
            ),
          );
        });
  }
}

class _VisitingPriority extends StatefulWidget {
  const _VisitingPriority({
    required this.studentId,
    required this.onTapGoToInternship,
  });

  final String studentId;
  final Function() onTapGoToInternship;

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
    final isOver = internship.date.end.compareTo(DateTime.now()) < 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Niveau de priorité pour les visites'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _visibilityFilters.map<Widget>((priority) {
            return InkWell(
              onTap: isOver ? null : () => _updatePriority(priority),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: isOver
                        ? false
                        : priority == internship.visitingPriority,
                    onChanged:
                        isOver ? null : (value) => _updatePriority(priority),
                    fillColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Theme.of(context).primaryColor.withOpacity(.32);
                      }
                      return Theme.of(context).primaryColor;
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: Icon(priority.icon, color: priority.color),
                  )
                ],
              ),
            );
          }).toList(),
        ),
        if (isOver)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.priority_high,
                      color: Theme.of(context).primaryColor,
                      size: 35,
                    ),
                    Text(
                      'La date de fin du stage est dépasseée.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                    onPressed: widget.onTapGoToInternship,
                    child: Text(
                      'Aller au stage',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white),
                    ))
              ],
            ),
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

class _StudentInformation extends StatelessWidget {
  const _StudentInformation({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Contact de l\'élève'),
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: PhoneListTile(
            initialValue: student.phone,
            enabled: false,
            isMandatory: false,
          ),
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
        const SubTitle('Contact en entreprise'),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adresse de l\'entreprise',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(enterprise.address == null
                          ? 'Aucune adresse'
                          : '${enterprise.address!.civicNumber} ${enterprise.address!.street}\n'
                              '${enterprise.address!.city}\n'
                              '${enterprise.address!.postalCode}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 8.0),
          child: Row(
            children: [
              InkWell(
                onTap: () =>
                    launchUrl(Uri.parse('tel:${internship.supervisor.phone}')),
                child: Icon(
                  Icons.phone,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  children: [
                    const Text(
                      'Responsable en milieu de stage',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                        'Responsable en milieu de stage\n${internship.supervisor.fullName}\n'
                        '${internship.supervisor.phone.toString() == '' ? 'Aucun téléphone enregistré' : internship.supervisor.phone}'),
                  ],
                ),
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
          child: Text('Équipements de protection individuelle requis :',
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
          child: Text('Tenue de travail :',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: internship.uniform.status == UniformStatus.none
              ? const Text('Aucune consigne de l\'entreprise')
              : Text(internship.uniform.uniform),
        ),
      ],
    );
  }
}

class _MoreInfoButton extends StatelessWidget {
  const _MoreInfoButton({required this.studentId, required this.onTap});

  final String studentId;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0, bottom: 40),
      child: Center(
        child: ElevatedButton(
            onPressed: onTap,
            child: const Text('Plus de détails\nsur le stage',
                textAlign: TextAlign.center)),
      ),
    );
  }
}

import 'package:collection/collection.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/models/protections.dart';
import 'package:crcrme_banque_stages/common/models/schedule.dart';
import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/models/uniform.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SupervisionStudentDetailsScreen extends StatelessWidget {
  const SupervisionStudentDetailsScreen({super.key, required this.studentId});

  final String studentId;

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
    final job = enterprise?.jobs[internship?.jobId];

    final student = StudentsProvider.studentsInMyGroups(context)
        .firstWhereOrNull((e) => e.id == studentId);

    return Scaffold(
      appBar: AppBar(
        title: student == null
            ? const Text('En attente des données')
            : Row(children: [
                student.avatar,
                const SizedBox(width: 12),
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
        child: student == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (internship == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Center(child: Text('Aucun stage pour l\'élève')),
                    ),
                  if (internship != null)
                    _VisitingPriority(
                      studentId: studentId,
                      onTapGoToInternship: () =>
                          _navigateToStudentIntership(context),
                    ),
                  if (internship != null)
                    _Contact(
                        student: student,
                        enterprise: enterprise!,
                        internship: internship),
                  if (internship != null)
                    _PersonalNotes(internship: internship),
                  if (internship != null) _Schedule(internship: internship),
                  if (internship != null) _buildUniformAndEpi(context, job!),
                  _MoreInfoButton(
                    studentId: studentId,
                    onTap: () => _navigateToStudentIntership(context),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildUniformAndEpi(BuildContext context, Job job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Exigences de l\'entreprise'),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUniform(context, job),
              const SizedBox(height: 24),
              _buildProtections(context, job),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUniform(BuildContext context, Job job) {
    // Workaround for job.uniforms
    final uniforms = job.uniform;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tenue de travail',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        uniforms.status == UniformStatus.none
            ? const Text('Aucune consigne de l\'entreprise')
            : ItemizedText(uniforms.uniforms),
      ],
    );
  }
}

Widget _buildProtections(BuildContext context, Job job) {
  final protections = job.protections;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Équipements de protection individuelle',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      protections.status == ProtectionsStatus.none
          ? const Text('Aucun équipement requis')
          : ItemizedText(protections.protections)
    ],
  );
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
              onTap: () => _updatePriority(priority),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: priority == internship.visitingPriority,
                    onChanged: (value) => _updatePriority(priority),
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
                      'La date de fin du stage est dépassée.',
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
  const _Contact(
      {required this.student,
      required this.enterprise,
      required this.internship});

  final Student student;
  final Enterprise enterprise;
  final Internship internship;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Contacts'),
        Padding(
          padding: const EdgeInsets.only(left: 32.0, top: 8.0),
          child: Row(
            children: [
              InkWell(
                onTap: () => launchUrl(Uri.parse('tel:${student.phone}')),
                child: Icon(
                  Icons.phone,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Élève',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${student.fullName}\n'
                        '${student.phone.toString() == '' ? 'Aucun téléphone enregistré' : student.phone}'),
                  ],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Responsable en milieu de stage',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${internship.supervisor.fullName}\n'
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

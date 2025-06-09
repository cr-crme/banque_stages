import 'package:collection/collection.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/internships/schedule.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common/models/persons/student.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/extensions/students_extension.dart';
import 'package:crcrme_banque_stages/common/extensions/time_of_day_extension.dart';
import 'package:crcrme_banque_stages/common/extensions/visiting_priorities_extension.dart';
import 'package:crcrme_banque_stages/common/provider_helpers/students_helpers.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SupervisionStudentDetailsScreen extends StatelessWidget {
  const SupervisionStudentDetailsScreen({super.key, required this.studentId});

  final String studentId;

  void _navigateToStudentInternship(BuildContext context) {
    GoRouter.of(context).pushNamed(
      Screens.student,
      pathParameters: Screens.params(studentId),
      queryParameters: Screens.queryParams(pageIndex: '1'),
    );
  }

  Future<Internship?> _getInternship(BuildContext context) async {
    while (true) {
      if (!context.mounted) return null;
      final internships = InternshipsProvider.of(context, listen: false);
      final internship = internships.byStudentId(studentId).lastOrNull;
      if (internship != null) return internship.isActive ? internship : null;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<Enterprise?> _getEnterprise(BuildContext context) async {
    final internship = await _getInternship(context);
    if (internship == null) return null;

    while (true) {
      if (!context.mounted) return null;
      final enterprises = EnterprisesProvider.of(context, listen: false);
      final enterprise = enterprises.fromIdOrNull(internship.enterpriseId);
      if (enterprise != null) return enterprise;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<Job?> _getJob(BuildContext context) async {
    final internship = await _getInternship(context);
    if (internship == null || !context.mounted) return null;
    final enterprise = await _getEnterprise(context);
    if (enterprise == null || !context.mounted) return null;

    return enterprise.jobs[internship.jobId];
  }

  Future<Student?> _getStudent(BuildContext context) async {
    while (true) {
      if (!context.mounted) return null;
      final students = StudentsHelpers.studentsInMyGroups(context);
      final student = students.firstWhereOrNull((e) => e.id == studentId);
      if (student != null) return student;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List>(
            future: Future.wait([
              _getInternship(context),
              _getEnterprise(context),
              _getJob(context),
              _getStudent(context),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null) {
                return Text('En attente des données');
              }

              final enterprise = snapshot.data?[1] as Enterprise?;
              final student = snapshot.data?[3] as Student?;
              if (student == null) return const Text('Aucun élève trouvé');

              return Row(children: [
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
              ]);
            }),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List>(
            future: Future.wait([
              _getInternship(context),
              _getEnterprise(context),
              _getJob(context),
              _getStudent(context),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final internship = snapshot.data?[0] as Internship?;
              final enterprise = snapshot.data?[1] as Enterprise?;
              final job = snapshot.data?[2] as Job?;
              final student = snapshot.data?[3] as Student?;
              if (student == null) {
                return const Center(child: Text('Aucun élève trouvé'));
              }

              return Column(
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
                          _navigateToStudentInternship(context),
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
                    onTap: () => _navigateToStudentInternship(context),
                  ),
                ],
              );
            }),
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
    final uniforms = job.uniforms;

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
    final internships = InternshipsProvider.of(context, listen: false);
    final studentInternships = internships.byStudentId(widget.studentId);
    if (studentInternships.isEmpty) return;
    internships.replacePriority(widget.studentId, newPriority);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final internships =
        InternshipsProvider.of(context).byStudentId(widget.studentId);
    if (internships.isEmpty) return Container();

    final internship = internships.last;
    final isOver = internship.dates.end.compareTo(DateTime.now()) < 1;

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
    // TODO: This automatically sends the comment which causes a race condition focus out by changing priority
    final internships = InternshipsProvider.of(context, listen: false);
    if (_textController.text == widget.internship.teacherNotes) return;
    internships.updateTeacherNote(
        widget.internship.studentId, _textController.text);
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

import 'package:collection/collection.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/internships/schedule.dart';
import 'package:common/models/persons/student.dart';
import 'package:common_flutter/helpers/responsive_service.dart';
import 'package:common_flutter/helpers/time_of_day_extension.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/extensions/students_extension.dart';
import 'package:crcrme_banque_stages/common/provider_helpers/students_helpers.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

final _logger = Logger('SupervisionStudentDetailsScreen');

class SupervisionStudentDetailsScreen extends StatelessWidget {
  const SupervisionStudentDetailsScreen({super.key, required this.studentId});

  static const route = '/student-details';
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
    _logger.finer(
        'Building SupervisionStudentDetailsScreen for student: $studentId');

    return ResponsiveService.scaffoldOf(
      context,
      appBar: ResponsiveService.appBarOf(
        context,
        title: FutureBuilder<List>(
            future: Future.wait([
              _getInternship(context),
              _getEnterprise(context),
              _getJob(context),
              _getStudent(context),
            ]),
            builder: (context, snapshot) {
              _logger.finer(
                  'Building app bar for SupervisionStudentDetailsScreen with: '
                  'hasInternship: ${snapshot.data?[0] != null}, '
                  'hasEnterprise: ${snapshot.data?[1] != null}, '
                  'hasJob: ${snapshot.data?[2] != null}, '
                  'hasStudent: ${snapshot.data?[3] != null}');

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
      smallDrawer: null,
      mediumDrawer: MainDrawer.medium,
      largeDrawer: MainDrawer.large,
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
                    _IsOver(
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

class _IsOver extends StatelessWidget {
  const _IsOver({
    required this.studentId,
    required this.onTapGoToInternship,
  });

  final String studentId;
  final Function() onTapGoToInternship;

  @override
  Widget build(BuildContext context) {
    final internships = InternshipsProvider.of(context).byStudentId(studentId);
    if (internships.isEmpty) return Container();

    final internship = internships.last;
    final isOver = internship.dates.end.compareTo(DateTime.now()) < 1;

    return isOver
        ? Center(
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
                    onPressed: onTapGoToInternship,
                    child: Text(
                      'Aller au stage',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white),
                    ))
              ],
            ),
          )
        : SizedBox.shrink();
  }
}

class _PersonalNotes extends StatefulWidget {
  const _PersonalNotes({required this.internship});

  final Internship internship;

  @override
  State<_PersonalNotes> createState() => _PersonalNotesState();
}

class _PersonalNotesState extends State<_PersonalNotes> {
  late final _textController = TextEditingController()
    ..text = widget.internship.teacherNotes;

  void _sendComments() {
    final internships = InternshipsProvider.of(context, listen: false);
    if (_textController.text == widget.internship.teacherNotes) return;
    internships.updateTeacherNote(
        widget.internship.studentId, _textController.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Particularités du stage à connaitre'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 32.0, bottom: 8),
              child: Text(
                  '(ex. entrer par la porte 5 réservée au personnel, ...)'),
            ),
            IconButton(
                onPressed: () => setState(() {
                      _editMode = !_editMode;
                      if (!_editMode) _sendComments();
                    }),
                icon: Icon(
                  _editMode ? Icons.save : Icons.edit,
                  color: Theme.of(context).primaryColor,
                ))
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 5 / 6,
            decoration: _editMode
                ? BoxDecoration(border: Border.all(color: Colors.grey))
                : null,
            child: _editMode
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 4,
                    maxLines: null,
                    controller: _textController,
                  )
                : Text(
                    _textController.text.isEmpty
                        ? 'Aucun commentaire'
                        : _textController.text,
                    style: const TextStyle(fontStyle: FontStyle.italic)),
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
              children: weeklySchedule.schedule.entries.map((pair) {
                final day = pair.key;
                final entry = pair.value;
                return TableRow(
                  children: [
                    Text(day.name),
                    Text(
                        textAlign: TextAlign.end,
                        entry?.blocks.first.start.format(context) ??
                            'Aucune heure'),
                    Text(
                        textAlign: TextAlign.end,
                        entry?.blocks.first.end.format(context) ??
                            'Aucune heure'),
                  ],
                );
              }).toList(),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/common/models/internship.dart';
import '/common/models/person.dart';
import '/common/models/schedule.dart';
import '/common/models/student.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/common/widgets/sub_title.dart';

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({
    super.key,
    required this.student,
  });

  final Student student;

  @override
  State<InternshipsPage> createState() => InternshipsPageState();
}

class InternshipsPageState extends State<InternshipsPage> {
  final Map<String, bool> _expanded = {};

  void _prepareExpander(List<Internship> internships) {
    if (_expanded.length != internships.length) {
      for (final internship in internships) {
        _expanded[internship.id] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allInternships = InternshipsProvider.of(context);
    final internships = allInternships.byStudentId(widget.student.id);
    _prepareExpander(internships);

    return ListView.builder(
      itemCount: internships.length,
      itemBuilder: (context, index) {
        final internship = internships[index];
        return ExpansionPanelList(
          expansionCallback: (int panelIndex, bool isExpanded) =>
              setState(() => _expanded[internship.id] = !isExpanded),
          children: [
            ExpansionPanel(
              canTapOnHeader: true,
              isExpanded: _expanded[internship.id]!,
              headerBuilder: (context, isExpanded) => ListTile(
                title: SubTitle(
                  'Année ${internship.date.start.year}-${internship.date.end.year}',
                  top: 0,
                  left: 0,
                  bottom: 0,
                ),
              ),
              body: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text('Détails du stage',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(color: Colors.black)),
                        ),
                        _InternshipBody(internship: internship),
                      ]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InternshipBody extends StatelessWidget {
  const _InternshipBody({required this.internship});

  final Internship internship;
  static const TextStyle _titleStyle = TextStyle(fontWeight: FontWeight.bold);
  static const _interline = 12.0;
  static const _leftTab = 12.0;

  Widget _buildTextSection({required String title, required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _titleStyle),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: _interline),
          child: Text(text),
        )
      ],
    );
  }

  Widget _buildJob(
    String title, {
    required String specializationId,
    required enterprises,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _titleStyle),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(enterprises[internship.enterpriseId]
                .jobs[internship.jobId]
                .specialization
                .idWithName),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(enterprises[internship.enterpriseId]
                .jobs[internship.jobId]
                .specialization
                .sector
                .idWithName),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonInfo({required Person person}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Adresse de l\'entreprise', style: _titleStyle),
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: _interline),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nom'),
              Text(person.fullName),
              const SizedBox(height: 8),
              const Text('Numéro de téléphone'),
              Text(person.phone.toString()),
              const SizedBox(height: 8),
              const Text('Courriel'),
              Text(person.email ?? 'Aucun'),
              const SizedBox(height: 8),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date du stage', style: _titleStyle),
        Padding(
          padding: const EdgeInsets.only(bottom: _interline),
          child: Table(
            children: [
              const TableRow(children: [
                Text('Date de début :'),
                Text('Date de fin :'),
              ]),
              TableRow(children: [
                Text(DateFormat.yMMMEd().format(internship.date.start)),
                Text(DateFormat.yMMMEd().format(internship.date.end)),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nombre d\'heures de stage', style: _titleStyle),
        Padding(
          padding: const EdgeInsets.only(bottom: _interline),
          child: Table(
            children: [
              TableRow(children: [
                Text('Total prévu : ${internship.length}h'),
                const Text(
                    'Total fait : XXXh'), // TODO when internship finalization is done
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSchedule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nombre d\'heures de stage', style: _titleStyle),
        Padding(
          padding: const EdgeInsets.only(bottom: _interline),
          child: Table(
            children: internship.weeklySchedules[0].schedule.map(
              // TODO Manage when there is more schedules
              (schedule) {
                return TableRow(
                  children: [
                    Text(schedule.dayOfWeek.name),
                    Text(schedule.start.format(context)),
                    Text(schedule.end.format(context)),
                  ],
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProtection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EPI requis', style: _titleStyle),
          if (internship.protections.isEmpty) Text('Aucune'),
          if (internship.protections.isNotEmpty)
            ...internship.protections.map((e) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('\u2022 '),
                    Flexible(child: Text(e)),
                  ],
                )),
        ],
      ),
    );
  }

  Widget _buildUniform() {
    return Padding(
      padding: const EdgeInsets.only(bottom: _interline),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Uniforme requis', style: _titleStyle),
          Text(internship.uniform == '' ? 'Aucun' : internship.uniform),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teachers = TeachersProvider.of(context);
    final enterprises = EnterprisesProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextSection(
            title: 'Enseignant.e superviseur.e de stage',
            text: teachers[internship.teacherId].fullName),
        _buildJob(
            'Métier${internship.extraSpecializationId.isNotEmpty ? ' principal' : ''}',
            specializationId: internship.jobId,
            enterprises: enterprises),
        if (internship.extraSpecializationId.isNotEmpty)
          ...internship.extraSpecializationId.asMap().keys.map(
                (indexExtra) => _buildJob(
                    'Métier secondaire${internship.extraSpecializationId.length > 1 ? ' (${indexExtra + 1})' : ''}',
                    specializationId:
                        internship.extraSpecializationId[indexExtra],
                    enterprises: enterprises),
              ),
        _buildTextSection(
            title: 'Entreprise',
            text: enterprises[internship.enterpriseId].name),
        _buildTextSection(
            title: 'Adresse de l\'entreprise',
            text: enterprises[internship.enterpriseId].address.toString()),
        _buildPersonInfo(person: internship.supervisor),
        _buildDates(),
        _buildTime(),
        _buildSchedule(context),
        _buildProtection(),
        _buildUniform(),
      ],
    );
  }
}

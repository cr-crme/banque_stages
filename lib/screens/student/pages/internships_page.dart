import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/common/models/internship.dart';
import '/common/models/person.dart';
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

  Widget _buildTextSection({required String title, required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.only(top: 2, left: 12.0, bottom: 12.0),
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
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 12.0),
            child: Text(enterprises[internship.enterpriseId]
                .jobs[internship.jobId]
                .specialization
                .idWithName),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 12.0),
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

  Widget _buildPersonInfo({required String title, required Person person}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Padding(
          padding: const EdgeInsets.only(top: 2, left: 12.0, bottom: 12.0),
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
              if (person.email != null) Text(person.email!),
              const SizedBox(height: 8),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDates(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date du stage',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Padding(
          padding: EdgeInsets.only(
              left: 12.0,
              right: MediaQuery.of(context).size.width / 4,
              bottom: 12.0),
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

  Widget _buildTime(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nombre d\'heures de stage',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Padding(
          padding: EdgeInsets.only(
              left: 12.0,
              right: MediaQuery.of(context).size.width / 4,
              bottom: 12.0),
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
        _buildJob('Métier principal',
            specializationId: internship.jobId, enterprises: enterprises),
        if (internship.extraSpecializationId.isNotEmpty)
          ...internship.extraSpecializationId.map(
            (id) => _buildJob('Métier secondaire',
                specializationId: internship.extraSpecializationId[0],
                enterprises: enterprises),
          ),
        _buildTextSection(
            title: 'Entreprise',
            text: enterprises[internship.enterpriseId].name),
        _buildTextSection(
            title: 'Adresse de l\'entreprise',
            text: enterprises[internship.enterpriseId].address.toString()),
        _buildPersonInfo(
            title: 'Adresse de l\'entreprise', person: internship.supervisor),
        _buildDates(context),
        _buildTime(context),
      ],
    );
  }
}

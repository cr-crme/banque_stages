import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/models/protections.dart';
import 'package:crcrme_banque_stages/common/models/uniform.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:flutter/material.dart';

class PrerequisitesExpansionPanel extends ExpansionPanel {
  PrerequisitesExpansionPanel({
    required super.isExpanded,
    required Enterprise enterprise,
    required Job job,
  }) : super(
          canTapOnHeader: true,
          body: _PrerequisitesBody(
            job: job,
            enterprise: enterprise,
          ),
          headerBuilder: (context, isExpanded) => const ListTile(
            title: Text('Prérequis pour le recrutement'),
          ),
        );
}

List<Widget> _printCountedList<T>(
    Iterable iterable, String Function(T) toString) {
  return iterable
      .toSet()
      .map<Widget>((e) => Text(
          '\u2022 ${toString(e)} (${iterable.fold<int>(0, (prev, e2) => prev + (e == e2 ? 1 : 0))})'))
      .toList();
}

class _PrerequisitesBody extends StatelessWidget {
  const _PrerequisitesBody({required this.job, required this.enterprise});

  final Job job;
  final Enterprise enterprise;

  @override
  Widget build(BuildContext context) {
    final hasData = job.postInternshipEvaluations.isNotEmpty;

    // TODO Benjamin - This is a workaround because uniforms are currently
    // stored in intership. I think this should be moved to the job creation
    final allInternships = InternshipsProvider.of(context);
    final internships =
        allInternships.where((e) => enterprise.jobs.hasId(e.jobId));

    // Workaround for "job.uniforms"
    final uniforms = internships.map<Uniform>((e) => e.uniform).toSet();
    final uniformsByEnterprise = uniforms
        .where((e) => e.status == UniformStatus.suppliedByEnterprise)
        .toSet();
    final uniformsByStudent = uniforms
        .where((e) => e.status == UniformStatus.suppliedByStudent)
        .toSet();

    // Workaround for "job.requirements"
    final protections = internships.map<Protections>((e) => e.protections);
    final protectionsByEnterprise = protections
        .where((e) => e.status == ProtectionsStatus.suppliedByEnterprise);
    final protectionsBySchool = protections
        .where((e) => e.status == ProtectionsStatus.suppliedBySchool);
    final requirementsByEnterprise =
        protectionsByEnterprise.expand((e) => e.protections);
    final requirementsBySchool =
        protectionsBySchool.expand((e) => e.protections);

    return hasData
        ? SizedBox(
            width: Size.infinite.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Âge minimum',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${job.minimalAge} ans'),
                  const SizedBox(height: 12),
                  const Text(
                    'Tenue de travail',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (uniformsByEnterprise.isEmpty && uniformsByStudent.isEmpty)
                    const Text('Aucune consigne de l\'entreprise'),
                  if (uniformsByEnterprise.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fournies par l\'entreprise :'),
                        ..._printCountedList<Uniform>(
                            uniformsByEnterprise, (e) => e.uniform),
                      ],
                    ),
                  if (uniformsByStudent.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (uniformsByEnterprise.isNotEmpty)
                          const SizedBox(height: 8),
                        const Text('Fournies par l\'étudiant :'),
                        ..._printCountedList<Uniform>(
                            uniformsByStudent, (e) => e.uniform),
                      ],
                    ),
                  const SizedBox(height: 12),
                  const Text(
                    'Équipement de protection individuelle :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (requirementsByEnterprise.isEmpty &&
                      requirementsBySchool.isEmpty)
                    const Text('Il n\'y a aucun prérequis pour ce métier'),
                  if (requirementsByEnterprise.isNotEmpty)
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fournies par l\'entreprise :'),
                          ..._printCountedList<String>(
                              requirementsByEnterprise, (e) => e),
                        ]),
                  if (requirementsBySchool.isNotEmpty)
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (requirementsBySchool.isNotEmpty)
                            const SizedBox(height: 8),
                          const Text('Fournies par l\'école :'),
                          ..._printCountedList<String>(
                              requirementsBySchool, (e) => e),
                        ]),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          )
        : const Center(
            child: Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text('Aucune donnée pour l\'instant'),
          ));
  }
}

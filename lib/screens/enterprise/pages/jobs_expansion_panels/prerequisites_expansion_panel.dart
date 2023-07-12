import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
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
    final evaluations = job.postInternshipEnterpriseEvaluations(context);

    // TODO Benjamin - We have to make a workaround because uniforms and job
    // requirements are currently stored in intership.
    // I think this should be moved to the job creation.
    final internships = InternshipsProvider.of(context)
        .where((internship) => job.id == internship.jobId);

    return evaluations.isEmpty
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
                  Text(
                      '${evaluations.fold(0, (prev, e) => e.minimumAge) ~/ 1} ans'),
                  const SizedBox(height: 12),
                  ..._buildUniform(internships),
                  const SizedBox(height: 12),
                  ..._buildProtections(internships),
                  const SizedBox(height: 12),
                  ..._buildEntepriseRequests(internships),
                  const SizedBox(height: 12),
                  ..._buildSkillsRequired(internships),
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

  List<Widget> _buildUniform(Iterable<Internship> internships) {
    // Workaround for "job.uniforms"
    final allUniforms = internships.map<Uniform>((e) => e.uniform).toSet();
    final uniforms = {
      UniformStatus.suppliedByEnterprise: allUniforms
          .where((e) => e.status == UniformStatus.suppliedByEnterprise)
          .map((e) => e.uniform),
      UniformStatus.suppliedByStudent: allUniforms
          .where((e) => e.status == UniformStatus.suppliedByStudent)
          .map((e) => e.uniform),
    };

    return [
      const Text(
        'Tenue de travail',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      if (uniforms[UniformStatus.suppliedByEnterprise]!.isEmpty &&
          uniforms[UniformStatus.suppliedByStudent]!.isEmpty)
        const Text('Aucune consigne de l\'entreprise'),
      if (uniforms[UniformStatus.suppliedByEnterprise]!.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fournie par l\'entreprise :'),
            ..._printCountedList<String>(
                uniforms[UniformStatus.suppliedByEnterprise]!, (e) => e),
          ],
        ),
      if (uniforms[UniformStatus.suppliedByStudent]!.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (uniforms[UniformStatus.suppliedByEnterprise]!.isNotEmpty)
              const SizedBox(height: 8),
            const Text('Fournie par l\'étudiant :'),
            ..._printCountedList<String>(
                uniforms[UniformStatus.suppliedByStudent]!, (e) => e),
          ],
        ),
    ];
  }

  List<Widget> _buildSkillsRequired(Iterable<Internship> internships) {
    final skills = internships
        .expand((e) => e.enterpriseEvaluation?.skillsRequired ?? [])
        .where((e) => e != null);

    return [
      const Text(
        'Habiletés exigées pour le stage',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      if (skills.isEmpty) const Text('Aucune'),
      if (skills.isNotEmpty) ..._printCountedList<String>(skills, (e) => e),
    ];
  }

  List<Widget> _buildEntepriseRequests(Iterable<Internship> internships) {
    final requests = internships
        .expand((e) => e.enterpriseEvaluation?.enterpriseRequests ?? [])
        .where((e) => e != null);

    return [
      const Text(
        'L\'entreprise a demandé',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      if (requests.isEmpty) const Text('Aucune exigence particulière'),
      if (requests.isNotEmpty) ..._printCountedList<String>(requests, (e) => e),
    ];
  }

  List<Widget> _buildProtections(Iterable<Internship> internships) {
    final allProtections = internships.map<Protections>((e) => e.protections);
    final protections = {
      ProtectionsStatus.suppliedByEnterprise: allProtections
          .where((e) => e.status == ProtectionsStatus.suppliedByEnterprise)
          .map((e) => e.protections)
          .expand((e) => e),
      ProtectionsStatus.suppliedBySchool: allProtections
          .where((e) => e.status == ProtectionsStatus.suppliedBySchool)
          .map((e) => e.protections)
          .expand((e) => e),
    };

    return [
      const Text(
        'Équipement de protection individuelle :',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      if (protections[ProtectionsStatus.suppliedByEnterprise]!.isEmpty &&
          protections[ProtectionsStatus.suppliedBySchool]!.isEmpty)
        const Text('Il n\'y a aucun prérequis pour ce métier'),
      if (protections[ProtectionsStatus.suppliedByEnterprise]!.isNotEmpty)
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Fournis par l\'entreprise :'),
          ..._printCountedList<String>(
              protections[ProtectionsStatus.suppliedByEnterprise]!, (e) => e),
        ]),
      if (protections[ProtectionsStatus.suppliedBySchool]!.isNotEmpty)
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (protections[ProtectionsStatus.suppliedByEnterprise]!.isNotEmpty)
            const SizedBox(height: 8),
          const Text('Fournis par l\'école :'),
          ..._printCountedList<String>(
              protections[ProtectionsStatus.suppliedBySchool]!, (e) => e),
        ]),
    ];
  }
}

import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/models/protections.dart';
import 'package:crcrme_banque_stages/common/models/uniform.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
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
            title: Text('Prérequis et équipements'),
          ),
        );
}

class _PrerequisitesBody extends StatelessWidget {
  const _PrerequisitesBody({required this.job, required this.enterprise});

  final Job job;
  final Enterprise enterprise;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Size.infinite.width,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMinimumAge(),
            const SizedBox(height: 12),
            ..._buildEntepriseRequests(),
            const SizedBox(height: 12),
            ..._buildUniform(),
            const SizedBox(height: 12),
            ..._buildProtections(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimumAge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Âge minimum',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text('${job.minimumAge} ans'),
      ],
    );
  }

  List<Widget> _buildUniform() {
    // Workaround for job.uniforms
    final uniforms = job.uniform;

    return [
      const Text(
        'Tenue de travail',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      if (uniforms.status == UniformStatus.none)
        const Text('Aucune consigne de l\'entreprise'),
      if (uniforms.status == UniformStatus.suppliedByEnterprise)
        const Text('Fournie par l\'entreprise\u00a0:'),
      if (uniforms.status == UniformStatus.suppliedByStudent)
        const Text('Fournie par l\'étudiant\u00a0:'),
      ItemizedText(uniforms.uniforms),
    ];
  }

  List<Widget> _buildEntepriseRequests() {
    final requests = job.preInternshipRequest.requests;
    return [
      const Text(
        'Exigences de l\'entreprise',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      if (requests.isEmpty) const Text('Aucune exigence particulière'),
      if (requests.isNotEmpty) ItemizedText(requests),
    ];
  }

  List<Widget> _buildProtections() {
    final protections = job.protections;

    return [
      const Text(
        'Équipements de protection individuelle',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      if (protections.status == ProtectionsStatus.none)
        const Text('Aucun équipement requis'),
      if (protections.status == ProtectionsStatus.suppliedByEnterprise)
        const Text('Fournis par l\'entreprise\u00a0:'),
      if (protections.status == ProtectionsStatus.suppliedBySchool)
        const Text('Fournis par l\'école\u00a0:'),
      ItemizedText(protections.protections),
    ];
  }
}

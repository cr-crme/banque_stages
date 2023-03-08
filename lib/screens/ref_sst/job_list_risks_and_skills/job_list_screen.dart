import '/misc/job_data_file_service.dart';
import 'package:flutter/material.dart';
import 'widgets/tile_job_risk.dart';
import 'widgets/tile_job_skill.dart';

class JobListScreen extends StatelessWidget {
  final String id;
  const JobListScreen({super.key, required this.id});

  List<Specialization> filledList(BuildContext context) {
    List<Specialization> out = [];
    for (final sector in JobDataFileService.sectors) {
      for (final specialization in sector.specializations) {
        // If there is no risk, it does not mean this specialization
        // is risk-free, it means it was not evaluated
        var hasRisks = false;
        for (final skill in specialization.skills) {
          if (hasRisks) break;
          hasRisks = skill.risks.isNotEmpty;
        }
        if (hasRisks) out.add(specialization);
      }
    }
    return out;
  }

  List<String> _extractAllRisks(Specialization job) {
    final out = <String>[];
    for (final skill in job.skills) {
      for (final risk in skill.risks) {
        if (!out.contains(risk)) out.add(risk);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final job =
        JobDataFileService.specializations.firstWhere((e) => e.id == id);
    final riskIds = _extractAllRisks(job);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: Text(job.name),
            bottom: TabBar(tabs: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Risques', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    Icon(Icons.warning),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Compétences', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    Icon(Icons.school),
                  ],
                ),
              ),
            ]),
          ),
          body: TabBarView(children: [
            ListView.separated(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemCount: riskIds.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, i) => TileJobRisk(riskIds: riskIds),
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  color: Colors.grey,
                  height: 16,
                );
              },
            ),
            ListView.separated(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemCount: job.skills.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, i) => const TileJobSkill(),
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  color: Colors.grey,
                  height: 16,
                );
              },
            )
          ])),
    );
  }
}

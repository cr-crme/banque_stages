import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:crcrme_banque_stages/misc/risk_data_file_service.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/risk.dart';
import 'widgets/tile_job_risk.dart';

class SpecializationListScreen extends StatelessWidget {
  final String id;
  const SpecializationListScreen({super.key, required this.id});

  List<Specialization> filledList(BuildContext context) {
    List<Specialization> out = [];
    for (final sector in ActivitySectorsService.sectors) {
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

  List<Risk> _extractAllRisks(Specialization specialization) {
    final out = <String>[];
    for (final skill in specialization.skills) {
      for (final risk in skill.risks) {
        if (!out.contains(risk)) out.add(risk);
      }
    }
    return out.map<Risk>((e) => RiskDataFileService.fromAbbrv(e)!).toList();
  }

  List<Risk> _risksSkillHas(Skill skill, List<Risk> allRisks) {
    final out = <Risk>[];
    for (final risk in skill.risks) {
      final skillRisk = RiskDataFileService.fromAbbrv(risk);
      if (out.contains(skillRisk) || skillRisk == null) continue;
      out.add(skillRisk);
    }
    return out;
  }

  List<Skill> _skillsThatHasThisRisk(Risk risk, List<Skill> skills) {
    final out = <Skill>[];
    for (final skill in skills) {
      if (skill.risks.toList().indexWhere((e) => e == risk.abbrv) < 0) {
        continue;
      }
      out.add(skill);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final specialization = ActivitySectorsService.specialization(id);

    final risks = _extractAllRisks(specialization);
    final skillsAssociatedToRisks = <Risk, List<Skill>>{};
    for (final risk in risks) {
      skillsAssociatedToRisks[risk] =
          _skillsThatHasThisRisk(risk, specialization.skills.toList());
    }
    risks.sort((a, b) =>
        skillsAssociatedToRisks[b]!.length -
        skillsAssociatedToRisks[a]!.length);

    final skills = specialization.skills.map((e) => e).toList();
    final risksAssociatedToSkill = <Skill, List<Risk>>{};
    for (final skill in skills) {
      risksAssociatedToSkill[skill] = _risksSkillHas(skill, risks).toList();
    }
    skills.sort((a, b) =>
        risksAssociatedToSkill[b]!.length - risksAssociatedToSkill[a]!.length);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5),
              child: AutoSizeText(specialization.idWithName, maxLines: 2),
            ),
            bottom: const TabBar(tabs: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Affichage par\ncompétence',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.build_circle_sharp),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Affichage par\nrisque',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.warning),
                  ],
                ),
              ),
            ]),
          ),
          body: TabBarView(children: [
            ListView.separated(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              itemCount: specialization.skills.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, i) => TileJobRisk(
                title: skills[i].name,
                elements: risksAssociatedToSkill[skills[i]]!,
                nbMaximumElements: 1000, // Show all in orange
                tooltipMessage:
                    'Nombre de compétences possiblement concernées par ce risque',
              ),
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
              itemCount: risks.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, i) => TileJobRisk(
                title: risks[i].name,
                elements: skillsAssociatedToRisks[risks[i]]!,
                nbMaximumElements: 1000, // Show all in orange
                tooltipMessage:
                    'Nombre de risques potentiellement présents pour cette compétence',
              ),
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

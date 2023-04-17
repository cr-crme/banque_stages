import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '/common/models/internship.dart';

class InternshipSkills extends StatefulWidget {
  const InternshipSkills({super.key, required this.internship});

  final Internship internship;

  @override
  State<InternshipSkills> createState() => _InternshipSkillsState();
}

class _InternshipSkillsState extends State<InternshipSkills> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: ExpansionPanelList(
        elevation: 0,
        expansionCallback: (index, isExpanded) =>
            setState(() => _isExpanded = !_isExpanded),
        children: [
          ExpansionPanel(
            isExpanded: _isExpanded,
            canTapOnHeader: true,
            headerBuilder: (context, isExpanded) => Text('Compétences',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.black)),
            body: Stack(
              alignment: Alignment.topRight,
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: _SpecificSkillBody(internship: widget.internship)),
                IconButton(
                    onPressed: () => GoRouter.of(context).pushNamed(
                        Screens.studentEvaluationMainScreen,
                        params: {'internshipId': widget.internship.id}),
                    icon: const Icon(
                      Icons.add_chart_rounded,
                      color: Colors.black,
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SpecificSkillBody extends StatelessWidget {
  const _SpecificSkillBody({
    required this.internship,
  });

  final Internship internship;

  Widget _buildLastEvaluation() {
    return Text('Dernière évaluation : '
        '${DateFormat('dd MMMM yyyy', 'fr_CA').format(internship.studentEvaluation.last.date)}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('C1. Compétences spécifiques du métier',
            style: TextStyle(fontWeight: FontWeight.bold)),
        if (internship.studentEvaluation.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text('Aucune évaluation disponible pour ce stage'),
          ),
        if (internship.studentEvaluation.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLastEvaluation(),
            ],
          )
      ],
    );
  }
}

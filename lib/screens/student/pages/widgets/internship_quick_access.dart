import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/finalize_internship_dialog.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/student_steps/attitude_evaluation_form_controller.dart';

class InternshipQuickAccess extends StatelessWidget {
  const InternshipQuickAccess({super.key, required this.internshipId});

  final String internshipId;

  @override
  Widget build(BuildContext context) {
    final enterprises = EnterprisesProvider.of(context);
    final internship = InternshipsProvider.of(context)[internshipId];
    final enterprise = enterprises[internship.enterpriseId];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnterprise(context, enterprise: enterprise),
          _buildQuickAccessButton(context, internship: internship),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(context, {required Internship internship}) {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Actions à réaliser',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 3),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(18))),
                        child: IconButton(
                          onPressed: () => GoRouter.of(context).pushNamed(
                            Screens.skillEvaluationMainScreen,
                            params: Screens.params(internshipId),
                            queryParams: Screens.queryParams(editMode: '1'),
                          ),
                          icon: const Icon(Icons.add_chart_rounded),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Évaluer C1',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 3),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(18))),
                        child: IconButton(
                          onPressed: () => GoRouter.of(context).pushNamed(
                              Screens.attitudeEvaluationScreen,
                              queryParams: Screens.queryParams(editMode: '1'),
                              extra: AttitudeEvaluationFormController(
                                  internshipId: internshipId)),
                          icon: const Icon(Icons.playlist_add_sharp),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Évaluer C2',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              if (internship.isActive)
                TextButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => FinalizeInternshipDialog(
                            internshipId: internshipId)),
                    child: const Text('Terminer le stage')),
              if (internship.isEnterpriseEvaluationPending)
                TextButton(
                    onPressed: () => _evaluateEnterprise(context, internship),
                    child: const Text('Évaluer l\'entreprise')),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEnterprise(context, {required Enterprise enterprise}) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 12),
      child: GestureDetector(
        onTap: () => GoRouter.of(context).pushNamed(
          Screens.enterprise,
          params: Screens.params(enterprise),
          queryParams: Screens.queryParams(pageIndex: '3'),
        ),
        child: Text(
          enterprise.name,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              decoration: TextDecoration.underline,
              color: Colors.blue),
        ),
      ),
    );
  }

  void _evaluateEnterprise(context, Internship internship) async {
    GoRouter.of(context).pushNamed(
      Screens.enterpriseEvaluationScreen,
      params: Screens.params(internship.enterpriseId, jobId: internship.jobId),
    );
  }
}

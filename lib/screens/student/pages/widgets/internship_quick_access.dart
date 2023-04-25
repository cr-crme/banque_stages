import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/widgets/dialogs/finalize_internship_dialog.dart';
import '/router.dart';
import '/screens/internship_forms/student_steps/attitude_evaluation_form_controller.dart';

class InternshipQuickAccess extends StatelessWidget {
  const InternshipQuickAccess({super.key, required this.internshipId});

  final String internshipId;

  @override
  Widget build(BuildContext context) {
    final enterprises = EnterprisesProvider.of(context);
    final internship = InternshipsProvider.of(context)[internshipId];
    final enterprise = enterprises[internship.enterpriseId];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEnterprise(context, enterprise: enterprise),
        _buildQuickAccessButton(context, internship: internship),
      ],
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
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          onPressed: () => GoRouter.of(context).pushNamed(
                            Screens.skillEvaluationMainScreen,
                            params: Screens.params(internshipId),
                            queryParams: Screens.queryParams(editMode: '1'),
                          ),
                          icon: const Icon(Icons.add_chart_rounded),
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Évaluer C1',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          onPressed: () => GoRouter.of(context).pushNamed(
                              Screens.attitudeEvaluationScreen,
                              queryParams: Screens.queryParams(editMode: '1'),
                              extra: AttitudeEvaluationFormController(
                                  internshipId: internshipId)),
                          icon: const Icon(Icons.add_chart_rounded),
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Évaluer C2',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
                    child: const Text('Terminer le stage'))
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
              decoration: TextDecoration.underline,
              color: Colors.blue),
        ),
      ),
    );
  }
}

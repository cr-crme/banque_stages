import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/finalize_internship_dialog.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/enterprise_steps/enterprise_evaluation_screen.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/student_steps/attitude_evaluation_form_controller.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/student_steps/attitude_evaluation_screen.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/student_steps/skill_evaluation_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InternshipQuickAccess extends StatelessWidget {
  const InternshipQuickAccess({super.key, required this.internshipId});

  final String internshipId;

  @override
  Widget build(BuildContext context) {
    try {
      final internship = InternshipsProvider.of(context)[internshipId];
      final enterprise =
          EnterprisesProvider.of(context)[internship.enterpriseId];
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
    } catch (e) {
      return SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
  }

  Widget _buildQuickAccessButton(context, {required Internship internship}) {
    final myId = TeachersProvider.of(context, listen: false).myTeacher?.id;
    final isSupervising = internship.supervisingTeacherIds.contains(myId);

    return isSupervising &&
            (internship.isActive || internship.isEnterpriseEvaluationPending)
        ? Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24),
            child: Row(
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
                            onPressed: () => showSkillEvaluationDialog(
                                context: context,
                                internshipId: internshipId,
                                editMode: true),
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
                            onPressed: () => showAttitudeEvaluationDialog(
                                context: context,
                                formController:
                                    AttitudeEvaluationFormController(
                                        internshipId: internshipId),
                                editMode: true),
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
            ),
          )
        : Container();
  }

  Widget _buildEnterprise(context, {required Enterprise enterprise}) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 12, right: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                enterprise.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: InkWell(
                  onTap: () => GoRouter.of(context).pushNamed(
                    Screens.enterprise,
                    pathParameters: Screens.params(enterprise),
                    queryParameters: Screens.queryParams(pageIndex: '3'),
                  ),
                  borderRadius: BorderRadius.circular(25),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.open_in_new,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _evaluateEnterprise(context, Internship internship) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            Dialog(child: EnterpriseEvaluationScreen(id: internship.id)));
  }
}

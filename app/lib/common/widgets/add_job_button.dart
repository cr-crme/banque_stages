import 'package:common/models/enterprises/enterprise_status.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common_flutter/widgets/enterprise_job_list_tile.dart';
import 'package:flutter/material.dart';

class AddJobButton extends StatelessWidget {
  const AddJobButton({
    super.key,
    required this.controllers,
    this.onJobAdded,
    this.style,
  });

  final List<EnterpriseJobListController> controllers;
  final ButtonStyle? style;
  final Function()? onJobAdded;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
        key: key,
        onPressed: () {
          controllers.add(EnterpriseJobListController(
              enterpriseStatus: EnterpriseStatus.active, job: Job.empty));
          if (onJobAdded != null) {
            onJobAdded!();
          }
        },
        style: style,
        icon: const Icon(Icons.business_center_rounded),
        label: Text(controllers.isEmpty
            ? 'Ajouter un métier'
            : 'Ajouter un autre métier'));
  }
}

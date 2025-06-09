import 'package:common/models/enterprises/job.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common_flutter/widgets/enterprise_job_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/job_form_field_list_tile.dart';
import 'package:flutter/material.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => JobsPageState();
}

// TODO: Finalize passage to EnterpriseJobListTile (no job is currently okay)
class JobsPageState extends State<JobsPage> {
  final _formKey = GlobalKey<FormState>();
  final _jobsControllers = <EnterpriseJobListController>[];
  final JobList jobs = JobList();

  bool validate() {
    jobs.clear();
    _formKey.currentState!.save();

    if (_jobsControllers.isEmpty) return false;

    return _formKey.currentState!.validate();
  }

  void addJobToForm() {
    _jobsControllers.add(EnterpriseJobListController(job: Job.empty));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Form(
        key: _formKey,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _jobsControllers.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) =>
              _buildNewJobsForm(index),
        ),
      ),
    );
  }

  Widget _buildNewJobsForm(int index) {
    final controller = _jobsControllers[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: Key('${controller.hashCode}_formKey'),
      children: [
        Row(
          children: [
            Text(
              'Métier ${index + 1}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              onPressed: () =>
                  setState(() => _jobsControllers.remove(controller)),
              padding: const EdgeInsets.all(8.0),
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Supprimer',
              color: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
        EnterpriseJobListTile(
            controller: controller,
            editMode: true,
            onRequestDelete: () =>
                setState(() => _jobsControllers.remove(controller))),
        const SizedBox(height: 20),
      ],
    );
  }
}

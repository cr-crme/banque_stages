import 'package:common/models/enterprises/job.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common_flutter/widgets/enterprise_job_list_tile.dart';
import 'package:flutter/material.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => JobsPageState();
}

class JobsPageState extends State<JobsPage> {
  final _formKey = GlobalKey<FormState>();
  final _jobsControllers = <EnterpriseJobListController>[];

  bool validate() {
    _formKey.currentState!.save();

    if (_jobsControllers.isEmpty) return false;

    return _formKey.currentState!.validate();
  }

  void addJobToForm() {
    _jobsControllers.add(EnterpriseJobListController(job: Job.empty));
    setState(() {});
  }

  JobList get jobs {
    final jobs = JobList();
    for (final controller in _jobsControllers) {
      jobs.add(controller.job);
    }
    return jobs;
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
        Text(
          'Métier ${index + 1}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        EnterpriseJobListTile(
            controller: controller,
            elevation: 0,
            canChangeExpandedState: false,
            initialExpandedState: true,
            editMode: true,
            onRequestDelete: () =>
                setState(() => _jobsControllers.remove(controller))),
        const SizedBox(height: 20),
      ],
    );
  }
}

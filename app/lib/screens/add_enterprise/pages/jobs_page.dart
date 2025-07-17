import 'package:common/models/enterprises/job.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common_flutter/providers/school_boards_provider.dart';
import 'package:common_flutter/widgets/enterprise_job_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('JobsPage');

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => JobsPageState();
}

class JobsPageState extends State<JobsPage> {
  final _formKey = GlobalKey<FormState>();
  final _jobsControllers = <EnterpriseJobListController>[];

  bool validate() {
    _logger.finer('Validating JobsPage with ${_jobsControllers.length} jobs');

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
    _logger.finer('Building JobsPage with ${_jobsControllers.length} jobs');

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
            showHeader: false,
            schools: [
              SchoolBoardsProvider.of(context, listen: false).mySchool!
            ],
            elevation: 0,
            canChangeExpandedState: false,
            initialExpandedState: true,
            editMode: true),
        const SizedBox(height: 20),
      ],
    );
  }
}

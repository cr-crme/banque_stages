import 'package:flutter/material.dart';

import '/common/models/job.dart';
import '/common/models/job_list.dart';
import '/common/widgets/delete_button.dart';
import '/common/widgets/form_fields/job_form_field_list_tile.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => JobsPageState();
}

class JobsPageState extends State<JobsPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<int, Widget> _jobsForm = {};
  int _formsKey = 0;
  final JobList jobs = JobList();

  bool validate() {
    jobs.clear();
    _formKey.currentState!.save();
    if (jobs.isEmpty) return false;

    return _formKey.currentState!.validate();
  }

  Widget _buildNewJobsForm(int index) {
    final key = _jobsForm.keys.toList()[index];
    return Column(
      key: Key(key.toString()),
      children: [
        ListTile(
          visualDensity:
              const VisualDensity(vertical: VisualDensity.minimumDensity),
          title: Text(
            'Métier ${index + 1}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          trailing: DeleteButton(
            onPressed: () => setState(() => _jobsForm.remove(key)),
          ),
        ),
        _jobsForm[key]!,
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void addJobToForm() {
    _jobsForm[_formsKey] = JobFormFieldListTile(
      onSaved: (Job? job) => setState(() => jobs.add(job!)),
    );
    _formsKey++;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _jobsForm.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) =>
            _buildNewJobsForm(index),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/models/job_list.dart';
import 'package:crcrme_banque_stages/common/widgets/delete_button.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/job_form_field_list_tile.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => JobsPageState();
}

class JobsPageState extends State<JobsPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<GlobalKey<FormState>, Widget> _jobsForm = {};
  final JobList jobs = JobList();

  bool validate() {
    jobs.clear();
    _formKey.currentState!.save();

    if (_jobsForm.isEmpty) return false;

    for (final key in _jobsForm.keys) {
      key.currentState?.activate();
    }

    return _formKey.currentState!.validate();
  }

  void addJobToForm() {
    final key = GlobalKey<FormState>();
    _jobsForm[key] = JobFormFieldListTile(
      key: key,
      onSaved: (Job? job) => setState(() => jobs.add(job!)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Form(
        key: _formKey,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _jobsForm.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) =>
              _buildNewJobsForm(index),
        ),
      ),
    );
  }

  Widget _buildNewJobsForm(int index) {
    final key = _jobsForm.keys.toList()[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: Key('${key}_formKey'),
      children: [
        Row(
          children: [
            Text(
              'Métier ${index + 1}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            DeleteButton(
              onPressed: () => setState(() => _jobsForm.remove(key)),
            ),
          ],
        ),
        _jobsForm[key]!,
        const SizedBox(height: 20),
      ],
    );
  }
}

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
  JobsPageState() {
    jobs.add(Job());
  }

  final _formKey = GlobalKey<FormState>();
  final JobList jobs = JobList();

  void addMetier() {
    setState(() => jobs.add(Job()));
  }

  void _removeMetier(int index) {
    setState(() {
      jobs.remove(index);

      if (jobs.isEmpty) {
        addMetier();
      }
    });
  }

  bool validate() {
    return _formKey.currentState!.validate();
  }

  void save() {
    _formKey.currentState!.save();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: jobs.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) => Column(
          children: [
            ListTile(
              visualDensity:
                  const VisualDensity(vertical: VisualDensity.minimumDensity),
              title: Text(
                "Métier ${index + 1}",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              trailing: DeleteButton(
                onPressed: () => _removeMetier(index),
              ),
            ),
            JobFormFieldListTile(
              initialValue: jobs[index],
              onSaved: (Job? job) => setState(() => jobs[index] = job!),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

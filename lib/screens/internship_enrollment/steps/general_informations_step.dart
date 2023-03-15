import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/models/student.dart';
import '/common/models/teacher.dart';
import '/common/providers/students_provider.dart';
import '/common/widgets/add_job_button.dart';
import '/common/widgets/form_fields/job_form_field_list_tile.dart';
import '/common/widgets/form_fields/student_picker_form_field.dart';
import '/misc/form_service.dart';

class GeneralInformationsStep extends StatefulWidget {
  const GeneralInformationsStep({
    super.key,
    required this.enterprise,
  });

  final Enterprise enterprise;

  @override
  State<GeneralInformationsStep> createState() =>
      GeneralInformationsStepState();
}

class GeneralInformationsStepState extends State<GeneralInformationsStep> {
  final formKey = GlobalKey<FormState>();

  Student? student;
  Teacher? teacher;

  Job primaryJob = Job();
  Job? secondJob;

  String? supervisorFirstName;
  String? supervisorLastName;
  String? supervisorPhone;
  String? supervisorEmail;

  @override
  Widget build(BuildContext context) {
    Iterable<Job> availableJobs = widget.enterprise.jobs.where(
      (job) =>
          job.positionsOffered - job.positionsOccupied > 0 &&
          job.activitySector != null &&
          job.specialization != null,
    );

    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: TextField(
                decoration: const InputDecoration(labelText: '* Entreprise'),
                controller: TextEditingController(text: widget.enterprise.name),
                enabled: false,
              ),
            ),
            ListTile(
              title: Consumer<StudentsProvider>(
                builder: (context, students, _) => StudentPickerFormField(
                  students: students.toList(),
                  onSaved: (s) => setState(() => student = s),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Métier',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (student?.program == 'FPT')
              const ListTile(
                title: Text('Métier principal'),
              ),
            JobFormFieldListTile(
              initialValue: Job(),
              sectors: availableJobs.map((job) => job.activitySector!).toList(),
              specializations:
                  availableJobs.map((job) => job.specialization!).toList(),
              askNumberPositionsOffered: false,
            ),
            if (student?.program == 'FPT') ...[
              const SizedBox(height: 8),
              if (secondJob == null)
                AddJobButton(
                  onPressed: () => setState(() => secondJob = Job()),
                )
              else ...[
                const ListTile(
                  title: Text('Métier secondaire'),
                ),
                JobFormFieldListTile(
                  initialValue: secondJob!,
                  onSaved: (job) => setState(() => secondJob = job),
                  askNumberPositionsOffered: false,
                ),
              ],
            ],
            const SizedBox(height: 16),
            Text(
              'Superviseur en milieu de travail \n(Responsable dans le milieu de stage)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(labelText: '* Prénom'),
                validator: FormService.textNotEmptyValidator,
                onSaved: (name) => supervisorFirstName = name!,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration:
                    const InputDecoration(labelText: '* Nom de famille'),
                validator: FormService.textNotEmptyValidator,
                onSaved: (name) => supervisorLastName = name!,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.phone),
                  labelText: '* Téléphone',
                ),
                validator: FormService.phoneValidator,
                onSaved: (phone) => supervisorPhone = phone!,
                keyboardType: TextInputType.phone,
              ),
            ),
            ListTile(
              title: TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.mail),
                  labelText: '* Courriel',
                ),
                validator: FormService.emailValidator,
                onSaved: (email) => supervisorEmail = email!,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

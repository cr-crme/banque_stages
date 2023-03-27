import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/models/student.dart';
import '/common/providers/students_provider.dart';
import '/common/widgets/add_job_button.dart';
import '/common/widgets/form_fields/job_form_field_list_tile.dart';
import '/common/widgets/form_fields/student_picker_form_field.dart';
import '/misc/form_service.dart';
import '/misc/job_data_file_service.dart';

class GeneralInformationsStep extends StatefulWidget {
  const GeneralInformationsStep({super.key, required this.enterprise});

  final Enterprise enterprise;

  @override
  State<GeneralInformationsStep> createState() =>
      GeneralInformationsStepState();
}

class GeneralInformationsStepState extends State<GeneralInformationsStep> {
  final formKey = GlobalKey<FormState>();

  Student? student;

  Job? primaryJob;
  final List<Job?> extraJobs = [];

  String? supervisorFirstName;
  String? supervisorLastName;
  String? supervisorPhone;
  String? supervisorEmail;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GeneralInformations(
              enterprise: widget.enterprise,
              onSelectStudent: (s) => setState(() => student = s),
            ),
            _MainJob(
              enterprise: widget.enterprise,
              onSaved: (job) => setState(() => primaryJob = job),
            ),
            if (student != null && student!.program == Program.fpt)
              _ExtraJobs(
                extraJobs: extraJobs,
                onAddJob: () => setState(() => extraJobs.add(null)),
                onSetJob: (job, i) => setState(() => extraJobs[i] = job),
                onDeleteJob: (i) => setState(() => extraJobs.removeAt(i)),
              ),
            _SupervisonInformation(
              onSavedFirstName: (name) => supervisorFirstName = name!,
              onSavedLastName: (name) => supervisorLastName = name!,
              onSavedPhone: (phone) => supervisorPhone = phone!,
              onSavedEmail: (email) => supervisorEmail = email!,
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneralInformations extends StatelessWidget {
  const _GeneralInformations({
    required this.enterprise,
    required this.onSelectStudent,
  });

  final Enterprise enterprise;
  final Function(Student?) onSelectStudent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations générales',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ListTile(
          title: TextField(
            decoration: const InputDecoration(labelText: '* Entreprise'),
            controller: TextEditingController(text: enterprise.name),
            enabled: false,
          ),
        ),
        ListTile(
          title: Consumer<StudentsProvider>(
            builder: (context, students, _) => StudentPickerFormField(
              students: students.toList(),
              onSaved: onSelectStudent,
              onSelect: onSelectStudent,
            ),
          ),
        )
      ],
    );
  }
}

class _MainJob extends StatelessWidget {
  const _MainJob({required this.enterprise, required this.onSaved});

  final Enterprise enterprise;
  final Function(Job?) onSaved;

  Map<Specialization, int> _generateSpecializationAndAvailability(context) {
    final Map<Specialization, int> out = {};
    for (final job in enterprise.availableJobs(context)) {
      out[job.specialization] = job.positionsRemaining(context);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            'Métier principal',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        JobFormFieldListTile(
          specializations: _generateSpecializationAndAvailability(context),
          askNumberPositionsOffered: false,
          onSaved: onSaved,
        )
      ],
    );
  }
}

class _ExtraJobs extends StatelessWidget {
  const _ExtraJobs({
    required this.extraJobs,
    required this.onAddJob,
    required this.onSetJob,
    required this.onDeleteJob,
  });

  final List<Job?> extraJobs;
  final Function() onAddJob;
  final Function(Job, int) onSetJob;
  final Function(int) onDeleteJob;

  Widget _extraJobTileBuilder(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Métier supplémentaire ${index + 1}'),
            ),
            IconButton(
              onPressed: () => onDeleteJob(index),
              icon: const Icon(Icons.delete, color: Colors.red),
            )
          ],
        ),
        JobFormFieldListTile(
          onSaved: (job) => onSetJob(job!, index),
          askNumberPositionsOffered: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            'Métiers supplémentaires',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (extraJobs.isNotEmpty)
          ...extraJobs
              .asMap()
              .keys
              .map<Widget>((i) => _extraJobTileBuilder(i))
              .toList(),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: AddJobButton(onPressed: onAddJob),
        ),
      ],
    );
  }
}

class _SupervisonInformation extends StatelessWidget {
  const _SupervisonInformation({
    required this.onSavedFirstName,
    required this.onSavedLastName,
    required this.onSavedPhone,
    required this.onSavedEmail,
  });

  final Function(String?) onSavedFirstName;
  final Function(String?) onSavedLastName;
  final Function(String?) onSavedPhone;
  final Function(String?) onSavedEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            'Superviseur en milieu de travail \n(Responsable dans le milieu de stage)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListTile(
          title: TextFormField(
            decoration: const InputDecoration(labelText: '* Prénom'),
            validator: FormService.textNotEmptyValidator,
            onSaved: onSavedFirstName,
          ),
        ),
        ListTile(
          title: TextFormField(
            decoration: const InputDecoration(labelText: '* Nom de famille'),
            validator: FormService.textNotEmptyValidator,
            onSaved: onSavedLastName,
          ),
        ),
        ListTile(
          title: TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.phone),
              labelText: '* Téléphone',
            ),
            validator: FormService.phoneValidator,
            onSaved: onSavedPhone,
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
            onSaved: onSavedEmail,
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      ],
    );
  }
}

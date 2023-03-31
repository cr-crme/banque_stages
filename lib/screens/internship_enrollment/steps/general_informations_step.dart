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
  final List<Specialization?> extraSpecializations = [];

  String? supervisorFirstName;
  String? supervisorLastName;
  String? supervisorPhone;
  String? supervisorEmail;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
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
            _ExtraSpecialization(
              extraSpecializations: extraSpecializations,
              onAddSpecialization: () =>
                  setState(() => extraSpecializations.add(null)),
              onSetSpecialization: (specialization, i) =>
                  setState(() => extraSpecializations[i] = specialization),
              onDeleteSpecialization: (i) =>
                  setState(() => extraSpecializations.removeAt(i)),
            ),
          _SupervisonInformation(
            onSavedFirstName: (name) => supervisorFirstName = name!,
            onSavedLastName: (name) => supervisorLastName = name!,
            onSavedPhone: (phone) => supervisorPhone = phone!,
            onSavedEmail: (email) => supervisorEmail = email!,
          ),
        ],
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

class _ExtraSpecialization extends StatelessWidget {
  const _ExtraSpecialization({
    required this.extraSpecializations,
    required this.onAddSpecialization,
    required this.onSetSpecialization,
    required this.onDeleteSpecialization,
  });

  final List<Specialization?> extraSpecializations;
  final Function() onAddSpecialization;
  final Function(Specialization, int) onSetSpecialization;
  final Function(int) onDeleteSpecialization;

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
              onPressed: () => onDeleteSpecialization(index),
              icon: const Icon(Icons.delete, color: Colors.red),
            )
          ],
        ),
        JobFormFieldListTile(
          onSaved: (job) => onSetSpecialization(job!.specialization, index),
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
        if (extraSpecializations.isNotEmpty)
          ...extraSpecializations
              .asMap()
              .keys
              .map<Widget>((i) => _extraJobTileBuilder(i))
              .toList(),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: AddJobButton(onPressed: onAddSpecialization),
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
            'Superviseur en milieu de travail \n(responsable du stagiaire)',
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/models/student.dart';
import '/common/providers/students_provider.dart';
import '/common/widgets/add_job_button.dart';
import '/common/widgets/form_fields/job_form_field_list_tile.dart';
import '/common/widgets/form_fields/student_picker_form_field.dart';
import '/common/widgets/phone_list_tile.dart';
import '/common/widgets/sub_title.dart';
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
    return SingleChildScrollView(
      child: Form(
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
        const SubTitle('Informations générales', left: 0, top: 0),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: '* Entreprise'),
                controller: TextEditingController(text: enterprise.name),
                enabled: false,
              ),
              Consumer<StudentsProvider>(
                builder: (context, students, _) => StudentPickerFormField(
                  students: students.toList(),
                  onSaved: onSelectStudent,
                  onSelect: onSelectStudent,
                ),
              ),
            ],
          ),
        ),
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
        const SubTitle('Métier principal', left: 0),
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

  Widget _extraJobTileBuilder(context, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                'Métier supplémentaire ${index + 1}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
              .map<Widget>((i) => _extraJobTileBuilder(context, i))
              .toList(),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 12),
          child: AddJobButton(
            onPressed: onAddSpecialization,
            style: Theme.of(context).textButtonTheme.style!.copyWith(
                backgroundColor: Theme.of(context)
                    .elevatedButtonTheme
                    .style!
                    .backgroundColor),
          ),
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
        const SubTitle('Superviseur en milieu de travail', left: 0),
        const Text('(Responsable du stagiaire)'),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '* Prénom'),
                validator: (text) =>
                    text!.isEmpty ? 'Ajouter un prénom.' : null,
                onSaved: onSavedFirstName,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: '* Nom de famille'),
                validator: (text) =>
                    text!.isEmpty ? 'Ajouter un nom de famille.' : null,
                onSaved: onSavedLastName,
              ),
              PhoneListTile(
                onSaved: onSavedPhone,
                isMandatory: true,
                enabled: true,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.mail),
                  labelText: '* Courriel',
                ),
                validator: FormService.emailValidator,
                onSaved: onSavedEmail,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

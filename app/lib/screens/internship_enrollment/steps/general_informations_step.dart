import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:crcrme_banque_stages/common/models/enterprise_extension.dart';
import 'package:crcrme_banque_stages/common/models/job_extension.dart';
import 'package:crcrme_banque_stages/common/models/students_extension.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/add_job_button.dart';
import 'package:crcrme_banque_stages/common/widgets/email_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/job_form_field_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/student_picker_form_field.dart';
import 'package:crcrme_banque_stages/common/widgets/phone_list_tile.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';

class GeneralInformationsStep extends StatefulWidget {
  const GeneralInformationsStep({super.key, required this.enterprise});

  final Enterprise enterprise;

  @override
  State<GeneralInformationsStep> createState() =>
      GeneralInformationsStepState();
}

class GeneralInformationsStepState extends State<GeneralInformationsStep> {
  final formKey = GlobalKey<FormState>();

  late Enterprise? enterprise = widget.enterprise;
  Student? student;

  Job? primaryJob;
  final List<Specialization?> extraSpecializations = [];

  String? supervisorFirstName;
  String? supervisorLastName;
  String? supervisorPhone;
  String? supervisorEmail;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GeneralInformations(
              enterprise: enterprise,
              onSelectEnterprise: (e) => setState(() => enterprise = e),
              student: student,
              onSelectStudent: (s) => setState(() => student = s),
            ),
            const SizedBox(height: 10),
            _MainJob(
                enterprise: enterprise,
                onSaved: (job) => setState(() => primaryJob = job),
                extraSpecializations: extraSpecializations),
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
              enterprise: enterprise,
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
    required this.onSelectEnterprise,
    required this.student,
    required this.onSelectStudent,
  });

  final Enterprise? enterprise;
  final Function(Enterprise?) onSelectEnterprise;
  final Student? student;
  final Function(Student?) onSelectStudent;

  List<Student> _studentsWithoutInternship(context, List<Student> students) {
    final List<Student> out = [];
    for (final student in students) {
      if (!student.hasActiveInternship(context)) out.add(student);
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    final students = StudentsProvider.studentsInMyGroups(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Stagiaire', left: 0, top: 0),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StudentPickerFormField(
                students: _studentsWithoutInternship(context, students),
                onSaved: onSelectStudent,
                onSelect: onSelectStudent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MainJob extends StatelessWidget {
  const _MainJob(
      {required this.enterprise,
      required this.onSaved,
      required this.extraSpecializations});

  final Enterprise? enterprise;
  final Function(Job?) onSaved;
  final List<Specialization?> extraSpecializations;

  Map<Specialization, int> _generateSpecializationAndAvailability(context) {
    final Map<Specialization, int> out = {};
    if (enterprise == null) return out;
    for (final job in enterprise!.availableJobs(context)) {
      out[job.specialization] = job.positionsRemaining(context);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Métier', left: 0),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (extraSpecializations.isNotEmpty)
                Text(
                  'Métier principal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              JobFormFieldListTile(
                specializations:
                    _generateSpecializationAndAvailability(context),
                specializationOnly: true,
                onSaved: onSaved,
              ),
            ],
          ),
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
            Text(
              'Métier supplémentaire ${index + 1}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(
              width: 35,
              height: 35,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () => onDeleteSpecialization(index),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
            )
          ],
        ),
        JobFormFieldListTile(
          onSaved: (job) => onSetSpecialization(job!.specialization, index),
          specializationOnly: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (extraSpecializations.isNotEmpty)
            ...extraSpecializations.asMap().keys.map<Widget>((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _extraJobTileBuilder(context, i),
                )),
          Text(
              'Besoin d\'ajouter des compétences d\'un autre métier pour ce stage?',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          AddJobButton(
            onPressed: onAddSpecialization,
            style: Theme.of(context).textButtonTheme.style!.copyWith(
                backgroundColor: Theme.of(context)
                    .elevatedButtonTheme
                    .style!
                    .backgroundColor),
          ),
        ],
      ),
    );
  }
}

class _SupervisonInformation extends StatefulWidget {
  const _SupervisonInformation({
    required this.enterprise,
    required this.onSavedFirstName,
    required this.onSavedLastName,
    required this.onSavedPhone,
    required this.onSavedEmail,
  });

  final Enterprise? enterprise;
  final Function(String?) onSavedFirstName;
  final Function(String?) onSavedLastName;
  final Function(String?) onSavedPhone;
  final Function(String?) onSavedEmail;

  @override
  State<_SupervisonInformation> createState() => _SupervisonInformationState();
}

class _SupervisonInformationState extends State<_SupervisonInformation> {
  bool _useContactInfo = false; // Start at false, but call toggle on init

  @override
  void initState() {
    super.initState();
    _toggleUseContactInfo();
  }

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  void _toggleUseContactInfo() {
    _useContactInfo = !_useContactInfo;
    if (_useContactInfo) {
      _firstNameController.text = widget.enterprise?.contact.firstName ?? '';
      _lastNameController.text = widget.enterprise?.contact.lastName ?? '';
      _phoneController.text = widget.enterprise?.contact.phone.toString() ?? '';
      _emailController.text = widget.enterprise?.contact.email ?? '';
    } else {
      _firstNameController.text = '';
      _lastNameController.text = '';
      _phoneController.text = '';
      _emailController.text = '';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Responsable en milieu de stage', left: 0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text('Même personne que le contact de l\'entreprise',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Switch(
              onChanged: widget.enterprise == null
                  ? null
                  : (newValue) => _toggleUseContactInfo(),
              value: _useContactInfo,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: '* Prénom'),
                validator: (text) =>
                    text!.isEmpty ? 'Ajouter un prénom.' : null,
                onSaved: widget.onSavedFirstName,
                enabled: !_useContactInfo,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration:
                    const InputDecoration(labelText: '* Nom de famille'),
                validator: (text) =>
                    text!.isEmpty ? 'Ajouter un nom de famille.' : null,
                onSaved: widget.onSavedLastName,
                enabled: !_useContactInfo,
              ),
              PhoneListTile(
                controller: _phoneController,
                onSaved: widget.onSavedPhone,
                isMandatory: true,
                canCall: false,
                enabled: !_useContactInfo,
              ),
              EmailListTile(
                controller: _emailController,
                isMandatory: true,
                onSaved: widget.onSavedEmail,
                enabled: !_useContactInfo,
                canMail: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

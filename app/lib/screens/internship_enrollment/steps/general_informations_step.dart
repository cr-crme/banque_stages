import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:common_flutter/providers/auth_provider.dart';
import 'package:common_flutter/providers/school_boards_provider.dart';
import 'package:common_flutter/widgets/email_list_tile.dart';
import 'package:common_flutter/widgets/enterprise_job_list_tile.dart';
import 'package:common_flutter/widgets/phone_list_tile.dart';
import 'package:common_flutter/widgets/student_picker_tile.dart';
import 'package:crcrme_banque_stages/common/extensions/enterprise_extension.dart';
import 'package:crcrme_banque_stages/common/extensions/students_extension.dart';
import 'package:crcrme_banque_stages/common/provider_helpers/students_helpers.dart';
import 'package:crcrme_banque_stages/common/widgets/add_job_button.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('GeneralInformationsStep');

List<Student> _studentsWithoutInternship(context, List<Student> students) {
  final List<Student> out = [];
  for (final student in students) {
    if (!student.hasActiveInternship(context)) out.add(student);
  }

  return out;
}

class GeneralInformationsStep extends StatefulWidget {
  const GeneralInformationsStep(
      {super.key, required this.enterprise, this.specifiedSpecialization});

  final Enterprise enterprise;
  final List<Specialization>? specifiedSpecialization;

  @override
  State<GeneralInformationsStep> createState() =>
      GeneralInformationsStepState();
}

class GeneralInformationsStepState extends State<GeneralInformationsStep> {
  final formKey = GlobalKey<FormState>();

  late final studentController = StudentPickerController(
    schoolBoardId: AuthProvider.of(context, listen: false).schoolBoardId!,
    studentWhiteList: _studentsWithoutInternship(
        context, StudentsHelpers.studentsInMyGroups(context)),
  );
  Enterprise get enterprise => widget.enterprise;
  Student? get student => studentController.student;

  late final primaryJobController = EnterpriseJobListController(
    job: widget.enterprise.availablejobs(context).length == 1
        ? widget.enterprise.availablejobs(context).first
        : Job.empty,
    specializationWhiteList: widget.specifiedSpecialization ??
        widget.enterprise
            .withRemainingPositions(context,
                schoolId: AuthProvider.of(context, listen: false).schoolId!,
                listen: false)
            .map((job) => job.specialization)
            .toList(),
  );
  final extraJobControllers = <EnterpriseJobListController>[];

  String? supervisorFirstName;
  String? supervisorLastName;
  String? supervisorPhone;
  String? supervisorEmail;

  @override
  Widget build(BuildContext context) {
    _logger.finer(
        'Building GeneralInformationsStep for enterprise: ${enterprise.id}');

    return FocusScope(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GeneralInformations(
                studentController: studentController, setState: setState),
            const SizedBox(height: 10),
            _MainJob(
                controller: primaryJobController,
                extraJobControllers: extraJobControllers),
            if (student != null && student!.program == Program.fpt)
              _ExtraSpecialization(
                  controllers: extraJobControllers, setState: setState),
            _SupervisonInformation(
              enterprise: widget.enterprise,
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
  const _GeneralInformations(
      {required this.studentController, required this.setState});
  final StudentPickerController studentController;

  final Function(Function()) setState;

  @override
  Widget build(BuildContext context) {
    _logger.finer(
        'Building _GeneralInformations with selected student: ${studentController.student?.id}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Stagiaire', left: 0, top: 0),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StudentPickerTile(
                controller: studentController,
                onSelected: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MainJob extends StatelessWidget {
  const _MainJob({
    required this.controller,
    required this.extraJobControllers,
  });

  final EnterpriseJobListController controller;
  final List<EnterpriseJobListController> extraJobControllers;

  @override
  Widget build(BuildContext context) {
    _logger
        .finer('Building _MainJob with controller job: ${controller.job.id}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Métier', left: 0),
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (extraJobControllers.isNotEmpty)
                Text(
                  'Métier principal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              EnterpriseJobListTile(
                controller: controller,
                schools: [
                  SchoolBoardsProvider.of(context, listen: false).mySchool!
                ],
                editMode: true,
                specializationOnly: true,
                canChangeExpandedState: false,
                initialExpandedState: true,
                elevation: 0.0,
                showHeader: false,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _ExtraSpecialization extends StatelessWidget {
  const _ExtraSpecialization(
      {required this.controllers, required this.setState});

  final List<EnterpriseJobListController> controllers;
  final Function(void Function()) setState;

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
                onTap: () => setState(() => controllers.removeAt(index)),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
            )
          ],
        ),
        EnterpriseJobListTile(
          controller: controllers[index],
          schools: [SchoolBoardsProvider.of(context, listen: false).mySchool!],
          editMode: true,
          specializationOnly: true,
          canChangeExpandedState: false,
          initialExpandedState: true,
          elevation: 0.0,
          showHeader: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _logger.finer(
        'Building _ExtraSpecialization with ${controllers.length} controllers');

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...controllers.asMap().keys.map<Widget>((i) => Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: _extraJobTileBuilder(context, i),
              )),
          Text(
              'Besoin d\'ajouter des compétences d\'un autre métier pour ce stage?',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          AddJobButton(
            onPressed: () => setState(() {
              controllers.add(EnterpriseJobListController(job: Job.empty));
            }),
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
    _logger.finer(
        'Building _SupervisionInformation for enterprise: ${widget.enterprise?.id} '
        'and contact id: ${widget.enterprise?.contact.id}');

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

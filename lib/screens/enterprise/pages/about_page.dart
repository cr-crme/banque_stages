import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '/common/models/enterprise.dart';
import '/common/models/teacher.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/schools_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/common/widgets/activity_type_cards.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
import '/common/widgets/disponibility_circle.dart';
import '/common/widgets/form_fields/activity_types_picker_form_field.dart';
import '/common/widgets/form_fields/share_with_picker_form_field.dart';
import '/misc/form_service.dart';

class EnterpriseAboutPage extends StatefulWidget {
  const EnterpriseAboutPage({
    super.key,
    required this.enterprise,
  });

  final Enterprise enterprise;

  @override
  State<EnterpriseAboutPage> createState() => EnterpriseAboutPageState();
}

class EnterpriseAboutPageState extends State<EnterpriseAboutPage> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  Set<String> _activityTypes = {};
  String? _shareWith;

  bool _editing = false;
  bool get editing => _editing;

  void toggleEdit() {
    if (!_editing) {
      setState(() => _editing = true);
      return;
    }

    if (!FormService.validateForm(_formKey, save: true)) {
      return;
    }

    context.read<EnterprisesProvider>().replace(
          widget.enterprise.copyWith(
            name: _name,
            activityTypes: _activityTypes,
            shareWith: _shareWith,
          ),
        );

    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => ConfirmPopDialog.show(context, editing: editing),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _GeneralInformation(
                  enterprise: widget.enterprise,
                  editMode: _editing,
                  onSaved: (name) => _name = name),
              _AvailablePlace(enterprise: widget.enterprise),
              _ActivityType(
                  enterprise: widget.enterprise,
                  editMode: _editing,
                  onSaved: (activityTypes) => _activityTypes = activityTypes!),
              _RecrutedBy(enterprise: widget.enterprise),
              _SharingLevel(
                  enterprise: widget.enterprise,
                  editingMode: _editing,
                  onSaved: (shareWith) => _shareWith = shareWith),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeneralInformation extends StatelessWidget {
  const _GeneralInformation(
      {required this.enterprise,
      required this.editMode,
      required this.onSaved});

  final Enterprise enterprise;
  final bool editMode;
  final Function(String?) onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Title('Informations générales'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                width: 140,
                height: 105,
                color: Theme.of(context).disabledColor,
                child: enterprise.photoUrl != null
                    ? Image.network(enterprise.photoUrl!)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Nom de l\'entreprise',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (editMode)
                      TextFormField(
                        controller:
                            TextEditingController(text: enterprise.name),
                        enabled: editMode,
                        onSaved: onSaved,
                      ),
                    if (!editMode) Text(enterprise.name),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _AvailablePlace extends StatelessWidget {
  const _AvailablePlace({required this.enterprise});

  final Enterprise enterprise;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Title('Places de stage disponibles'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: enterprise.jobs
                .map(
                  (job) => ListTile(
                    visualDensity: VisualDensity.compact,
                    leading: DisponibilityCircle(
                      positionsOffered: job.positionsOffered,
                      positionsOccupied: job.positionsOccupied,
                    ),
                    title: Text(job.specialization?.idWithName ?? 'bad id'),
                    trailing: Text(
                        '${job.positionsOffered - job.positionsOccupied} / ${job.positionsOffered}'),
                  ),
                )
                .toList(),
          ),
        )
      ],
    );
  }
}

class _ActivityType extends StatelessWidget {
  const _ActivityType(
      {required this.enterprise,
      required this.editMode,
      required this.onSaved});

  final Enterprise enterprise;
  final bool editMode;
  final Function(Set<String>?) onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _Title('Types d\'activités'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Visibility(
                visible: !editMode,
                child:
                    ActivityTypeCards(activityTypes: enterprise.activityTypes),
              ),
              Visibility(
                visible: editMode,
                child: ActivityTypesPickerFormField(
                  initialValue: enterprise.activityTypes,
                  onSaved: onSaved,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _RecrutedBy extends StatelessWidget {
  const _RecrutedBy({required this.enterprise});

  final Enterprise enterprise;

  void _sendEmail(Teacher teacher) {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: teacher.email!,
    );
    launchUrl(emailLaunchUri);
  }

  @override
  Widget build(BuildContext context) {
    final schools = SchoolsProvider.of(context);
    final teachers = TeachersProvider.of(context);

    final teacher = teachers.fromId(enterprise.recrutedBy);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Title('Entreprise recrutée par :'),
        GestureDetector(
          onTap: teacher.email == null ? null : () => _sendEmail(teacher),
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Row(
              children: [
                Text(
                  teacher.fullName,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        decoration: teacher.email == null
                            ? null
                            : TextDecoration.underline,
                        color: teacher.email == null ? null : Colors.blue,
                      ),
                ),
                Flexible(
                  child: Text(
                    ' - ${schools.fromId(teacher.schoolId).name}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _SharingLevel extends StatelessWidget {
  const _SharingLevel(
      {required this.enterprise,
      required this.editingMode,
      required this.onSaved});

  final Enterprise enterprise;
  final bool editingMode;
  final Function(String?) onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            'Partage de l\'entreprise',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Visibility(
                visible: !editingMode,
                child: Text(
                  enterprise.shareWith,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Visibility(
                visible: editingMode,
                child: ShareWithPickerFormField(
                  initialValue: enterprise.shareWith,
                  onSaved: onSaved,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

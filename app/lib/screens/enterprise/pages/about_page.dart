import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/utils.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/extensions/job_extension.dart';
import 'package:crcrme_banque_stages/common/widgets/activity_type_cards.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_exit_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/disponibility_circle.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/activity_types_picker_form_field.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/misc/form_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EnterpriseAboutPage extends StatefulWidget {
  const EnterpriseAboutPage({
    super.key,
    required this.enterprise,
    required this.onAddInternshipRequest,
  });

  final Enterprise enterprise;
  final Function(Enterprise) onAddInternshipRequest;

  @override
  State<EnterpriseAboutPage> createState() => EnterpriseAboutPageState();
}

class EnterpriseAboutPageState extends State<EnterpriseAboutPage> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  Set<ActivityTypes> _activityTypes = {};
  final Map<Job, int> _positionOffered = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _name = widget.enterprise.name;
    _activityTypes = {...widget.enterprise.activityTypes};
    _positionOffered.clear();
    for (var job in widget.enterprise.jobs) {
      _positionOffered[job] = job.positionsOffered;
    }
  }

  bool _editing = false;
  bool get editing => _editing;

  void toggleEdit({bool save = true}) {
    if (_editing) {
      _editing = false;
      if (!save) {
        setState(() {});
        return;
      }
    } else {
      setState(() => _editing = true);
      return;
    }

    if (!FormService.validateForm(_formKey, save: true)) {
      return;
    }

    if (_name != widget.enterprise.name ||
        areSetsNotEqual(_activityTypes, widget.enterprise.activityTypes) ||
        areMapsNotEqual(_positionOffered, {
          for (var job in widget.enterprise.jobs) job: job.positionsOffered,
        })) {
      EnterprisesProvider.of(context, listen: false).replace(
        widget.enterprise.copyWith(
            name: _name,
            activityTypes: _activityTypes,
            jobs: JobList()
              ..addAll(widget.enterprise.jobs.map((job) {
                return job.copyWith(positionsOffered: _positionOffered[job]!);
              }))),
      );
    }

    setState(() => _editing = false);
  }

  bool _canPop = false;

  @override
  Widget build(BuildContext context) {
    EnterprisesProvider.of(context); // Register so the build is triggered

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (_canPop) return;

        _canPop = await ConfirmExitDialog.show(context,
            content: Text.rich(TextSpan(children: [
              const TextSpan(
                  text: '** Vous quittez la page sans avoir '
                      'cliqué sur Enregistrer '),
              WidgetSpan(
                  child: SizedBox(
                height: 22,
                width: 22,
                child: Icon(
                  Icons.save,
                  color: Theme.of(context).primaryColor,
                ),
              )),
              const TextSpan(
                text: '. **\n\nToutes vos modifications seront perdues.',
              ),
            ])),
            isEditing: editing);

        // If the user confirms the exit, redo the pop
        if (_canPop && context.mounted) Navigator.of(context).pop();
      },
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GeneralInformation(
                  enterprise: widget.enterprise,
                  editMode: _editing,
                  onSaved: (name) => _name = name),
              _AvailablePlace(
                initial: _positionOffered,
                editMode: _editing,
                onChanged: (Job job, int newValue) =>
                    setState(() => _positionOffered[job] = newValue),
              ),
              _ActivityType(
                  initial: _activityTypes,
                  editMode: _editing,
                  onSaved: (activityTypes) => _activityTypes = activityTypes!),
              _RecrutedBy(enterprise: widget.enterprise),
              _AddInternshipButton(
                editingMode: _editing,
                onPressed: () async =>
                    await widget.onAddInternshipRequest(widget.enterprise),
              ),
              const SizedBox(height: 24),
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
    return editMode
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SubTitle('Nom de l\'entreprise'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller:
                            TextEditingController(text: enterprise.name),
                        enabled: editMode,
                        onSaved: onSaved,
                        validator: (text) => text!.isEmpty
                            ? 'Ajouter le nom de l\'entreprise.'
                            : null,
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        : Container();
  }
}

class _AvailablePlace extends StatelessWidget {
  const _AvailablePlace({
    required this.initial,
    required this.editMode,
    required this.onChanged,
  });

  final Map<Job, int> initial;
  final bool editMode;
  final Function(Job job, int newValue) onChanged;

  @override
  Widget build(BuildContext context) {
    final jobs = initial.keys.toList();
    jobs.sort(
      (a, b) => a.specialization.name
          .toLowerCase()
          .compareTo(b.specialization.name.toLowerCase()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Places de stage disponibles'),
        Column(
          children: jobs.map(
            (job) {
              final positionsRemaining = job.positionsRemaining(context);
              final int positionsOffered = initial[job]!;

              return ListTile(
                visualDensity: VisualDensity.compact,
                leading: DisponibilityCircle(
                  positionsOffered: positionsOffered,
                  positionsOccupied: job.positionsOccupied(context),
                ),
                title: Text(job.specialization.idWithName),
                trailing: editMode
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: positionsOffered == 0
                                  ? null
                                  : () => onChanged(job, positionsOffered - 1),
                              icon: Icon(Icons.remove,
                                  color: positionsRemaining == 0
                                      ? Colors.grey
                                      : Colors.black)),
                          Text(positionsOffered.toString()),
                          IconButton(
                              onPressed: () =>
                                  onChanged(job, positionsOffered + 1),
                              icon: const Icon(Icons.add, color: Colors.black)),
                        ],
                      )
                    : Text(
                        '${job.positionsRemaining(context)} / $positionsOffered',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
              );
            },
          ).toList(),
        )
      ],
    );
  }
}

class _ActivityType extends StatelessWidget {
  const _ActivityType(
      {required this.initial, required this.editMode, required this.onSaved});

  final Set<ActivityTypes> initial;
  final bool editMode;
  final Function(Set<ActivityTypes>?) onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Types d\'activités'),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Column(
            children: [
              Visibility(
                visible: !editMode,
                child: ActivityTypeCards(activityTypes: initial),
              ),
              Visibility(
                visible: editMode,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ActivityTypesPickerFormField(
                    initialValue: initial,
                    onSaved: onSaved,
                    activityTabAtTop: true,
                  ),
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

  Future<Teacher?> _getTeacherFromId(BuildContext context) async {
    while (true) {
      if (!context.mounted) return null;
      final teachers = TeachersProvider.of(context);
      final teacher = teachers.fromIdOrNull(enterprise.recruiterId);
      if (teacher != null) return teacher;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getTeacherFromId(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final teacher = snapshot.data! as Teacher;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SubTitle('Entreprise recrutée par'),
              GestureDetector(
                onTap: teacher.email == null ? null : () => _sendEmail(teacher),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Text(
                    teacher.fullName,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          decoration: teacher.email == null
                              ? null
                              : TextDecoration.underline,
                          color: teacher.email == null ? null : Colors.blue,
                        ),
                  ),
                ),
              )
            ],
          );
        });
  }
}

class _AddInternshipButton extends StatelessWidget {
  const _AddInternshipButton({
    required this.editingMode,
    required this.onPressed,
  });

  final bool editingMode;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: editingMode
            ? Container()
            : ElevatedButton(
                onPressed: onPressed,
                child: const Text('Inscrire un stagiaire')),
      ),
    );
  }
}

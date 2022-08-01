import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/activity_type.dart';
import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/models/job_list.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/activity_types_picker_form_field.dart';
import '/common/widgets/add_job_button.dart';
import '/common/widgets/confirm_pop_dialog.dart';
import '/common/widgets/delete_button.dart';
import '/common/widgets/job_form_field.dart';
import '/common/widgets/share_with_picker_form_field.dart';

class AddEnterpriseScreen extends StatefulWidget {
  const AddEnterpriseScreen({Key? key}) : super(key: key);

  static const route = "/add-enterprise";

  @override
  State<AddEnterpriseScreen> createState() => _AddEnterpriseScreenState();
}

class _AddEnterpriseScreenState extends State<AddEnterpriseScreen> {
  _AddEnterpriseScreenState() {
    _jobs.add(Job());
  }

  final _formKeyInformations = GlobalKey<FormState>();
  final _formKeyJobs = GlobalKey<FormState>();
  final _formKeyContact = GlobalKey<FormState>();
  int _currentStep = 0;

  // Infos
  String? _name;
  String? _neq;

  Set<ActivityType> _activityTypes = {};

  String? _shareWith;

  // Métiers
  final JobList _jobs = JobList();

  // Contact
  String? _contactName;
  String? _contactFunction;
  String? _contactPhone;
  String? _contactEmail;

  String? _address;

  void _addMetier() {
    setState(() {
      _jobs.add(Job());
    });
  }

  void _removeMetier(int index) {
    setState(() {
      _jobs.remove(index);

      if (_jobs.isEmpty) {
        _addMetier();
      }
    });
  }

  Future<bool> _onWillPop() async {
    ScaffoldMessenger.of(context).clearSnackBars();

    return await showDialog(
        context: context, builder: (context) => const ConfirmPopDialog());
  }

  void _showInvalidFieldsSnakBar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Assurez vous que tous les champs soient valides")));
  }

  void _nextStep() {
    bool valid = false;
    switch (_currentStep) {
      case 0:
        valid = _formKeyInformations.currentState!.validate();
        break;
      case 1:
        valid = _formKeyJobs.currentState!.validate();
        break;
      case 2:
        valid = _formKeyContact.currentState!.validate();
        break;
    }

    if (!valid) {
      _showInvalidFieldsSnakBar();
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();

    if (_currentStep == 2) {
      _submit(context);
    } else {
      setState(() => _currentStep += 1);
    }
  }

  Widget _controlBuilder(BuildContext context, ControlsDetails details) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Visibility(
          visible: _currentStep == 1,
          child: AddJobButton(onPressed: _addMetier),
        ),
        const Expanded(child: SizedBox()),
        OutlinedButton(
            onPressed: details.onStepCancel, child: const Text("Annuler")),
        const SizedBox(
          width: 20,
        ),
        TextButton(
          onPressed: details.onStepContinue,
          child:
              _currentStep == 2 ? const Text("Ajouter") : const Text("Suivant"),
        )
      ],
    );
  }

  void _submit(BuildContext context) {
    if (!_formKeyInformations.currentState!.validate()) {
      _showInvalidFieldsSnakBar();
      setState(() => _currentStep = 0);
      return;
    } else if (!_formKeyJobs.currentState!.validate()) {
      _showInvalidFieldsSnakBar();
      setState(() => _currentStep = 1);
      return;
    } else if (!_formKeyContact.currentState!.validate()) {
      _showInvalidFieldsSnakBar();
      setState(() => _currentStep = 2);
      return;
    }

    _formKeyInformations.currentState!.save();
    _formKeyJobs.currentState!.save();
    _formKeyContact.currentState!.save();
    EnterprisesProvider provider = context.read<EnterprisesProvider>();

    Enterprise enterprise = Enterprise(
      name: _name!,
      neq: _neq!,
      activityTypes: _activityTypes,
      recrutedBy: "?",
      shareWith: _shareWith!,
      jobs: _jobs,
      contactName: _contactName!,
      contactFunction: _contactFunction!,
      contactPhone: _contactPhone!,
      contactEmail: _contactEmail!,
      address: _address!,
    );

    provider.add(enterprise);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Nouvelle entreprise"),
        ),
        body: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepTapped: (int tapped) => setState(() => _currentStep = tapped),
          onStepCancel: () => Navigator.pop(context),
          steps: [
            Step(
              isActive: _currentStep == 0,
              title: const Text("Informations"),
              content: _informationsForm,
            ),
            Step(
              isActive: _currentStep == 1,
              title: const Text("Métiers"),
              content: _jobsForm,
            ),
            Step(
              isActive: _currentStep == 2,
              title: const Text("Contact"),
              content: _contactForm,
            )
          ],
          controlsBuilder: _controlBuilder,
        ),
      ),
    );
  }

  Form get _informationsForm => Form(
        key: _formKeyInformations,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: TextFormField(
                  decoration: const InputDecoration(labelText: "* Nom"),
                  validator: (text) {
                    if (text!.isEmpty) {
                      return "Le champ ne peut pas être vide";
                    }
                    return null;
                  },
                  onSaved: (name) => _name = name,
                ),
              ),
              ListTile(
                title: TextFormField(
                  decoration: const InputDecoration(labelText: "NEQ"),
                  validator: (text) {
                    if (text!.isNotEmpty &&
                        !RegExp(r'^\d{10}$').hasMatch(text)) {
                      return "Le NEQ est composé de 10 chiffres";
                    }
                    return null;
                  },
                  onSaved: (neq) => _neq = neq,
                ),
              ),
              ListTile(
                title: ActivityTypesPickerFormField(
                  onSaved: (Set<ActivityType>? activityTypes) =>
                      setState(() => _activityTypes = activityTypes!),
                ),
              ),
              ListTile(
                title: ShareWithPickerFormField(
                  onSaved: (String? shareWith) =>
                      setState(() => _shareWith = shareWith),
                ),
              ),
            ],
          ),
        ),
      );

  Form get _jobsForm => Form(
        key: _formKeyJobs,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _jobs.length,
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: JobFormField(
                  initialValue: _jobs[index],
                  onSaved: (Job? job) => setState(() => _jobs[index] = job!),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      );

  Form get _contactForm => Form(
        key: _formKeyContact,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const ListTile(
                visualDensity:
                    VisualDensity(vertical: VisualDensity.minimumDensity),
                title: Text("Personne contact en entreprise"),
              ),
              ListTile(
                title: TextFormField(
                  decoration: const InputDecoration(labelText: "* Nom"),
                  validator: (text) {
                    if (text!.isEmpty) {
                      return "Le champ ne peut pas être vide";
                    }
                    return null;
                  },
                  onSaved: (name) => _contactName = name!,
                ),
              ),
              ListTile(
                title: TextFormField(
                  decoration: const InputDecoration(labelText: "* Fonction"),
                  validator: (text) {
                    if (text!.isEmpty) {
                      return "Le champ ne peut pas être vide";
                    }
                    return null;
                  },
                  onSaved: (function) => _contactFunction = function!,
                ),
              ),
              ListTile(
                title: TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.phone),
                    labelText: "* Téléphone",
                  ),
                  validator: (phone) {
                    if (phone!.isEmpty) {
                      return "Le champ ne peut pas être vide";
                    } else if (!RegExp(
                            r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$')
                        .hasMatch(phone)) {
                      return "Le numéro entré n'est pas valide";
                    }
                    return null;
                  },
                  onSaved: (phone) => _contactPhone = phone!,
                ),
              ),
              ListTile(
                title: TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.mail),
                    labelText: "* Courriel",
                  ),
                  validator: (email) {
                    if (email!.isEmpty) {
                      return "Le champ ne peut pas être vide";
                    } else if (!RegExp(
                            r'^[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+$')
                        .hasMatch(email)) {
                      return "Le courriel entré n'est pas valide";
                    }
                    return null;
                  },
                  onSaved: (email) => _contactEmail = email!,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const ListTile(
                visualDensity:
                    VisualDensity(vertical: VisualDensity.minimumDensity),
                title: Text("Addresse de l'établissement"),
              ),
              // TODO: Implement Google Maps (?) autocomplete
              ListTile(
                title: TextFormField(
                  decoration: const InputDecoration(labelText: "Adresse"),
                  onSaved: (address) => _address = address!,
                ),
              ),
            ],
          ),
        ),
      );
}

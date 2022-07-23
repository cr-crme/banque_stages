import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/activity_type.dart';
import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/models/job_list.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/activity_types_selector_dialog.dart';
import '/common/widgets/confirm_pop_dialog.dart';
import '/common/widgets/job_form_field.dart';

class AddEnterprise extends StatefulWidget {
  const AddEnterprise({Key? key}) : super(key: key);

  static const route = "/enterprises/add";

  @override
  State<AddEnterprise> createState() => _AddEnterpriseState();
}

class _AddEnterpriseState extends State<AddEnterprise> {
  _AddEnterpriseState() {
    _jobs.add(Job());
  }

  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Infos
  String? _name;
  String? _neq;

  Set<ActivityType> _activityTypes = {};

  bool _shareToOthers = true;

  // Métiers
  final JobList _jobs = JobList();

  // Contact
  String? _contactName;
  String? _contactFunction;
  String? _contactPhone;
  String? _contactEmail;

  String? _address;

  Future<void> _showActivityTypeSelector() async {
    Set<ActivityType> activityTypes = await showDialog(
        context: context,
        builder: (context) =>
            ActivityTypesSelectorDialog(initialValue: _activityTypes));

    setState(() => _activityTypes = activityTypes);
  }

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
    return await showDialog(
        context: context, builder: (context) => const ConfirmPopDialog());
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate() == false) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Assurez vous que tous les champs soient valides")));

      setState(() => _currentStep = 0);
      return;
    }

    _formKey.currentState!.save();
    EnterprisesProvider provider = context.read<EnterprisesProvider>();

    Enterprise enterprise = Enterprise(
      name: _name!,
      neq: _neq!,
      activityTypes: _activityTypes,
      recrutedBy: "?",
      shareToOthers: _shareToOthers,
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
          title: const Text("Nouvelle enterprise"),
        ),
        body: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepContinue: () => setState(() {
              if (_currentStep == 2) {
                _submit(context);
              } else {
                _currentStep += 1;
              }
            }),
            onStepTapped: (int index) => setState(() => _currentStep = index),
            onStepCancel: () => Navigator.pop(context),
            steps: [
              Step(
                  isActive: _currentStep == 0,
                  title: const Text("Informations"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListTile(
                          title: TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Nom *"),
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
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          title: const Text("Types d'activités"),
                          subtitle: Text(
                            _activityTypes.join(", "),
                            maxLines: 1,
                          ),
                          trailing: TextButton(
                            child: const Text("Modifier"),
                            onPressed: () => _showActivityTypeSelector(),
                          ),
                        ),
                        SwitchListTile(
                          title: const Text("Partager l'enterprise"),
                          value: _shareToOthers,
                          onChanged: (bool newValue) => setState(() {
                            _shareToOthers = newValue;
                          }),
                        ),
                      ],
                    ),
                  )),
              Step(
                isActive: _currentStep == 1,
                title: const Text("Métiers"),
                content: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _jobs.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) => Column(
                    children: [
                      ListTile(
                        visualDensity: const VisualDensity(
                            vertical: VisualDensity.minimumDensity),
                        title: Text(
                          "Métier ${index + 1}",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        trailing: IconButton(
                          onPressed: () => _removeMetier(index),
                          icon: const Icon(Icons.delete_forever),
                          color: Colors.redAccent,
                        ),
                      ),
                      JobFormField(
                        initialValue: _jobs[index],
                        onSaved: (Job? job) =>
                            setState(() => _jobs[index] = job!),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Step(
                  isActive: _currentStep == 2,
                  title: const Text("Contact"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        const ListTile(
                          visualDensity: VisualDensity(
                              vertical: VisualDensity.minimumDensity),
                          title: Text("Personne contact en enterprise"),
                        ),
                        ListTile(
                          title: TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Nom *"),
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
                            decoration:
                                const InputDecoration(labelText: "Fonction"),
                            onSaved: (function) => _contactFunction = function!,
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            decoration: InputDecoration(
                                label: Row(children: const [
                              Icon(Icons.phone),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text("Téléphone *"),
                              )
                            ])),
                            validator: (phone) {
                              if (phone!.isEmpty) {
                                return "Le champ ne peut pas être vide";
                              }
                              if (!RegExp(
                                      r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$')
                                  .hasMatch(phone)) {
                                return "Le numéro entré doit être valide";
                              }
                              return null;
                            },
                            onSaved: (phone) => _contactPhone = phone!,
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            decoration: InputDecoration(
                                label: Row(children: const [
                              Icon(Icons.mail),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text("Courriel"),
                              )
                            ])),
                            onSaved: (email) => _contactEmail = email!,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const ListTile(
                            visualDensity: VisualDensity(
                                vertical: VisualDensity.minimumDensity),
                            title: Text("Addresse de l'établissement")),
                        ListTile(
                          title: TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Adresse"),
                            onSaved: (address) => _address = address!,
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
            controlsBuilder: (context, details) => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: _currentStep == 1,
                  child: TextButton(
                    onPressed: () => _addMetier(),
                    child: const Text("Ajouter un métier"),
                  ),
                ),
                const Expanded(child: SizedBox()),
                OutlinedButton(
                    onPressed: details.onStepCancel,
                    child: const Text("Annuler")),
                const SizedBox(
                  width: 20,
                ),
                TextButton(
                    onPressed: details.onStepContinue,
                    child: _currentStep == 2
                        ? const Text("Ajouter")
                        : const Text("Suivant"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

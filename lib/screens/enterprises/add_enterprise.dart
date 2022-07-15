import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/activity_types.dart';
import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/providers/activity_types_provider.dart';
import '/common/providers/enterprises_provider.dart';
import 'widgets/activity_types_selector_dialog.dart';

class AddEnterprise extends StatefulWidget {
  const AddEnterprise({Key? key}) : super(key: key);

  static const route = "/enterprises/add";

  @override
  State<AddEnterprise> createState() => _AddEnterpriseState();
}

class _AddEnterpriseState extends State<AddEnterprise> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Infos
  String? _name;
  String? _neq;

  static const _choicesRecrutedBy = ["?"];
  String _recrutedBy = _choicesRecrutedBy[0];

  bool _shareToOthers = true;

  // Métiers
  final List<Job> _jobs = [Job()];

  // Contact
  String? _contactName;
  String? _contactFunction;
  String? _contactPhone;
  String? _contactEmail;

  String? _address;

  void _showActivityTypeSelector(BuildContext context) {
    ActivityTypesProvider provider =
        Provider.of<ActivityTypesProvider>(context, listen: false);

    showDialog(
        context: context,
        builder: (context) => ChangeNotifierProvider.value(
            value: provider, child: const ActivityTypesSelectorDialog()));
  }

  void _addMetier() {
    setState(() {
      _jobs.add(Job());
    });
  }

  void _removeMetier(int index) {
    setState(() {
      _jobs.removeAt(index);

      if (_jobs.isEmpty) {
        _addMetier();
      }
    });
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate() == false) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Assurez vous que tous les champs sont valides")));

      setState(() => _currentStep = 0);
      return;
    }

    _formKey.currentState!.save();

    List<ActivityTypes> activityTypes = context
        .read<ActivityTypesProvider>()
        .activityTypes
        .entries
        .where((activityType) => activityType.value)
        .map((activityType) => activityType.key)
        .toList();

    Enterprise enterprise = Enterprise(
      name: _name!,
      neq: _neq!,
      activityTypes: activityTypes,
      recrutedBy: _recrutedBy,
      shareToOthers: _shareToOthers,
      jobs: _jobs,
      contactName: _contactName!,
      contactFunction: _contactFunction!,
      contactPhone: _contactPhone!,
      contactEmail: _contactEmail!,
      address: _address!,
    );

    context.read<EnterprisesProvider>().add(enterprise);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Nouvelle enterprise"),
        ),
        body: ChangeNotifierProvider<ActivityTypesProvider>(
          create: (context) => ActivityTypesProvider(),
          builder: (context, child) => Form(
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
                              decoration:
                                  const InputDecoration(labelText: "NEQ"),
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
                                context
                                    .watch<ActivityTypesProvider>()
                                    .activityTypes
                                    .entries
                                    .where((e) => e.value)
                                    .map((e) => e.key)
                                    .join(", "),
                                maxLines: 1,
                              ),
                              trailing: TextButton(
                                child: const Text("Modifier"),
                                onPressed: () =>
                                    _showActivityTypeSelector(context),
                              )),
                          ListTile(
                            title: const Text("Enterprise recrutée par"),
                            trailing: DropdownButton<String>(
                              value: _recrutedBy,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _recrutedBy = newValue!;
                                });
                              },
                              items: _choicesRecrutedBy.map((String value) {
                                return DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            visualDensity: const VisualDensity(
                                vertical: VisualDensity.minimumDensity),
                            title: Text("Métier ${index + 1}",
                                textAlign: TextAlign.left),
                            trailing: IconButton(
                              onPressed: () => _removeMetier(index),
                              icon: const Icon(Icons.delete_forever),
                              color: Colors.redAccent,
                            ),
                          ),
                          ListTile(
                            title: const Text("Secteur d'activités"),
                            trailing: DropdownButton<String>(
                              value: _jobs[index].activitySector.name,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _jobs[index] = _jobs[index].copyWith(
                                      activitySector: JobActivitySector.values
                                          .firstWhere((sector) =>
                                              sector.name == newValue!));
                                });
                              },
                              items: JobActivitySector.values
                                  .map((JobActivitySector sector) {
                                return DropdownMenuItem(
                                  value: sector.name,
                                  child: Text(sector.toString()),
                                );
                              }).toList(),
                            ),
                          ),
                          ListTile(
                            title: const Text("Métier semi-spécialisé"),
                            trailing: DropdownButton<String>(
                              value: _jobs[index].specialization.name,
                              icon: const Icon(Icons.arrow_downward),
                              elevation: 16,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _jobs[index] = _jobs[index].copyWith(
                                      specialization: JobSpecialization.values
                                          .firstWhere((specialization) =>
                                              specialization.name ==
                                              newValue!));
                                });
                              },
                              items: JobSpecialization.values
                                  .map((JobSpecialization specialization) {
                                return DropdownMenuItem(
                                  value: specialization.name,
                                  child: Text(specialization.toString()),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ]),
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
                              onSaved: (function) =>
                                  _contactFunction = function!,
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
                    child: ElevatedButton(
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
        ));
  }
}
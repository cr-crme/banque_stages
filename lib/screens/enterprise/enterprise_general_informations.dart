import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/activity_type.dart';
import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/activity_types_selector_dialog.dart';
import '/common/widgets/confirm_pop_dialog.dart';

class EnterpriseGeneralInformation extends StatefulWidget {
  const EnterpriseGeneralInformation({Key? key, required this.enterpriseId})
      : super(key: key);

  static const String route = "generalInfo";

  final String enterpriseId;

  @override
  State<EnterpriseGeneralInformation> createState() =>
      _EnterpriseGeneralInformationState();
}

class _EnterpriseGeneralInformationState
    extends State<EnterpriseGeneralInformation> {
  final _formKey = GlobalKey<FormState>();

  bool _editable = false;

  String? _name;
  String? _neq;

  Set<ActivityType> _activityTypes = {};

  static const _choicesRecrutedBy = ["?"];
  String _recrutedBy = _choicesRecrutedBy[0];

  bool _shareToOthers = true;

  Future<void> _showActivityTypeSelector() async {
    Set<ActivityType> activityTypes = await showDialog(
        context: context,
        routeSettings: RouteSettings(arguments: _activityTypes),
        builder: (context) => const ActivityTypesSelectorDialog());

    setState(() => _activityTypes = activityTypes);
  }

  Future<bool> _onWillPop() async {
    if (_editable) {
      return await showDialog(
          context: context, builder: (context) => const ConfirmPopDialog());
    }

    return true;
  }

  void _toggleEdit() {
    if (_editable) {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Assurez vous que tous les champs soient valides")));

        return;
      }

      _formKey.currentState!.save();
      EnterprisesProvider provider = context.read<EnterprisesProvider>();

      Enterprise enterprise = provider[widget.enterpriseId].copyWith(
        name: _name!,
        neq: _neq!,
        activityTypes: _activityTypes,
        recrutedBy: _recrutedBy,
        shareToOthers: _shareToOthers,
      );

      provider.replace(enterprise);
    }

    setState(() => _editable = !_editable);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Selector<EnterprisesProvider, Enterprise>(
            builder: (context, enterprise, child) => Scaffold(
                  appBar: AppBar(title: Text(enterprise.name)),
                  body: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Informations générales",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          ListTile(
                            title: TextFormField(
                              initialValue: enterprise.name,
                              enabled: _editable,
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
                              initialValue: enterprise.neq,
                              enabled: _editable,
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
                          IndexedStack(index: _editable ? 1 : 0, children: [
                            Column(
                              children: [
                                ListTile(
                                  title: const Text("Types d'activités"),
                                  trailing: Text(
                                    enterprise.activityTypes.join(", "),
                                    maxLines: 1,
                                  ),
                                ),
                                ListTile(
                                    title: Text(
                                        "L'enterprise a été recrutée par ${enterprise.recrutedBy}")),
                                ListTile(
                                  title: enterprise.shareToOthers
                                      ? const Text("L'enterprise est partagée")
                                      : const Text(
                                          "L'entreprise n'est pas partagée"),
                                ),
                              ],
                            ),
                            Column(children: [
                              ListTile(
                                  title: const Text("Types d'activités"),
                                  subtitle: Text(
                                    _activityTypes.join(", "),
                                    maxLines: 1,
                                  ),
                                  trailing: TextButton(
                                    child: const Text("Modifier"),
                                    onPressed: () =>
                                        _showActivityTypeSelector(),
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
                            ])
                          ])
                        ]),
                      ),
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: _toggleEdit,
                    child: _editable
                        ? const Icon(Icons.save_rounded)
                        : const Icon(Icons.edit),
                  ),
                ),
            selector: (context, enterprises) =>
                enterprises[widget.enterpriseId]));
  }
}

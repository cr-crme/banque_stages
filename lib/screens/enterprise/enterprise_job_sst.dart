import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/confirm_pop_dialog.dart';

class EnterpriseJobSST extends StatefulWidget {
  const EnterpriseJobSST({Key? key, required this.enterpriseId})
      : super(key: key);

  static const String route = "jobSST";

  final String enterpriseId;

  @override
  State<EnterpriseJobSST> createState() => _EnterpriseJobSSTState();
}

class _EnterpriseJobSSTState extends State<EnterpriseJobSST> {
  late String jobId = ModalRoute.of(context)!.settings.arguments as String;

  final _formKey = GlobalKey<FormState>();

  bool _editable = false;

  String? _dangerousSituations;
  String? _protectionEquipements;
  String? _accidentsHistory;
  String? _stressSituations;

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

      provider[widget.enterpriseId].jobs.replace(provider[widget.enterpriseId]
          .jobs[jobId]
          .copyWith(
              dangerousSituations: _dangerousSituations,
              protectionEquipements: _protectionEquipements,
              accidentsHistory: _accidentsHistory,
              stressSituations: _stressSituations));
    }

    setState(() => _editable = !_editable);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Selector<EnterprisesProvider, Enterprise>(
            builder: (context, enterprise, child) => Form(
                    child: Scaffold(
                  appBar: AppBar(title: Text(enterprise.name)),
                  body: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  enterprise.jobs[jobId].specialization
                                      .toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Santé et Sécurité du travail (SST)",
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ),
                            const ListTile(
                                title: Text(
                                    "Avez-vous identifié des situations de travail dangereuses lors de vos visites de supervision dans cette entreprise ? Si oui, lesquelles?")),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: TextFormField(
                                initialValue:
                                    enterprise.jobs[jobId].dangerousSituations,
                                onSaved: (dangerousSituations) =>
                                    _dangerousSituations = dangerousSituations,
                                enabled: _editable,
                                keyboardType: TextInputType.multiline,
                                minLines: 4,
                                maxLines: null,
                              ),
                            ),
                            const ListTile(
                                title: Text(
                                    "Équipements de protection individuelle requis")),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: TextFormField(
                                initialValue: enterprise
                                    .jobs[jobId].protectionEquipements,
                                onSaved: (protectionEquipements) =>
                                    _protectionEquipements =
                                        protectionEquipements,
                                enabled: _editable,
                                keyboardType: TextInputType.multiline,
                                minLines: 4,
                                maxLines: null,
                              ),
                            ),
                            const ListTile(
                                title: Text(
                                    "Est-ce qu’il y a déjà eu des accidents de stagiaire (il peut s’agir d’une blesssure mineure comme une coupure ou une brûlure)? Si oui, racontez ce qu’il s’est passé")),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: TextFormField(
                                initialValue:
                                    enterprise.jobs[jobId].accidentsHistory,
                                onSaved: (accidentsHistory) =>
                                    _accidentsHistory = accidentsHistory,
                                enabled: _editable,
                                keyboardType: TextInputType.multiline,
                                minLines: 4,
                                maxLines: null,
                              ),
                            ),
                            const ListTile(
                                title: Text(
                                    "Est-ce que des stagiaires ont déjà fait face à des situations source de stress ou de violence dans cette entreprise? (p. ex. harcèlement de la part de collègues, violence verbale de clients...)")),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: TextFormField(
                                initialValue:
                                    enterprise.jobs[jobId].stressSituations,
                                onSaved: (stressSituations) =>
                                    _stressSituations = stressSituations,
                                enabled: _editable,
                                keyboardType: TextInputType.multiline,
                                minLines: 4,
                                maxLines: null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: _toggleEdit,
                    child: _editable
                        ? const Icon(Icons.save_rounded)
                        : const Icon(Icons.edit),
                  ),
                )),
            selector: (context, enterprises) =>
                enterprises[widget.enterpriseId]));
  }
}

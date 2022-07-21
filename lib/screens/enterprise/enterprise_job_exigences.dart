import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/confirm_pop_dialog.dart';

class EnterpriseJobExigences extends StatefulWidget {
  const EnterpriseJobExigences({Key? key, required this.enterpriseId})
      : super(key: key);

  static const String route = "jobExigences";

  final String enterpriseId;

  @override
  State<EnterpriseJobExigences> createState() => _EnterpriseJobExigencesState();
}

class _EnterpriseJobExigencesState extends State<EnterpriseJobExigences> {
  late String jobId = ModalRoute.of(context)!.settings.arguments as String;

  final _formKey = GlobalKey<FormState>();

  bool _editable = false;

  int? _minimumAge;
  String? _uniform;
  String? _expectations;
  String? _supervision;
  String? _comments;

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
              minimumAge: _minimumAge,
              uniform: _uniform,
              expectations: _expectations,
              supervision: _supervision,
              comments: _comments));
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
                    appBar: AppBar(
                      title: Text(enterprise.name),
                      actions: [
                        IconButton(
                          onPressed: _toggleEdit,
                          icon: _editable
                              ? const Icon(Icons.save_rounded)
                              : const Icon(Icons.edit),
                        ),
                      ],
                    ),
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
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Exigences",
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                              ),
                              const ListTile(title: Text("Âge minimum")),
                              const ListTile(
                                  title: Text("Tenue vestimentaire requise")),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: TextFormField(
                                  initialValue: enterprise.jobs[jobId].uniform,
                                  onSaved: (uniform) => _uniform = uniform,
                                  enabled: _editable,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 4,
                                  maxLines: null,
                                ),
                              ),
                              const ListTile(
                                  title: Text(
                                      "Attentes envers les stagiaires (autonomie, productivité...)")),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: TextFormField(
                                  initialValue:
                                      enterprise.jobs[jobId].expectations,
                                  onSaved: (expectations) =>
                                      _expectations = expectations,
                                  enabled: _editable,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 4,
                                  maxLines: null,
                                ),
                              ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Type d’encadrement des stagiaires",
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: TextFormField(
                                  initialValue:
                                      enterprise.jobs[jobId].supervision,
                                  onSaved: (supervision) =>
                                      _supervision = supervision,
                                  enabled: _editable,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 4,
                                  maxLines: null,
                                ),
                              ),
                              const Divider(),
                              Text("Autres commentaires",
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: TextFormField(
                                  initialValue: enterprise.jobs[jobId].comments,
                                  onSaved: (comments) => _comments = comments,
                                  enabled: _editable,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 4,
                                  maxLines: null,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            selector: (context, enterprises) =>
                enterprises[widget.enterpriseId]));
  }
}

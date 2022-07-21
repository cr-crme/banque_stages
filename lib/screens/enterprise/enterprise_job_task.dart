import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/confirm_pop_dialog.dart';

class EnterpriseJobTask extends StatefulWidget {
  const EnterpriseJobTask({Key? key, required this.enterpriseId})
      : super(key: key);

  static const String route = "jobTask";

  final String enterpriseId;

  @override
  State<EnterpriseJobTask> createState() => _EnterpriseJobTaskState();
}

class _EnterpriseJobTaskState extends State<EnterpriseJobTask> {
  late String jobId = ModalRoute.of(context)!.settings.arguments as String;

  final _formKey = GlobalKey<FormState>();

  bool _editable = false;

  String? _principalTask;

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
          .copyWith(principalTask: _principalTask));
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
                                child: Text("Tâches principales",
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: TextFormField(
                                  initialValue:
                                      enterprise.jobs[jobId].principalTask,
                                  enabled: _editable,
                                  onSaved: (principalTask) =>
                                      _principalTask = principalTask,
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

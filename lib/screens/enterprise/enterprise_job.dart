import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/confirm_pop_dialog.dart';

class EnterpriseJob extends StatefulWidget {
  const EnterpriseJob({Key? key, required this.enterpriseId}) : super(key: key);

  static const String route = "jobTask";

  final String enterpriseId;

  @override
  State<EnterpriseJob> createState() => _EnterpriseJobState();
}

class _EnterpriseJobState extends State<EnterpriseJob> {
  late String jobId = ModalRoute.of(context)!.settings.arguments as String;

  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;

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
            builder: (context, enterprise, child) => PageView(
                  onPageChanged: (value) =>
                      setState(() => _currentPage = value),
                  children: [],
                ),
            selector: (context, enterprises) =>
                enterprises[widget.enterpriseId]));
  }
}

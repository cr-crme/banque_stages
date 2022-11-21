import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/activity_type_cards.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
import '/common/widgets/disponibility_circle.dart';
import '/common/widgets/form_fields/activity_types_picker_form_field.dart';
import '/common/widgets/form_fields/share_with_picker_form_field.dart';
import '/misc/form_service.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({
    super.key,
    required this.enterprise,
  });

  final Enterprise enterprise;

  @override
  State<AboutPage> createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
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

    if (!FormService.validateForm(_formKey)) {
      return;
    }

    _formKey.currentState!.save();

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
              ListTile(
                title: Text(
                  "Informations générales",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      width: 140,
                      height: 105,
                      color: Theme.of(context).disabledColor,
                      child: widget.enterprise.photo.isNotEmpty
                          ? Image.network(widget.enterprise.photo)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: TextEditingController(
                                text: widget.enterprise.name),
                            decoration: const InputDecoration(
                              labelText: "Nom de l'entreprise",
                            ),
                            enabled: _editing,
                            onSaved: (name) => _name = name,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Entreprise recrutée par :",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            widget.enterprise.recrutedBy,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(
                  "Places de stage disponibles",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: widget.enterprise.jobs
                      .map(
                        (job) => ListTile(
                          visualDensity: VisualDensity.compact,
                          leading: DisponibilityCircle(
                            positionsOffered: job.positionsOffered,
                            positionsOccupied: job.positionsOccupied,
                          ),
                          title:
                              Text(job.specialization?.idWithName ?? "bad id"),
                          trailing: Text(
                              "${job.positionsOffered - job.positionsOccupied} / ${job.positionsOffered}"),
                        ),
                      )
                      .toList(),
                ),
              ),
              ListTile(
                title: Text(
                  "Types d'activités",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Visibility(
                      visible: !_editing,
                      child: ActivityTypeCards(
                          activityTypes: widget.enterprise.activityTypes),
                    ),
                    Visibility(
                      visible: _editing,
                      child: ActivityTypesPickerFormField(
                        initialValue: widget.enterprise.activityTypes,
                        onSaved: (activityTypes) =>
                            _activityTypes = activityTypes!,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(
                  "Partage de l'entreprise",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Visibility(
                      visible: !_editing,
                      child: Text(
                        widget.enterprise.shareWith,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Visibility(
                      visible: _editing,
                      child: ShareWithPickerFormField(
                        initialValue: widget.enterprise.shareWith,
                        onSaved: (shareWith) => _shareWith = shareWith,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

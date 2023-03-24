import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import '/common/models/job.dart';
import '/misc/job_data_file_service.dart';

class JobFormFieldListTile extends StatefulWidget {
  const JobFormFieldListTile({
    super.key,
    this.initialValue,
    this.onSaved,
    this.sectors,
    this.specializations,
    this.askNumberPositionsOffered = true,
  });

  final Job? initialValue;
  final FormFieldSetter<Job>? onSaved;
  final List<ActivitySector>? sectors;
  final List<Specialization>? specializations;
  final bool askNumberPositionsOffered;

  @override
  State<JobFormFieldListTile> createState() => _JobFormFieldListTileState();
}

class _JobFormFieldListTileState extends State<JobFormFieldListTile> {
  ActivitySector? _activitySector;
  Specialization? _specialization;
  int _positionOffered = 0;
  static const String _invalidActivitySector = 'invalid_activitySector';
  static const String _invalidSpecialization = 'invalid_specialization';

  String? _validator() {
    if (_activitySector == null) {
      return _invalidActivitySector;
    }
    if (_specialization == null) {
      return _invalidSpecialization;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Job>(
      onSaved: (_) => widget.onSaved != null
          ? widget.onSaved!(Job(
              specialization: _specialization!,
              positionsOffered: _positionOffered))
          : null,
      validator: (_) => _validator(),
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Autocomplete<ActivitySector>(
            displayStringForOption: (s) => s.idWithName,
            optionsBuilder: (textEditingValue) => ActivitySectorsService.sectors
                .whereId(id: textEditingValue.text),
            onSelected: (sector) => setState(() {
              _activitySector = sector;
              _specialization = null;
            }),
            fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
              return ListTile(
                title: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onSubmitted: (_) => onSubmitted(),
                  onChanged: (_) => setState(() {
                    _activitySector = null;
                    _specialization = null;
                  }),
                  decoration: InputDecoration(
                    labelText: '* Secteur d\'activités',
                    errorText: state.errorText == _invalidActivitySector
                        ? 'Entrez une valeur valide'
                        : null,
                  ),
                ),
              );
            },
          ),
          Autocomplete<Specialization>(
            displayStringForOption: (s) => s.idWithName,
            optionsBuilder: (textEditingValue) => _activitySector != null
                ? _activitySector!.specializations
                    .where((s) => s.idWithName.contains(textEditingValue.text))
                    .toList()
                : [],
            onSelected: (specilization) =>
                setState(() => _specialization = specilization),
            fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
              if (_specialization == null) {
                controller.text = '';
              }
              return ListTile(
                title: TextField(
                  enabled: _activitySector != null,
                  controller: controller,
                  focusNode: focusNode,
                  onSubmitted: (_) => onSubmitted(),
                  onChanged: (_) => setState(() => _specialization = null),
                  decoration: InputDecoration(
                    labelText: '* Métier semi-spécialisé',
                    errorText: state.errorText == _invalidSpecialization
                        ? 'Entrez une valeur valide'
                        : null,
                  ),
                ),
              );
            },
          ),
          if (widget.askNumberPositionsOffered)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Postes disponibles',
                    style: Theme.of(state.context).textTheme.titleMedium,
                  ),
                ),
                SizedBox(
                  width: 112,
                  child: SpinBox(
                    value: state.value?.positionsOffered.toDouble() ?? 0,
                    min: 1,
                    max: 10,
                    spacing: 0,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (double value) =>
                        _positionOffered = value.toInt(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

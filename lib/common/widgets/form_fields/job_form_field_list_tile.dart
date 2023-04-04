import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import '/common/models/job.dart';
import '/misc/job_data_file_service.dart';

class JobFormFieldListTile extends StatefulWidget {
  const JobFormFieldListTile({
    super.key,
    this.initialValue,
    this.onSaved,
    this.specializations,
    this.askNumberPositionsOffered = true,
  });

  final Job? initialValue;
  final FormFieldSetter<Job>? onSaved;
  final Map<Specialization, int>?
      specializations; // Specialization and number of position for each
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
  static const String _invalidNumber = 'invalid_number';

  String? _validator() {
    if (_activitySector == null) {
      return _invalidActivitySector;
    }
    if (_specialization == null) {
      return _invalidSpecialization;
    }
    if (widget.askNumberPositionsOffered && _positionOffered == 0) {
      return _invalidNumber;
    }
    return null;
  }

  List<ActivitySector> get _availableSectors {
    if (widget.specializations == null) {
      return ActivitySectorsService.sectors.toList();
    }

    final List<ActivitySector> out = [];
    for (final specialization in widget.specializations!.keys) {
      out.add(specialization.sector);
    }
    return out;
  }

  List<Specialization> get _availableSpecialization {
    if (widget.specializations == null) {
      return _activitySector!.specializations.toList();
    }

    return widget.specializations!.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Job>(
      onSaved: _specialization == null ||
              (widget.askNumberPositionsOffered && _positionOffered == 0)
          ? null
          : (_) => widget.onSaved != null
              ? widget.onSaved!(Job(
                  specialization: _specialization!,
                  positionsOffered: _positionOffered))
              : null,
      validator: (_) => _validator(),
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Autocomplete<ActivitySector>(
            displayStringForOption: (sector) => sector.idWithName,
            optionsBuilder: (textEditingValue) => _availableSectors.where(
                (sector) => sector.idWithName.contains(textEditingValue.text)),
            onSelected: (sector) => setState(() {
              _activitySector = sector;
              _specialization = null;
            }),
            fieldViewBuilder: (_, controller, focusNode, onSubmitted) =>
                ListTile(
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
                    hintText: 'Saisir nom ou n° de secteur',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => controller.text = '',
                    )),
              ),
            ),
          ),
          Autocomplete<Specialization>(
            displayStringForOption: (specialization) {
              final available = widget.specializations == null
                  ? null
                  : widget.specializations![specialization];
              return '${specialization.idWithName}'
                  '${available == null ? '' : '\n($available stage${available > 1 ? 's' : ''} disponible${available > 1 ? 's' : ''})'}';
            },
            optionsBuilder: (textEditingValue) => _activitySector != null
                ? _availableSpecialization
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
                      hintText: 'Saisir nom ou n° de métier',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => controller.text = '',
                      )),
                ),
              );
            },
          ),
          if (widget.askNumberPositionsOffered)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Places de stages disponibles',
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
                    validator: (value) =>
                        int.parse(value!) == 0 ? 'Indiquer un nombre' : null,
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

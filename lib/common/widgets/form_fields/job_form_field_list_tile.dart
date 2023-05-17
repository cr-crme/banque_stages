import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/widgets/autocomplete_options_builder.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';

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
  final _sectorTextController = TextEditingController();
  Specialization? _specialization;
  int _positionOffered = 0;
  static const String _invalidSpecialization = 'invalid_specialization';
  static const String _invalidNumber = 'invalid_number';

  String? _validator() {
    if (_specialization == null) {
      return _invalidSpecialization;
    }
    if (widget.askNumberPositionsOffered && _positionOffered == 0) {
      return _invalidNumber;
    }
    return null;
  }

  List<Specialization> get _availableSpecialization {
    if (widget.specializations == null) {
      final out = ActivitySectorsService.allSpecializations;
      out.sort((a, b) => a.name.compareTo(b.name));
      return out;
    }

    return widget.specializations!.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Job>(
      onSaved: (_) {
        if (widget.onSaved == null ||
            _specialization == null ||
            (widget.askNumberPositionsOffered && _positionOffered == 0)) {
          return;
        }
        widget.onSaved!(Job(
            specialization: _specialization!,
            positionsOffered: _positionOffered));
      },
      validator: (_) => _validator(),
      builder: (state) => Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Autocomplete<Specialization>(
              displayStringForOption: (specialization) {
                final available = widget.specializations == null
                    ? null
                    : widget.specializations![specialization];
                return '${specialization.idWithName}'
                    '${available == null ? '' : '\n($available stage${available > 1 ? 's' : ''} disponible${available > 1 ? 's' : ''})'}';
              },
              optionsBuilder: (textEditingValue) => _availableSpecialization
                  .where((s) => s.idWithName
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()))
                  .toList(),
              optionsViewBuilder: (context, onSelected, options) =>
                  OptionsBuilderForAutocomplete(
                onSelected: onSelected,
                options: options,
                optionToString: (Specialization e) => e.idWithName,
              ),
              onSelected: (specilization) {
                FocusManager.instance.primaryFocus?.unfocus();
                _specialization = specilization;
                _sectorTextController.text = _specialization!.sector.idWithName;
                setState(() {});
              },
              fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
                if (_specialization == null) {
                  controller.text = '';
                }
                if (_availableSpecialization.length == 1) {
                  _specialization = _availableSpecialization[0];
                  controller.text = _specialization!.idWithName;
                  _sectorTextController.text =
                      _specialization!.sector.idWithName;
                }
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onSubmitted: (_) => onSubmitted(),
                  decoration: InputDecoration(
                      labelText: '* Métier semi-spécialisé',
                      errorText: state.errorText == _invalidSpecialization
                          ? 'Sélectionner un métier.'
                          : null,
                      hintText: 'Saisir nom ou n° de métier',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.text = '';
                          _sectorTextController.text = '';
                        },
                      )),
                );
              },
            ),
            TextField(
                controller: _sectorTextController,
                decoration: const InputDecoration(
                  labelText: '* Secteur d\'activités',
                  enabled: false,
                )),
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
                          int.parse(value!) == 0 ? 'Indiquer un nombre.' : null,
                      onChanged: (double value) =>
                          _positionOffered = value.toInt(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

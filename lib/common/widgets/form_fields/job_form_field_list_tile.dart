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
  State<JobFormFieldListTile> createState() => JobFormFieldListTileState();
}

class JobFormFieldListTileState extends State<JobFormFieldListTile> {
  final _textKey = GlobalKey<FormState>();
  bool _isValidating = false;
  final _sectorTextController = TextEditingController();
  Specialization? _specialization;
  int _positionOffered = 0;
  static const String _invalidSpecialization = 'invalid_specialization';
  static const String _invalidNumber = 'invalid_number';

  String? validator() {
    _textKey.currentState?.validate();
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
          positionsOffered: _positionOffered,
          // TODO Aurelie - Should we really add incident contact at that moment?
          sstEvaluation: JobSstEvaluation.empty(incidentContact: ''),
        ));
      },
      validator: (_) => validator(),
      builder: (state) => Column(
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
                    .contains(textEditingValue.text.toLowerCase().trim()))
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
                if (controller.text != '') state.didChange(null);
                controller.text = '';
              }
              if (_availableSpecialization.length == 1) {
                _specialization = _availableSpecialization[0];
                controller.text = _specialization!.idWithName;
                _sectorTextController.text = _specialization!.sector.idWithName;
              }
              return TextFormField(
                key: _textKey,
                controller: controller,
                focusNode: focusNode,
                validator: (value) {
                  _isValidating = true;
                  return value!.isEmpty ? 'Sélectionner un métier' : null;
                },
                decoration: InputDecoration(
                    labelText: '* Métier semi-spécialisé',
                    errorText: state.errorText == _invalidSpecialization
                        ? 'Sélectionner un métier.'
                        : null,
                    hintText: 'Saisir nom ou n° de métier',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        if (focusNode.hasFocus) focusNode.nextFocus();

                        state.didChange(null);
                        controller.text = '';
                        _specialization = null;
                        _sectorTextController.text = '';
                      },
                    )),
              );
            },
          ),
          if (widget.askNumberPositionsOffered)
            Row(
              children: [
                Expanded(
                  child: Text(
                    '* Places de stages disponibles',
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
                    validator: (value) {
                      final out = _isValidating && int.parse(value!) == 0
                          ? 'Combien?'
                          : null;
                      _isValidating = false;
                      return out;
                    },
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

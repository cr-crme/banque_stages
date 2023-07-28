import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/models/pre_internship_request.dart';
import 'package:crcrme_banque_stages/common/models/protections.dart';
import 'package:crcrme_banque_stages/common/models/uniform.dart';
import 'package:crcrme_banque_stages/common/widgets/autocomplete_options_builder.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/checkbox_with_other.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/radio_with_precision.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

class JobFormFieldListTile extends StatefulWidget {
  const JobFormFieldListTile({
    super.key,
    this.initialValue,
    this.onSaved,
    this.specializations,
    this.specializationOnly = false,
  });

  final Job? initialValue;
  final FormFieldSetter<Job>? onSaved;
  final Map<Specialization, int>?
      specializations; // Specialization and number of position for each
  final bool specializationOnly;

  @override
  State<JobFormFieldListTile> createState() => JobFormFieldListTileState();
}

class JobFormFieldListTileState extends State<JobFormFieldListTile> {
  final _textKey = GlobalKey<FormState>();
  final _preInternshipRequestKey =
      GlobalKey<CheckboxWithOtherState<PreInternshipRequestType>>();
  final _uniformKey = GlobalKey<RadioWithChildState<UniformStatus>>();
  final _protectionsKey = GlobalKey<RadioWithChildState<ProtectionsStatus>>();
  final _protectionsTypeKey =
      GlobalKey<CheckboxWithOtherState<ProtectionsType>>();
  final _uniformTextController = TextEditingController();

  bool _isValidating = false;
  final _sectorTextController = TextEditingController();
  Specialization? _specialization;
  int _positionOffered = 0;
  static const String _invalidSpecialization = 'invalid_specialization';
  static const String _invalidNumber = 'invalid_number';

  int _minimalAge = -1;

  String? validator() {
    _textKey.currentState?.validate();
    if (_specialization == null) {
      return _invalidSpecialization;
    }
    if (widget.specializationOnly) return null;

    if (_positionOffered == 0) {
      return _invalidNumber;
    }

    if (_uniformKey.currentState!.value == null) return 'invalid_radio_choice';

    if (_protectionsKey.currentState!.hasOther &&
        _protectionsTypeKey.currentState!.values.isEmpty) {
      return 'invalid_protections_choice';
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
        if (widget.specializationOnly) return;
        if (widget.onSaved == null || _specialization == null) return;
        if (validator() != null) return;

        final preInternshipRequest = PreInternshipRequest(
            requests: _preInternshipRequestKey.currentState!.values
                .map<String>((e) => e.toString())
                .toList());
        final uniform = Uniform(
            status: _uniformKey.currentState!.value!,
            uniform: _uniformTextController.text);
        final protections = Protections(
            status: _protectionsKey.currentState!.value!,
            protections: _protectionsTypeKey.currentState!.values);

        widget.onSaved!(Job(
          specialization: _specialization!,
          positionsOffered: _positionOffered,
          minimumAge: _minimalAge,
          preInternshipRequest: preInternshipRequest,
          uniform: uniform,
          protections: protections,
          sstEvaluation: JobSstEvaluation.empty(incidentContact: ''),
        ));
      },
      validator: (_) => validator(),
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildJobPicker(state),
          if (!widget.specializationOnly)
            Column(
              children: [
                _buildAvailability(state),
                _buildMinimumAge(),
                const SizedBox(height: 8),
                _buildPrerequisite(),
                const SizedBox(height: 8),
                _buildUniform(),
                const SizedBox(height: 8),
                _buildProtections(),
              ],
            ),
        ],
      ),
    );
  }

  Row _buildAvailability(FormFieldState<Job> state) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '* Places de stages disponibles',
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
              border: InputBorder.none,
            ),
            validator: (value) {
              final out =
                  _isValidating && int.parse(value!) == 0 ? 'Combien?' : null;
              _isValidating = false;
              return out;
            },
            onChanged: (double value) => _positionOffered = value.toInt(),
          ),
        ),
      ],
    );
  }

  Autocomplete<Specialization> _buildJobPicker(FormFieldState<Job> state) {
    return Autocomplete<Specialization>(
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
    );
  }

  Widget _buildMinimumAge() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(child: Text('* Âge minimum des stagiaires (ans)')),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.24,
          child: TextFormField(
            validator: (value) {
              final current = int.tryParse(value!);
              if (current == null) return 'Préciser';
              if (current < 10 || current > 30) return 'Entre 10 et 30';
              return null;
            },
            keyboardType: TextInputType.number,
            onSaved: (value) => _minimalAge = int.tryParse(value!) ?? -1,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("[0-9]")),
            ], // Only numbers can be entered
          ),
        ),
      ],
    );
  }

  Widget _buildPrerequisite() {
    return CheckboxWithOther<PreInternshipRequestType>(
      key: _preInternshipRequestKey,
      title:
          '* Exigences de l\'entreprise avant d\'accueillir des élèves en stage:',
      elements: PreInternshipRequestType.values,
    );
  }

  Widget _buildUniform() {
    return RadioWithChild<UniformStatus>(
      key: _uniformKey,
      title:
          '* Exigences de l\'entreprise avant d\'accueillir des élèves en stage:',
      elements: UniformStatus.values,
      elementsThatShowChild: const [
        UniformStatus.suppliedByEnterprise,
        UniformStatus.suppliedByStudent
      ],
      child: Padding(
        padding: const EdgeInsets.only(left: 32.0, right: 8, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Décrire la tenue exigée par l\'entreprise ou les '
              'règles d\'habillement\u00a0',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextFormField(
              controller: _uniformTextController,
              minLines: 1,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              validator: (value) =>
                  value == null || !RegExp('[a-zA-Z0-9]').hasMatch(value)
                      ? 'Décrire la tenue de travail.'
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtections() {
    return RadioWithChild<ProtectionsStatus>(
      key: _protectionsKey,
      title: '*Est-ce que l\'élève devra porter des équipements de protection '
          'individuelle (EPI) pour faire ce métier\u00a0?',
      elements: ProtectionsStatus.values,
      elementsThatShowChild: const [
        ProtectionsStatus.suppliedByEnterprise,
        ProtectionsStatus.suppliedBySchool
      ],
      child: CheckboxWithOther<ProtectionsType>(
        key: _protectionsTypeKey,
        title: 'Lesquels\u00a0:',
        elements: ProtectionsType.values,
      ),
    );
  }
}

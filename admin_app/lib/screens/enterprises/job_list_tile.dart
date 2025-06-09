import 'package:admin_app/widgets/radio_with_follow_up.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:common_flutter/widgets/animated_expanding_card.dart';
import 'package:common_flutter/widgets/autocomplete_options_builder.dart';
import 'package:common_flutter/widgets/checkbox_with_other.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JobListController {
  late Specialization? _specialization = _job.specializationOrNull;
  late final _minimumAgeController = TextEditingController(
    text: _job.minimumAge.toString(),
  );
  late int _positionsOffered = _job.positionsOffered;
  int _positionsOccupied = 0;

  final _preInternshipRequestKey =
      GlobalKey<CheckboxWithOtherState<PreInternshipRequestTypes>>();
  final _uniformFormKey = GlobalKey<RadioWithFollowUpState<UniformStatus>>();
  late final _uniformTextController = TextEditingController(
    text: _job.uniforms.uniforms.join('\n '),
  );
  final _protectionsKey =
      GlobalKey<RadioWithFollowUpState<ProtectionsStatus>>();
  final _protectionsTextController =
      GlobalKey<CheckboxWithOtherState<ProtectionsType>>();

  final Job _job;
  JobListController({required Job job}) : _job = job.copyWith();

  Job get job => _job.copyWith(
    specialization: _specialization,
    minimumAge: int.tryParse(_minimumAgeController.text),
    positionsOffered: _positionsOffered,
    preInternshipRequests: PreInternshipRequests.fromStrings(
      _preInternshipRequestKey.currentState?.values ?? [],
      id: _job.preInternshipRequests.id,
    ),
    uniforms: _job.uniforms.copyWith(
      status: _uniformFormKey.currentState?.value,
      uniforms: _uniformTextController.text.split('\n'),
    ),
    protections: _job.protections.copyWith(
      status: _protectionsKey.currentState?.value,
      protections: _protectionsTextController.currentState?.values,
    ),
  );

  void dispose() {
    _minimumAgeController.dispose();
    _uniformTextController.dispose();
  }
}

class JobListTile extends StatefulWidget {
  const JobListTile({
    super.key,
    required this.controller,
    required this.editMode,
    required this.onRequestDelete,
  });

  final JobListController controller;
  final bool editMode;
  final Function() onRequestDelete;

  @override
  State<JobListTile> createState() => _JobListTileState();
}

class _JobListTileState extends State<JobListTile> {
  Job get job => widget.controller._job;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final internships = InternshipsProvider.of(context, listen: true);
    widget.controller._positionsOffered = job.positionsOffered;
    widget.controller._positionsOccupied = internships.fold(
      0,
      (sum, e) => e.jobId == job.id && e.isActive ? sum + 1 : sum,
    );
  }

  void _updatePositions(int newCount) {
    setState(() => widget.controller._positionsOffered = newCount);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedExpandingCard(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.controller._specialization?.idWithName ??
                    'Aucune spécialisation',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          if (widget.editMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: widget.onRequestDelete,
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 12.0, right: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.editMode) _buildJobPicker(),
            const SizedBox(height: 8),
            _buildMinimumAge(),
            const SizedBox(height: 8),
            _buildAvailability(),
            const SizedBox(height: 8),
            _buildPrerequisites(),
            const SizedBox(height: 8),
            _buildUniform(),
            const SizedBox(height: 8),
            _buildProtections(),
          ],
        ),
      ),
    );
  }

  List<Specialization> get _availableSpecialization {
    // Make a copy of the available specializations
    List<Specialization> out = [...ActivitySectorsService.allSpecializations];
    out.sort((a, b) => a.name.compareTo(b.name)); // Sort them by name
    return out;
  }

  Autocomplete<Specialization> _buildJobPicker() {
    return Autocomplete<Specialization>(
      displayStringForOption: (specialization) => specialization.idWithName,
      optionsBuilder:
          (textEditingValue) =>
              _availableSpecialization
                  .where(
                    (s) => s.idWithName.toLowerCase().contains(
                      textEditingValue.text.toLowerCase().trim(),
                    ),
                  )
                  .toList(),
      optionsViewBuilder:
          (context, onSelected, options) => OptionsBuilderForAutocomplete(
            onSelected: onSelected,
            options: options,
            optionToString: (Specialization e) => e.idWithName,
          ),
      onSelected: (specialization) {
        FocusManager.instance.primaryFocus?.unfocus();
        widget.controller._specialization = specialization;
        setState(() {});
      },
      initialValue: TextEditingValue(
        text: widget.controller._specialization?.idWithName ?? '',
      ),
      fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
        if (_availableSpecialization.length == 1) {
          widget.controller._specialization = _availableSpecialization[0];
          controller.text = widget.controller._specialization!.idWithName;
        }
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: (value) {
            return widget.controller._specialization == null
                ? 'Sélectionner un métier.'
                : null;
          },
          enabled: _availableSpecialization.length != 1,
          decoration: InputDecoration(
            labelText: '* Métier semi-spécialisé',
            hintText: 'Saisir nom ou n° de métier',
            suffixIcon:
                _availableSpecialization.length == 1
                    ? null
                    : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        if (focusNode.hasFocus) focusNode.nextFocus();
                        widget.controller._specialization = null;
                        controller.clear();
                      },
                    ),
          ),
        );
      },
    );
  }

  Widget _buildMinimumAge() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text('* Âge minimum des stagiaires (ans)')),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.24,
          height: 25,
          child: TextFormField(
            controller: widget.controller._minimumAgeController,
            enabled: widget.editMode,
            validator: (value) {
              final current = int.tryParse(value!);
              if (current == null) return 'Préciser';
              if (current < 10 || current > 30) return 'Entre 10 et 30';
              return null;
            },
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailability() {
    final positionsRemaining =
        widget.controller._positionsOffered -
        widget.controller._positionsOccupied;
    // TODO Add a close the internship for all the schools
    // TODO Bring this into the header and add schools
    // TODO Add a toggle to make the specialization private or public
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Places disponibles'),
        widget.editMode
            ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed:
                      widget.controller._positionsOffered == 0
                          ? null
                          : () => _updatePositions(
                            widget.controller._positionsOffered - 1,
                          ),
                  icon: Icon(
                    Icons.remove,
                    color: positionsRemaining == 0 ? Colors.grey : Colors.black,
                  ),
                ),
                Text(
                  '$positionsRemaining / ${widget.controller._positionsOffered}',
                ),
                IconButton(
                  onPressed:
                      () => _updatePositions(
                        widget.controller._positionsOffered + 1,
                      ),
                  icon: const Icon(Icons.add, color: Colors.black),
                ),
              ],
            )
            : Text(
              '$positionsRemaining / ${widget.controller._positionsOffered}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
      ],
    );
  }

  Widget _buildPrerequisites() {
    return _BuildPrerequisitesCheckboxes(
      checkBoxKey: widget.controller._preInternshipRequestKey,
      enabled: widget.editMode,
      initialValues: [
        ...job.preInternshipRequests.requests.map((e) => e.toString()),
        job.preInternshipRequests.other ?? '',
      ],
    );
  }

  Widget _buildUniform() {
    return _BuildUniformRadio(
      uniformKey: widget.controller._uniformFormKey,
      uniformTextController: widget.controller._uniformTextController,
      initialSelection: job.uniforms.status,
      enabled: widget.editMode,
    );
  }

  Widget _buildProtections() {
    return _BuildProtectionsRadio(
      protectionsKey: widget.controller._protectionsKey,
      protectionsTypeKey: widget.controller._protectionsTextController,
      initialSelection: job.protections.status,
      initialItems:
          job.protections.protections.map((e) => e.toString()).toList(),
      enabled: widget.editMode,
    );
  }
}

class _BuildPrerequisitesCheckboxes extends StatelessWidget {
  const _BuildPrerequisitesCheckboxes({
    required this.checkBoxKey,
    required this.initialValues,
    required this.enabled,
  });

  final GlobalKey<CheckboxWithOtherState<PreInternshipRequestTypes>>
  checkBoxKey;
  final List<String>? initialValues;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return CheckboxWithOther<PreInternshipRequestTypes>(
      key: checkBoxKey,
      title:
          'Exigences de l\'entreprise avant d\'accueillir des élèves en stage:',
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      enabled: enabled,
      elements: PreInternshipRequestTypes.values,
      initialValues: initialValues,
    );
  }
}

class _BuildUniformRadio extends StatelessWidget {
  const _BuildUniformRadio({
    required this.uniformKey,
    required this.uniformTextController,
    this.initialSelection,
    required this.enabled,
  });

  final GlobalKey<RadioWithFollowUpState<UniformStatus>> uniformKey;
  final TextEditingController uniformTextController;
  final UniformStatus? initialSelection;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RadioWithFollowUp<UniformStatus>(
      key: uniformKey,
      title:
          'Est-ce qu\'une tenue de travail spécifique est exigée pour '
          'ce poste\u00a0?',
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      elements: UniformStatus.values,
      elementsThatShowChild: const [
        UniformStatus.suppliedByEnterprise,
        UniformStatus.suppliedByStudent,
      ],
      enabled: enabled,
      initialValue: initialSelection,
      followUpChild: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 8,
          top: 4,
          bottom: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Décrire la tenue exigée par l\'entreprise ou les '
              'règles d\'habillement\u00a0:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextFormField(
              controller: uniformTextController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              enabled: enabled,
              minLines: 1,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(color: Colors.black),
              validator:
                  (value) =>
                      value == null || !RegExp('[a-zA-Z0-9]').hasMatch(value)
                          ? 'Décrire la tenue de travail.'
                          : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildProtectionsRadio extends StatelessWidget {
  const _BuildProtectionsRadio({
    required this.protectionsKey,
    required this.protectionsTypeKey,
    this.initialSelection,
    this.initialItems,
    required this.enabled,
  });

  final GlobalKey<RadioWithFollowUpState<ProtectionsStatus>> protectionsKey;
  final GlobalKey<CheckboxWithOtherState<ProtectionsType>> protectionsTypeKey;
  final ProtectionsStatus? initialSelection;
  final List<String>? initialItems;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RadioWithFollowUp<ProtectionsStatus>(
      key: protectionsKey,
      title:
          'Est-ce que l\'élève devra porter des équipements de protection '
          'individuelle (EPI)\u00a0?',
      enabled: enabled,
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      elements: ProtectionsStatus.values,
      elementsThatShowChild: const [
        ProtectionsStatus.suppliedByEnterprise,
        ProtectionsStatus.suppliedBySchool,
      ],
      initialValue: initialSelection,
      followUpChild: CheckboxWithOther<ProtectionsType>(
        key: protectionsTypeKey,
        title: 'Lesquels\u00a0:',
        enabled: enabled,
        elements: ProtectionsType.values,
        initialValues: initialItems,
      ),
    );
  }
}

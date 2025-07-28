import 'package:common/models/enterprises/job.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:common_flutter/providers/students_provider.dart';
import 'package:common_flutter/widgets/animated_expanding_card.dart';
import 'package:common_flutter/widgets/autocomplete_options_builder.dart';
import 'package:common_flutter/widgets/checkbox_with_other.dart';
import 'package:common_flutter/widgets/entity_picker_tile.dart';
import 'package:common_flutter/widgets/radio_with_follow_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnterpriseJobListController {
  late Specialization? _specialization = _job.specializationOrNull;
  Specialization? get specialization => _specialization;

  final List<Specialization>? _specializationsWhiteList;
  final List<Specialization>? _specializationBlacklist;

  late final _minimumAgeController = TextEditingController(
    text: _job.minimumAge.toString(),
  );
  late Map<String, int> _positionsOffered = _job.positionsOffered.map(
    (key, value) => MapEntry(key, value),
  );
  final Map<String, int> _positionsOccupied = {};

  var _preInternshipRequests = PreInternshipRequests.empty;
  late var _uniformStatus = _job.uniforms.status;
  late final _uniformDescription = TextEditingController(
    text: _job.uniforms.uniforms.join('\n '),
  );
  late var _protectionStatus = _job.protections.status;
  late var _protections = _job.protections.protections;

  final EntityPickerController? _reservedForPickerController;

  final Job _job;
  EnterpriseJobListController({
    required Job job,
    List<Specialization>? specializationWhiteList,
    List<Specialization>? specializationBlackList,
    EntityPickerController? reservedForPickerController,
  }) : _job = job.copyWith(),
       _specializationsWhiteList = specializationWhiteList,
       _specializationBlacklist = specializationBlackList,
       _reservedForPickerController = reservedForPickerController;

  Job get job => _job.copyWith(
    specialization: _specialization,
    minimumAge: int.tryParse(_minimumAgeController.text),
    positionsOffered: _positionsOffered,
    preInternshipRequests: _preInternshipRequests,
    uniforms: _job.uniforms.copyWith(
      status: _uniformStatus,
      uniforms:
          _uniformStatus == UniformStatus.none
              ? []
              : _uniformDescription.text.split('\n'),
    ),
    protections: _job.protections.copyWith(
      status: _protectionStatus,
      protections: _protections,
    ),
    reservedForId:
        _reservedForPickerController == null
            ? _job.reservedForId
            : (_reservedForPickerController.selectionId ?? ''),
  );

  void dispose() {
    _minimumAgeController.dispose();
    _uniformDescription.dispose();
  }
}

class EnterpriseJobListTile extends StatefulWidget {
  const EnterpriseJobListTile({
    super.key,
    required this.controller,
    required this.schools,
    this.editMode = false,
    this.onRequestDelete,
    this.canChangeExpandedState = true,
    this.initialExpandedState = false,
    this.elevation = 10.0,
    this.specializationOnly = false,
    this.showHeader = true,
    this.availabilityIsMandatory = false,
  });

  final EnterpriseJobListController controller;
  final List<School> schools;
  final bool editMode;
  final Function()? onRequestDelete;
  final bool canChangeExpandedState;
  final bool initialExpandedState;
  final double elevation;
  final bool specializationOnly;
  final bool showHeader;
  final bool availabilityIsMandatory;

  @override
  State<EnterpriseJobListTile> createState() => _EnterpriseJobListTileState();
}

class _EnterpriseJobListTileState extends State<EnterpriseJobListTile> {
  Job get job => widget.controller.job;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final students = StudentsProvider.of(context, listen: true);
    final internships = InternshipsProvider.of(context, listen: true);
    widget.controller._positionsOffered = job.positionsOffered;

    widget.controller._positionsOccupied.clear();
    for (final intership in internships) {
      if (intership.jobId == job.id && intership.isActive) {
        final schoolId =
            students
                .firstWhereOrNull(
                  (student) => student.id == intership.studentId,
                )
                ?.schoolId;
        if (schoolId == null) continue;

        widget.controller._positionsOccupied[schoolId] =
            (widget.controller._positionsOccupied[schoolId] ?? 0) + 1;
      }
    }
  }

  void _updatePositions(String schoolId, int newCount) {
    setState(() => widget.controller._positionsOffered[schoolId] = newCount);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedExpandingCard(
      elevation: widget.elevation,
      canChangeExpandedState: widget.canChangeExpandedState,
      initialExpandedState: widget.initialExpandedState,
      header:
          widget.showHeader
              ? Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.controller._specialization?.idWithName ??
                                'Aucune spécialisation sélectionnée',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (widget.editMode && widget.onRequestDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: widget.onRequestDelete,
                          ),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    ...widget.schools.map(
                      (school) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 2.0,
                        ),
                        child: _buildAvailability(school: school),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.controller._reservedForPickerController != null)
                      Column(
                        children: [
                          _buildReservedFor(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              )
              : const SizedBox.shrink(),
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 12.0, right: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.editMode) _buildJobPicker(),
            const SizedBox(height: 8),
            if (!widget.specializationOnly)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMinimumAge(),
                  const SizedBox(height: 8),
                  if (!widget.showHeader)
                    Column(
                      children: [
                        ...widget.schools.map(
                          (school) => _buildAvailability(school: school),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  _buildPrerequisites(),
                  const SizedBox(height: 8),
                  _buildUniform(),
                  const SizedBox(height: 8),
                  _buildProtections(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<Specialization> get _availableSpecialization {
    // Make a copy of the available specializations
    List<Specialization> out = [
      ...(widget.controller._specializationsWhiteList ??
          ActivitySectorsService.allSpecializations),
    ];
    if (widget.controller._specializationBlacklist != null) {
      // Remove the blacklisted specializations
      out.removeWhere(
        (s) => widget.controller._specializationBlacklist!.any(
          (blacklisted) => blacklisted.id == s.id,
        ),
      );
    }
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

  int _positionOffered(String schoolId) {
    return widget.controller._positionsOffered[schoolId] ?? 0;
  }

  int _positionOccupied(String schoolId) {
    return widget.controller._positionsOccupied[schoolId] ?? 0;
  }

  int _positionRemaining(String schoolId) =>
      _positionOffered(schoolId) - _positionOccupied(schoolId);

  Widget _buildAvailability({required School school}) {
    final positionsRemaining = _positionRemaining(school.id);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            '${widget.availabilityIsMandatory ? '* ' : ''}Places disponibles à ${school.name}',
          ),
        ),
        widget.editMode
            ? FormField(
              validator:
                  (value) =>
                      widget.availabilityIsMandatory &&
                              _positionOffered(school.id) == 0
                          ? 'Ajouter au moins une place.'
                          : null,
              builder:
                  (state) => Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed:
                                _positionOffered(school.id) == 0
                                    ? null
                                    : () => _updatePositions(
                                      school.id,
                                      _positionOffered(school.id) - 1,
                                    ),
                            icon: Icon(
                              Icons.remove,
                              color:
                                  _positionOffered(school.id) == 0
                                      ? Colors.grey
                                      : Colors.black,
                            ),
                          ),
                          Text(
                            '$positionsRemaining / ${_positionOffered(school.id)}',
                          ),
                          IconButton(
                            onPressed:
                                () => _updatePositions(
                                  school.id,
                                  _positionOffered(school.id) + 1,
                                ),
                            icon: const Icon(Icons.add, color: Colors.black),
                          ),
                        ],
                      ),
                      if (state.hasError)
                        Text(
                          state.errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
            )
            : Text(
              '$positionsRemaining / ${_positionOffered(school.id)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
      ],
    );
  }

  final _preInternshipRequestKey =
      GlobalKey<CheckboxWithOtherState<PreInternshipRequestTypes>>();
  Widget _buildPrerequisites() {
    return BuildPrerequisitesCheckboxes(
      checkBoxKey: _preInternshipRequestKey,
      enabled: widget.editMode,
      initialValues: [
        ...job.preInternshipRequests.requests.map((e) => e.toString()),
        job.preInternshipRequests.other ?? '',
      ],
      onChanged: (values) {
        widget
            .controller
            ._preInternshipRequests = PreInternshipRequests.fromStrings(values);
      },
    );
  }

  final _uniformFormKey = GlobalKey<RadioWithFollowUpState<UniformStatus>>();
  Widget _buildUniform() {
    return BuildUniformRadio(
      uniformKey: _uniformFormKey,
      uniformTextController: widget.controller._uniformDescription,
      initialSelection: job.uniforms.status,
      enabled: widget.editMode,
      onChanged: (value) {
        widget.controller._uniformStatus = value;
      },
    );
  }

  final _protectionsKey =
      GlobalKey<RadioWithFollowUpState<ProtectionsStatus>>();
  final _protectionsTextController =
      GlobalKey<CheckboxWithOtherState<ProtectionsType>>();
  Widget _buildProtections() {
    return BuildProtectionsRadio(
      protectionsKey: _protectionsKey,
      protectionsTypeKey: _protectionsTextController,
      initialSelection: job.protections.status,
      initialItems:
          job.protections.protections.map((e) => e.toString()).toList(),
      enabled: widget.editMode,
      onChanged: (status, protections) {
        widget.controller._protectionStatus = status;
        widget.controller._protections = protections;
      },
    );
  }

  Widget _buildReservedFor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Réserver ce poste à un\u00b7e enseignant\u00b7e',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 36.0),
          child: EntityPickerTile(
            controller: widget.controller._reservedForPickerController!,
            editMode: widget.editMode,
          ),
        ),
      ],
    );
  }
}

class BuildPrerequisitesCheckboxes extends StatelessWidget {
  const BuildPrerequisitesCheckboxes({
    super.key,
    required this.checkBoxKey,
    required this.initialValues,
    this.enabled = true,
    this.onChanged,
    this.hideTitle = false,
  });

  final GlobalKey<CheckboxWithOtherState<PreInternshipRequestTypes>>
  checkBoxKey;
  final List<String>? initialValues;
  final bool enabled;
  final Function(List<String>)? onChanged;
  final bool hideTitle;

  @override
  Widget build(BuildContext context) {
    return CheckboxWithOther<PreInternshipRequestTypes>(
      key: checkBoxKey,
      title:
          hideTitle
              ? null
              : 'Exigences de l\'entreprise avant d\'accueillir des élèves en stage:',
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      enabled: enabled,
      elements: PreInternshipRequestTypes.values,
      initialValues: initialValues,
      onOptionSelected: (_) {
        if (onChanged != null) {
          onChanged!(checkBoxKey.currentState?.values ?? []);
        }
      },
    );
  }
}

class BuildUniformRadio extends StatelessWidget {
  const BuildUniformRadio({
    super.key,
    required this.uniformKey,
    required this.uniformTextController,
    this.initialSelection,
    this.enabled = true,
    required this.onChanged,
    this.hideTitle = false,
  });

  final GlobalKey<RadioWithFollowUpState<UniformStatus>> uniformKey;
  final TextEditingController uniformTextController;
  final UniformStatus? initialSelection;
  final bool enabled;
  final bool hideTitle;
  final Function(UniformStatus) onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioWithFollowUp<UniformStatus>(
      key: uniformKey,
      title:
          hideTitle
              ? null
              : 'Est-ce qu\'une tenue de travail spécifique est exigée pour '
                  'ce poste\u00a0?',
      titleStyle: Theme.of(context).textTheme.bodyLarge,
      elements: UniformStatus.values,
      elementsThatShowChild: const [
        UniformStatus.suppliedByEnterprise,
        UniformStatus.suppliedByStudent,
      ],
      enabled: enabled,
      onChanged: (value) => onChanged(value!),
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

class BuildProtectionsRadio extends StatelessWidget {
  const BuildProtectionsRadio({
    super.key,
    required this.protectionsKey,
    required this.protectionsTypeKey,
    this.initialSelection,
    this.initialItems,
    this.enabled = true,
    required this.onChanged,
    this.hideTitle = false,
  });

  final GlobalKey<RadioWithFollowUpState<ProtectionsStatus>> protectionsKey;
  final GlobalKey<CheckboxWithOtherState<ProtectionsType>> protectionsTypeKey;
  final ProtectionsStatus? initialSelection;
  final List<String>? initialItems;
  final bool enabled;
  final Function(ProtectionsStatus status, List<String> protections) onChanged;
  final bool hideTitle;

  @override
  Widget build(BuildContext context) {
    return RadioWithFollowUp<ProtectionsStatus>(
      key: protectionsKey,
      title:
          hideTitle
              ? null
              : 'Est-ce que l\'élève devra porter des équipements de protection '
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
        onOptionSelected: (values) {
          final status =
              protectionsKey.currentState?.value ?? ProtectionsStatus.none;
          final protections = values.map((e) => e.toString()).toList();
          onChanged(status, protections);
        },
      ),
      onChanged: (value) {
        final status =
            protectionsKey.currentState?.value ?? ProtectionsStatus.none;
        final protections = protectionsTypeKey.currentState?.values ?? [];
        onChanged(status, protections);
      },
    );
  }
}

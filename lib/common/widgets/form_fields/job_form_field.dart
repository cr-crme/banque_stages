import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import '/common/models/job.dart';
import '/misc/job_data_file_service.dart';

class JobFormField extends StatelessWidget {
  const JobFormField({
    super.key,
    required this.initialValue,
    this.onSaved,
    this.sectors,
    this.specializations,
  });

  final Job initialValue;
  final FormFieldSetter<Job>? onSaved;
  final List<ActivitySector>? sectors;
  final List<Specialization>? specializations;

  static const String _invalidActivitySector = "invalid_activitySector";
  static const String _invalidSpecialization = "invalid_specialization";

  static String? _validator(Job? job) {
    if (job?.activitySector == null) {
      return _invalidActivitySector;
    } else if (job!.specialization == null ||
        !job.activitySector!.specializations.contains(job.specialization)) {
      return _invalidSpecialization;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<Job>(
        initialValue: initialValue,
        onSaved: onSaved,
        validator: _validator,
        builder: (state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Secteur d'activités :",
                  style: Theme.of(state.context).textTheme.titleMedium,
                ),
                ListTile(
                  title: Autocomplete<ActivitySector>(
                    displayStringForOption: (s) => s.idWithName,
                    optionsBuilder: (textEditingValue) =>
                        JobDataFileService.filterData(
                      query: textEditingValue.text,
                      data: sectors ?? JobDataFileService.sectors,
                    ),
                    onSelected: (sector) => state.didChange(
                      state.value!.copyWith(activitySector: sector),
                    ),
                    fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onSubmitted: (_) => onSubmitted(),
                        onChanged: (value) => state.didChange(
                          // We don't use copyWith because it doesn't work with null values (when we want to reset the specialization)
                          Job(
                            activitySector: JobDataFileService.sectors
                                .firstWhereOrNull((s) => s.idWithName == value),
                            positionsOffered: state.value!.positionsOffered,
                          ),
                        ),
                        decoration: InputDecoration(
                          labelText: "* Secteur d'activités",
                          errorText: state.errorText == _invalidActivitySector
                              ? "Entrez une valeur valide"
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Métier semi-spécialisé :",
                  style: Theme.of(state.context).textTheme.titleMedium,
                ),
                ListTile(
                  title: Autocomplete<Specialization>(
                    displayStringForOption: (s) => s.idWithName,
                    optionsBuilder: (textEditingValue) =>
                        JobDataFileService.filterData(
                      query: textEditingValue.text,
                      data: state.value!.activitySector?.specializations
                              .where(
                                  (s) => specializations?.contains(s) ?? true)
                              .toList() ??
                          [],
                    ),
                    onSelected: (specialization) => state.didChange(
                      state.value!.copyWith(specialization: specialization),
                    ),
                    fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
                      return TextField(
                        enabled: state.value!.activitySector != null,
                        controller: controller,
                        focusNode: focusNode,
                        onSubmitted: (_) => onSubmitted(),
                        onChanged: (value) => state.didChange(
                          Job(
                            activitySector: state.value!.activitySector,
                            specialization: state
                                .value!.activitySector?.specializations
                                .firstWhereOrNull((s) => s.idWithName == value),
                          ),
                        ),
                        decoration: InputDecoration(
                          labelText: "* Métier semi-spécialisé",
                          errorText: state.errorText == _invalidSpecialization
                              ? "Entrez une valeur valide"
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Postes disponibles",
                        style: Theme.of(state.context).textTheme.titleMedium,
                      ),
                    ),
                    SizedBox(
                      width: 112,
                      child: SpinBox(
                        value: state.value!.positionsOffered.toDouble(),
                        min: 1,
                        max: 10,
                        spacing: 0,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                        ),
                        onChanged: (double value) => state.didChange(
                          state.value!
                              .copyWith(positionsOffered: value.toInt()),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ));
  }
}

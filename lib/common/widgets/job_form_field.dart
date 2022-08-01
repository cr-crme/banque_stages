import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import '/common/models/job.dart';

class JobFormField extends FormField<Job> {
  const JobFormField(
      {Key? key,
      required Job initialValue,
      FormFieldSetter<Job>? onSaved,
      AutovalidateMode? autovalidateMode})
      : super(
            key: key,
            initialValue: initialValue,
            onSaved: onSaved,
            autovalidateMode: autovalidateMode,
            validator: _validator,
            builder: _builder);

  static const String _invalidActivitySector = "invalid_activitySector";
  static const String _invalidSpecialization = "invalid_specialization";

  static String? _validator(Job? job) {
    if (!jobActivitySectors.contains(job!.activitySector)) {
      return _invalidActivitySector;
    } else if (!jobSpecializations.contains(job.specialization)) {
      return _invalidSpecialization;
    }

    return null;
  }

  static Widget _builder(FormFieldState<Job> state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Secteur d'activités :",
          style: Theme.of(state.context).textTheme.titleMedium,
        ),
        ListTile(
          title: AutoCompleteTextField<String>(
            key: GlobalKey(),
            controller:
                TextEditingController(text: state.value!.activitySector),
            decoration: InputDecoration(
              labelText: "* Secteur d'activités",
              errorText: state.errorText == _invalidActivitySector
                  ? "Entrez une valeur valide"
                  : null,
            ),
            textSubmitted: (sector) =>
                state.didChange(state.value!.copyWith(activitySector: sector)),
            itemSubmitted: (sector) =>
                state.didChange(state.value!.copyWith(activitySector: sector)),
            clearOnSubmit: false,
            suggestions: jobActivitySectors,
            itemBuilder: (context, suggestion) =>
                ListTile(title: Text(suggestion)),
            itemSorter: (a, b) => a.compareTo(b),
            minLength: 0,
            itemFilter: (suggestion, query) => suggestion
                .toString()
                .toLowerCase()
                .startsWith(query.toLowerCase()),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Métier semi-spécialisé :",
          style: Theme.of(state.context).textTheme.titleMedium,
        ),
        ListTile(
          title: AutoCompleteTextField<String>(
            key: GlobalKey(),
            controller:
                TextEditingController(text: state.value!.specialization),
            decoration: InputDecoration(
              labelText: "* Métier semi-spécialisé",
              errorText: state.errorText == _invalidSpecialization
                  ? "Entrez une valeur valide"
                  : null,
            ),
            textSubmitted: (specialization) => state.didChange(
                state.value!.copyWith(specialization: specialization)),
            itemSubmitted: (specialization) => state.didChange(
                state.value!.copyWith(specialization: specialization)),
            clearOnSubmit: false,
            suggestions: jobSpecializations,
            itemBuilder: (context, suggestion) =>
                ListTile(title: Text(suggestion)),
            itemSorter: (a, b) => a.compareTo(b),
            minLength: 0,
            itemFilter: (suggestion, query) => suggestion
                .toString()
                .toLowerCase()
                .startsWith(query.toLowerCase()),
          ),
        ),
        Row(
          children: [
            Expanded(
                child: Text("Postes disponibles",
                    style: Theme.of(state.context).textTheme.titleMedium)),
            SizedBox(
              width: 112,
              child: SpinBox(
                value: 1,
                min: 1,
                max: 10,
                spacing: 0,
                decoration:
                    const InputDecoration(border: UnderlineInputBorder()),
                onChanged: (double value) => state
                    .didChange(state.value!.copyWith(totalSlot: value.toInt())),
              ),
            ),
          ],
        )
      ],
    );
  }
}

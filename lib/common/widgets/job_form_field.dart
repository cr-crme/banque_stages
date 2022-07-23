import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import '/common/models/job.dart';

class JobFormField extends FormField<Job> {
  const JobFormField(
      {Key? key,
      required Job initialValue,
      FormFieldSetter<Job>? onSaved,
      FormFieldValidator<Job>? validator,
      AutovalidateMode? autovalidateMode})
      : super(
            key: key,
            initialValue: initialValue,
            onSaved: onSaved,
            validator: validator,
            autovalidateMode: autovalidateMode,
            builder: _builder);

  static Widget _builder(FormFieldState<Job> state) {
    return Column(
      children: [
        SizedBox(
          width: Size.infinite.width,
          child: Text(
            "Secteur d'activités :",
            style: Theme.of(state.context).textTheme.titleMedium,
          ),
        ),
        DropdownButton<String>(
          value: state.value?.activitySector.name,
          icon: const Icon(Icons.arrow_downward),
          onChanged: (String? name) => state.didChange(
            state.value?.copyWith(
                activitySector: JobActivitySector.values
                    .firstWhere((activity) => activity.name == name!)),
          ),
          items: JobActivitySector.values
              .map((JobActivitySector sector) => DropdownMenuItem(
                  value: sector.name, child: Text(sector.toString())))
              .toList(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: Size.infinite.width,
          child: Text(
            "Métier semi-spécialisé :",
            style: Theme.of(state.context).textTheme.titleMedium,
          ),
        ),
        DropdownButton<String>(
          value: state.value?.specialization.name,
          icon: const Icon(Icons.arrow_downward),
          onChanged: (String? name) => state.didChange(
            state.value?.copyWith(
                specialization: JobSpecialization.values.firstWhere(
                    (specialization) => specialization.name == name!)),
          ),
          items: JobSpecialization.values
              .map((JobSpecialization specialization) => DropdownMenuItem(
                    value: specialization.name,
                    child: Text(specialization.toString()),
                  ))
              .toList(),
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
                    .didChange(state.value?.copyWith(totalSlot: value.toInt())),
              ),
            ),
          ],
        )
      ],
    );
  }
}

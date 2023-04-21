import 'package:flutter/material.dart';

class LowHighSliderFormField extends FormField<double> {
  const LowHighSliderFormField({
    super.key,
    double initialValue = 3,
    bool enabled = true,
    void Function(double? value)? onSaved,
  }) : super(
          initialValue: initialValue,
          enabled: enabled,
          onSaved: onSaved,
          builder: _builder,
        );

  static const int min = 1;
  static const int max = 5;

  static Widget _builder(FormFieldState<double> state) {
    if (state.value! < min || state.value! > max) {
      return const Text('Aucune donnée pour l\'instant.');
    }

    return SizedBox(
      width: Size.infinite.width,
      child: Row(
        children: [
          const Text('Faible'),
          Expanded(
            child: Slider(
              value: state.value!,
              onChanged: state.widget.enabled
                  ? (double newValue) => state.didChange(newValue)
                  : null,
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
            ),
          ),
          const Text('Élevé'),
        ],
      ),
    );
  }
}

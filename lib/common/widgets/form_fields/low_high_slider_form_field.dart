import 'package:flutter/material.dart';

class LowHighSliderFormField extends FormField<double> {
  const LowHighSliderFormField({
    super.key,
    double initialValue = 3,
    bool enabled = true,
    void Function(double? value)? onSaved,
    this.min = 1,
    this.max = 5,
    this.lowLabel = 'Faible',
    this.highLabel = 'Élevé',
  }) : super(
          initialValue: initialValue,
          enabled: enabled,
          onSaved: onSaved,
          builder: _builder,
        );

  final String lowLabel;
  final String highLabel;
  final int min;
  final int max;

  static Widget _builder(FormFieldState<double> state) {
    final lowLabel = (state.widget as LowHighSliderFormField).lowLabel;
    final highLabel = (state.widget as LowHighSliderFormField).highLabel;
    final min = (state.widget as LowHighSliderFormField).min;
    final max = (state.widget as LowHighSliderFormField).max;

    if (state.value! < min || state.value! > max) {
      return const Text('Aucune donnée pour l\'instant.');
    }

    return SizedBox(
      width: Size.infinite.width,
      child: Row(
        children: [
          Text(lowLabel, textAlign: TextAlign.center),
          Expanded(
            child: Slider(
              value: state.value!,
              onChanged: state.widget.enabled
                  ? (double newValue) => state.didChange(newValue)
                  : null,
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              label: '${state.value!.toInt()}',
            ),
          ),
          Text(highLabel, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

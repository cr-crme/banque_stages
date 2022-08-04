import 'package:flutter/material.dart';

class LowHighSliderFormField extends FormField<double> {
  const LowHighSliderFormField({
    Key? key,
    required double initialValue,
    bool enabled = true,
    void Function(double?)? onSaved,
  }) : super(
          key: key,
          initialValue: initialValue,
          enabled: enabled,
          onSaved: onSaved,
          builder: _builder,
        );

  // TODO: Handle invalid values (display as non-existant)

  static Widget _builder(FormFieldState<double> state) {
    return SizedBox(
      width: Size.infinite.width,
      child: Row(
        children: [
          const Text("Faible"),
          Expanded(
            child: Slider(
              value: state.value!,
              onChanged: state.widget.enabled
                  ? (double newValue) => state.didChange(newValue)
                  : null,
              min: 1,
              max: 5,
              divisions: 4,
            ),
          ),
          const Text("Élevé"),
        ],
      ),
    );
  }
}

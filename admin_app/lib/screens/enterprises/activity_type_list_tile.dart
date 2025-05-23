import 'package:admin_app/widgets/autocomplete_options_builder.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:flutter/material.dart';

class ActivityTypeListController {
  final Set<ActivityTypes> _activityTypes;
  Set<ActivityTypes> get activityTypes => {..._activityTypes};

  ActivityTypeListController({required Set<ActivityTypes> initial})
    : _activityTypes = {...initial};

  void dispose() {
    _activityTypes.clear();
  }
}

class ActivityTypeListTile extends StatelessWidget {
  const ActivityTypeListTile({
    super.key,
    required this.controller,
    required this.editMode,
    required this.onSaved,
  });

  final ActivityTypeListController controller;
  final bool editMode;
  final Function(Set<ActivityTypes>?) onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Types d\'activités'),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Column(
            children: [
              editMode
                  ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _ActivityTypesPickerFormField(
                      controller: controller,
                      activityTabAtTop: true,
                    ),
                  )
                  : _ActivityTypeCards(controller: controller),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityTypeCards extends StatelessWidget {
  const _ActivityTypeCards({required this.controller, this.onDeleted});

  final ActivityTypeListController controller;
  final void Function(ActivityTypes activityType)? onDeleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          controller._activityTypes
              .map(
                (activityType) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    deleteIcon: const Icon(Icons.delete, color: Colors.black),
                    deleteIconColor: Theme.of(context).colorScheme.onPrimary,
                    label: Text(
                      activityType.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    backgroundColor: const Color(0xFFB8D8E6),
                    side: BorderSide.none,
                    onDeleted:
                        onDeleted != null
                            ? () => onDeleted!(activityType)
                            : null,
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _ActivityTypesPickerFormField extends FormField<Set<ActivityTypes>> {
  _ActivityTypesPickerFormField({
    required this.controller,
    String? Function(Set<ActivityTypes>? activityTypes)? validator,
    required this.activityTabAtTop,
  }) : super(
         initialValue: controller._activityTypes,
         validator: validator ?? _validator,
         builder: _builder,
       );

  final bool activityTabAtTop;
  final ActivityTypeListController controller;

  static String? _validator(Set<ActivityTypes>? activityTypes) {
    if (activityTypes!.isEmpty) return 'Choisir au moins un type d\'activité.';

    return null;
  }

  static Widget _builder(FormFieldState<Set<ActivityTypes>> state) {
    late TextEditingController textFieldController;
    late FocusNode textFieldFocusNode;
    final controller =
        (state.widget as _ActivityTypesPickerFormField).controller;
    final activityTabAtTop =
        (state.widget as _ActivityTypesPickerFormField).activityTabAtTop;

    final activityTabs = _ActivityTypeCards(
      controller: controller,
      onDeleted: (activityType) {
        state.value!.remove(activityType);
        controller._activityTypes.remove(activityType);
        state.didChange(state.value);
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activityTabAtTop) activityTabs,
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            return ActivityTypes.values
                .map<String>((e) => e.toString())
                .where(
                  (activity) =>
                      activity.toLowerCase().contains(
                        textEditingValue.text.toLowerCase().trim(),
                      ) &&
                      !state.value!.contains(
                        ActivityTypes.fromString(activity),
                      ),
                );
          },
          optionsViewBuilder:
              (context, onSelected, options) => OptionsBuilderForAutocomplete(
                onSelected: onSelected,
                options: options,
                optionToString: (String e) => e,
              ),
          onSelected: (activityType) {
            state.value!.add(ActivityTypes.fromString(activityType));
            controller._activityTypes.add(
              ActivityTypes.fromString(activityType),
            );
            state.didChange(state.value);
            textFieldController.text = '';
            textFieldFocusNode.unfocus();
          },
          fieldViewBuilder: (_, controller, focusNode, onSubmitted) {
            textFieldController = controller;
            textFieldFocusNode = focusNode;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: '* Type d\'activité de l\'entreprise',
                errorText: state.errorText,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    if (focusNode.hasFocus) focusNode.nextFocus();

                    controller.text = '';
                  },
                ),
              ),
            );
          },
        ),
        if (!activityTabAtTop) const SizedBox(height: 8),
        if (!activityTabAtTop) activityTabs,
      ],
    );
  }
}

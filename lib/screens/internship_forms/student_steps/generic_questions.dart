import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/common/models/internship.dart';
import '/common/widgets/sub_title.dart';
import 'student_form_controller.dart';

class GenericQuestions extends StatelessWidget {
  const GenericQuestions(
      {super.key, required this.internship, required this.formController});

  final Internship internship;
  final StudentFormController formController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EvaluationDate(formController: formController),
        _PersonAtMeeting(formController: formController),
      ],
    );
  }
}

class _EvaluationDate extends StatefulWidget {
  const _EvaluationDate({required this.formController});

  final StudentFormController formController;
  @override
  State<_EvaluationDate> createState() => _EvaluationDateState();
}

class _EvaluationDateState extends State<_EvaluationDate> {
  void _promptDate(context) async {
    final newDate = await showDatePicker(
      helpText: 'Sélectionner les dates',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      initialDate: widget.formController.evaluationDate,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (newDate == null) return;

    widget.formController.evaluationDate = newDate;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Date de l\'évaluation'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(DateFormat('dd MMMM yyyy', 'fr_CA')
                  .format(widget.formController.evaluationDate)),
              IconButton(
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.blue,
                ),
                onPressed: () => _promptDate(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PersonAtMeeting extends StatefulWidget {
  const _PersonAtMeeting({required this.formController});

  final StudentFormController formController;
  @override
  State<_PersonAtMeeting> createState() => _PersonAtMeetingState();
}

class _PersonAtMeetingState extends State<_PersonAtMeeting> {
  Widget _buildCheckTile(
      {required String title,
      required bool value,
      required Function(bool?) onChanged}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 3 / 4,
      child: CheckboxListTile(
        visualDensity: VisualDensity.compact,
        controlAffinity: ListTileControlAffinity.leading,
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Personnes présentes lors de l\'évaluation'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...widget.formController.wereAtMeeting.keys
                  .map((person) => _buildCheckTile(
                      title: person,
                      value: widget.formController.wereAtMeeting[person]!,
                      onChanged: (newValue) => setState(() => widget
                          .formController.wereAtMeeting[person] = newValue!)))
                  .toList(),
              _buildCheckTile(
                  title: 'Autre',
                  value: widget.formController.withOtherAtMeeting,
                  onChanged: (newValue) => setState(() =>
                      widget.formController.withOtherAtMeeting = newValue!)),
              Visibility(
                visible: widget.formController.withOtherAtMeeting,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Précisez : ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextFormField(
                        controller:
                            widget.formController.othersAtMeetingController,
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

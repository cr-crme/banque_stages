import 'package:common/models/internships/internship.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:common_flutter/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('ValidationStep');

class ValidationStep extends StatelessWidget {
  const ValidationStep({super.key, required this.internship});

  final Internship? internship;

  @override
  Widget build(BuildContext context) {
    _logger.finer('Building ScheduleStep widget');
    String studentName = 'Aucun stagiaire sélectionné';
    if (internship != null) {
      final name = StudentsProvider.of(context)
          .fromIdOrNull(internship!.studentId)
          ?.fullName;
      if (name != null) studentName = name;
    }

    final enterprise =
        EnterprisesProvider.of(context).fromIdOrNull(internship?.enterpriseId);
    internship?.jobId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Stagiaire', left: 0),
        Text(studentName),
        const SizedBox(height: 16),
        const SubTitle('Métier(s)', left: 0),
        intern
      ],
    );
  }
}

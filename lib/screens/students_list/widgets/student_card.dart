import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/common/models/student.dart';

class StudentCard extends StatelessWidget {
  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
  });

  final Student student;
  final void Function(Student student) onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: InkWell(
        onTap: () => onTap(student),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        Text(student.program),
                        Text(
                          AppLocalizations.of(context)!
                              .student_currentGroup(student.group),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

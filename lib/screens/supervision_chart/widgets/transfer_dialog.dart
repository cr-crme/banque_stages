import 'package:flutter/material.dart';

import '/common/models/student.dart';
import '/common/models/teacher.dart';

class TransferDialog extends StatefulWidget {
  const TransferDialog({
    super.key,
    required this.students,
    required this.teachers,
  });

  final List<Student> students;
  final List<Teacher> teachers;

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  late String _choiceStudent = widget.students[0].id;
  late String _choiceTeacher = widget.teachers[0].id;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Transférer un étudiant'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sélectionner un étudiant'),
          DropdownButton<String>(
            value: _choiceStudent,
            icon: const Icon(Icons.expand_more),
            onChanged: (String? newValue) =>
                setState(() => _choiceStudent = newValue!),
            items: widget.students
                .map<DropdownMenuItem<String>>(
                    (student) => DropdownMenuItem<String>(
                          value: student.id,
                          child: Text(student.fullName),
                        ))
                .toList(),
          ),
          const SizedBox(height: 20),
          const Text('Sélectionner la personne qui le supervisera'),
          DropdownButton<String>(
            value: _choiceTeacher,
            icon: const Icon(Icons.expand_more),
            onChanged: (String? newValue) =>
                setState(() => _choiceTeacher = newValue!),
            items: widget.students
                .map<DropdownMenuItem<String>>(
                    (student) => DropdownMenuItem<String>(
                          value: student.id,
                          child: Text(student.fullName),
                        ))
                .toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, ['1', '2']),
            child: const Text('Annuler')),
        TextButton(
            onPressed: () => Navigator.pop(
                  context,
                ),
            child: const Text('Ok')),
      ],
    );
  }
}

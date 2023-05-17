import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/models/teacher.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';

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
  late String? _choiceTeacher = _getCurrentSupervisorId();

  String? _getCurrentSupervisorId() {
    final internships = InternshipsProvider.of(context, listen: false);
    final internship = internships.byStudentId(_choiceStudent);
    if (internship.isEmpty) {
      return null;
    }
    return internships.byStudentId(_choiceStudent).last.teacherId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Transférer la supervision de l\'élève'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Élève'),
          DropdownButton<String>(
            value: _choiceStudent,
            icon: const Icon(Icons.expand_more),
            onChanged: widget.students.length == 1
                ? null
                : (String? newValue) {
                    _choiceStudent = newValue!;
                    _choiceTeacher = _getCurrentSupervisorId();
                    setState(() {});
                  },
            items: widget.students
                .map<DropdownMenuItem<String>>(
                    (student) => DropdownMenuItem<String>(
                          value: student.id,
                          child: Text(student.fullName),
                        ))
                .toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Enseignant\u00b7e',
          ),
          if (_choiceTeacher == null)
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Aucun stage pour cet élève',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          if (_choiceTeacher != null)
            DropdownButton<String>(
              value: _choiceTeacher,
              icon: const Icon(Icons.expand_more),
              onChanged: (String? newValue) =>
                  setState(() => _choiceTeacher = newValue!),
              items: widget.teachers
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
        OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
        TextButton(
          onPressed: () {
            Navigator.pop(
                context,
                _choiceTeacher == null
                    ? null
                    : [_choiceStudent, _choiceTeacher!]);
          },
          child: const Text('Ok'),
        ),
      ],
    );
  }
}

class AcceptTransferDialog extends StatelessWidget {
  const AcceptTransferDialog({super.key, required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Transfert d\'élève'),
      content:
          Text('La supervision de ${student.fullName} vous a été transférée.\n'
              'Acceptez-vous?'),
      actions: [
        OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non')),
        TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui')),
      ],
    );
  }
}

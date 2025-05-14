import 'package:common/models/internships/internship.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';

extension InternshipExtension on Internship {
  void addSupervisingTeacher(context, {required String teacherId}) {
    if (teacherId == signatoryTeacherId ||
        supervisingTeacherIds.contains(teacherId)) {
      // If the teacher is already assigned, do nothing
      return;
    }

    // Make sure the student is in a group supervised by the teacher
    final students = StudentsProvider.allStudentsLimitedInfo(context);
    final student = students.firstWhere((e) => e.id == studentId);
    final teacher = TeachersProvider.of(context, listen: false)[teacherId];
    if (!teacher.groups.contains(student.group)) {
      throw Exception(
          'The teacher ${teacher.fullName} is not assigned to the group ${student.group}');
    }

    InternshipsProvider.of(context, listen: false).replace(
      copyWith(
        extraSupervisingTeacherIds: [...extraSupervisingTeacherIds, teacherId],
      ),
    );
  }

  void removeSupervisingTeacher(context, {required String teacherId}) {
    if (teacherId == signatoryTeacherId ||
        !supervisingTeacherIds.contains(teacherId)) {
      // If the teacher is not assigned, do nothing
      return;
    }

    InternshipsProvider.of(context, listen: false).replace(
      copyWith(
          extraSupervisingTeacherIds: extraSupervisingTeacherIds
              .where((id) => id != teacherId)
              .toList()),
    );
  }
}

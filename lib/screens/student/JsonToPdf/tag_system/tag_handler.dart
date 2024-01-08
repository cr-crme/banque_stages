// ignore_for_file: constant_identifier_names

import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/models/teacher.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/schools_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:flutter/widgets.dart';

enum DocumentTags {
  SCHOOL_NAME,
  SCHOOL_ADDRESS,
  ENTERPRISE_NAME,
  ENTERPRISE_ADDRESS,
  ENTERPRISE_HEADQUARTERS_ADDRESS,
  ENTERPRISE_PHONE_NUMBER,
  ENTERPRISE_CONTACT_FIRST_NAME,
  ENTERPRISE_CONTACT_LAST_NAME,
  ENTERPRISE_CONTACT_NAME,
  ENTERPRISE_CONTACT_FUNCTION,
  STUDENT_FIRST_NAME,
  STUDENT_LAST_NAME,
  STUDENT_NAME,
  STUDENT_ADDRESS,
  STUDENT_PHONE_NUMBER,
  STUDENT_BIRTH_DATE,
  STUDENT_EMERGENCY_CONTACT_FIRST_NAME,
  STUDENT_EMERGENCY_CONTACT_LAST_NAME,
  STUDENT_EMERGENCY_CONTACT_NAME,
  STUDENT_EMERGENCY_CONTACT_RELATIONSHIP,
  TEACHER_FIRST_NAME,
  TEACHER_LAST_NAME,
  TEACHER_NAME,
  TEACHER_PHONE_NUMBER,
  INTERNSHIP_SUPERVISOR_FIRST_NAME,
  INTERNSHIP_SUPERVISOR_LAST_NAME,
  INTERNSHIP_SUPERVISOR_NAME,
  INTERNSHIP_SUPERVISOR_PHONE_NUMBER,
}

class TagHandler {
  final BuildContext context;
  final Internship internship;

  TagHandler({required this.context, required this.internship});

  Future<String> replaceTag(String content) async {
    String tagName = content.substring(2, content.length - 2);
    DocumentTags? tagEnum;
    for (DocumentTags tag in DocumentTags.values) {
      if (tag.toString().split('.').last == tagName) {
        tagEnum = tag;
        break;
      }
    }
    if (tagEnum != null) {
      String replacementValue = await fetchDataForTag(tagEnum);
      return replacementValue;
    }

    return content;
  }

  Future<String> fetchDataForTag(DocumentTags tag) async {
    String tagKey = _convertTagToString(tag);

    switch (tag) {
      case DocumentTags.SCHOOL_NAME:
      case DocumentTags.SCHOOL_ADDRESS:
        return await _getSchoolData(tagKey);
      case DocumentTags.ENTERPRISE_NAME:
      case DocumentTags.ENTERPRISE_ADDRESS:
      case DocumentTags.ENTERPRISE_HEADQUARTERS_ADDRESS:
      case DocumentTags.ENTERPRISE_PHONE_NUMBER:
      case DocumentTags.ENTERPRISE_CONTACT_FIRST_NAME:
      case DocumentTags.ENTERPRISE_CONTACT_LAST_NAME:
      case DocumentTags.ENTERPRISE_CONTACT_NAME:
      case DocumentTags.ENTERPRISE_CONTACT_FUNCTION:
        return await _getEnterpriseData(tagKey);
      case DocumentTags.STUDENT_FIRST_NAME:
      case DocumentTags.STUDENT_LAST_NAME:
      case DocumentTags.STUDENT_NAME:
      case DocumentTags.STUDENT_ADDRESS:
      case DocumentTags.STUDENT_PHONE_NUMBER:
      case DocumentTags.STUDENT_BIRTH_DATE:
      case DocumentTags.STUDENT_EMERGENCY_CONTACT_FIRST_NAME:
      case DocumentTags.STUDENT_EMERGENCY_CONTACT_LAST_NAME:
      case DocumentTags.STUDENT_EMERGENCY_CONTACT_NAME:
      case DocumentTags.STUDENT_EMERGENCY_CONTACT_RELATIONSHIP:
        return await _getStudentData(tagKey);
      case DocumentTags.TEACHER_FIRST_NAME:
      case DocumentTags.TEACHER_LAST_NAME:
      case DocumentTags.TEACHER_NAME:
      case DocumentTags.TEACHER_PHONE_NUMBER:
        return await _getTeacherData(tagKey);
      case DocumentTags.INTERNSHIP_SUPERVISOR_FIRST_NAME:
        return internship.supervisor.firstName;
      case DocumentTags.INTERNSHIP_SUPERVISOR_LAST_NAME:
        return internship.supervisor.lastName;
      case DocumentTags.INTERNSHIP_SUPERVISOR_NAME:
        return '${internship.supervisor.firstName} ${internship.supervisor.lastName}';
      case DocumentTags.INTERNSHIP_SUPERVISOR_PHONE_NUMBER:
        return internship.supervisor.phone.toString();

      default:
        throw Exception('Unhandled document tag: $tag');
    }
  }

  String _convertTagToString(DocumentTags tag) {
    String tagString = tag
        .toString()
        .replaceAll('DocumentTags.', '')
        .replaceAll('_', ' ')
        .toLowerCase();
    return _toCamelCase(tagString);
  }

  String _toCamelCase(String text) {
    return text.split(' ').map((word) {
      if (text.split(' ').indexOf(word) != 0) {
        // If it's not the first word, capitalize the first letter
        return word[0].toUpperCase() + word.substring(1);
      }
      return word; // First word remains in lowercase
    }).join('');
  }

  Future<String> _getSchoolData(String tag) async {
    final schoolProvider = SchoolsProvider.of(context, listen: false);
    switch (tag) {
      case 'schoolName':
        return schoolProvider[0].name;
      case 'schoolAddress':
        return schoolProvider[0].address.toString();
      default:
        throw Exception('Unhandled school tag: $tag');
    }
  }

  Future<String> _getEnterpriseData(String tag) async {
    final enterprisesProvider = EnterprisesProvider.of(context, listen: false);
    Enterprise enterprise = enterprisesProvider
        .firstWhere((enterprise) => enterprise.id == internship.enterpriseId);
    switch (tag) {
      case 'enterpriseName':
        return enterprise.name;
      case 'enterpriseAddress':
        return enterprise.address?.toString() ?? '';
      case 'enterpriseHeadquartersAddress':
        return enterprise.headquartersAddress?.toString() ?? '';
      case 'enterprisePhoneNumber':
        return enterprise.phone.toString();
      case 'enterpriseContactFirstName':
        return enterprise.contact.firstName;
      case 'enterpriseContactLastName':
        return enterprise.contact.lastName;
      case 'enterpriseContactName':
        return '${enterprise.contact.firstName} ${enterprise.contact.lastName}';
      case 'enterpriseContactFunction':
        return enterprise.contactFunction;
      default:
        throw Exception('Unhandled enterprise tag: $tag');
    }
  }

  Future<String> _getStudentData(String tag) async {
    final studentsProvider =
        StudentsProvider.mySupervizedStudents(context, listen: false);
    Student student = studentsProvider
        .firstWhere((student) => student.id == internship.studentId);
    switch (tag) {
      case 'studentFirstName':
        return student.firstName;
      case 'studentLastName':
        return student.lastName;
      case 'studentName':
        return '${student.firstName} ${student.lastName}';
      case 'studentAddress':
        return student.address.toString();
      case 'studentPhoneNumber':
        return student.phone.toString();
      case 'studentBirthDate':
        return student.dateBirth.toString();
      case 'studentEmergencyContactFirstName':
        return student.contact.firstName;
      case 'studentEmergencyContactLastName':
        return student.contact.lastName;
      case 'studentEmergencyContactName':
        return '${student.contact.firstName} ${student.contact.lastName}';
      case 'studentEmergencyContactRelationship':
        return student.contactLink;
      default:
        throw Exception('Unhandled student tag: $tag');
    }
  }

  Future<String> _getTeacherData(String tag) async {
    final teachersProvider = TeachersProvider.of(context, listen: false);
    Teacher teacher = teachersProvider
        .firstWhere((teacher) => teacher.id == internship.signatoryTeacherId);
    switch (tag) {
      case 'teacherFirstName':
        return teacher.firstName;
      case 'teacherLastName':
        return teacher.lastName;
      case 'teacherName':
        return '${teacher.firstName} ${teacher.lastName}';
      case 'teacherPhoneNumber':
        return teacher.phone.toString();
      default:
        throw Exception('Unhandled teacher tag: $tag');
    }
  }

  Future<dynamic> processElementsRecursively(
      dynamic elements, TagHandler tagsHandler) async {
    if (elements is Map<String, dynamic>) {
      // Processing Map elements
      return await processMapElement(elements, tagsHandler);
    } else if (elements is List) {
      // Processing List elements
      for (var i = 0; i < elements.length; i++) {
        elements[i] =
            await processElementsRecursively(elements[i], tagsHandler);
      }
      return elements;
    }
    return elements;
  }

  Future<Map<String, dynamic>> processMapElement(
      Map<String, dynamic> element, TagHandler tagsHandler) async {
    if (element['child'] != null) {
      element['child'] =
          await processElementsRecursively(element['child'], tagsHandler);
    } else if (element['elements'] != null && element['elements'] is List) {
      element['elements'] =
          await processElementsRecursively(element['elements'], tagsHandler);
    } else if (element['children'] != null && element['children'] is List) {
      element['children'] =
          await processElementsRecursively(element['children'], tagsHandler);
    } else if (element['type'] == "text" || element['type'] == "inputField") {
      String key = element['type'] == "text" ? 'content' : 'defaultValue';
      String? value = element[key];
      if (value != null && value.startsWith('__') && value.endsWith('__')) {
        String replacedValue = await tagsHandler.replaceTag(value);
        element[key] = replacedValue;
      }
    }
    return element;
  }
}

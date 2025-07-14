import 'dart:typed_data';

import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/internships/schedule.dart';
import 'package:common/models/internships/time_utils.dart' as time_utils;
import 'package:common/models/internships/transportation.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common/models/persons/person.dart';
import 'package:common/models/persons/student.dart' as student_model;
import 'package:common/models/persons/teacher.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

part 'package:crcrme_banque_stages/screens/internship_forms/pdf_templates/attitude_evaluation_pdf_template.dart';
part 'package:crcrme_banque_stages/screens/internship_forms/pdf_templates/internship_contract_pdf_template.dart';
part 'package:crcrme_banque_stages/screens/internship_forms/pdf_templates/skill_evaluation_pdf_template.dart';
part 'package:crcrme_banque_stages/screens/internship_forms/pdf_templates/visa_pdf_template.dart';

class GenerateDocuments {
  static Future<Uint8List> generateInternshipContractPdf(
          BuildContext context, PdfPageFormat format,
          {required String internshipId}) async =>
      await _generateInternshipContractPdf(context, format,
          internshipId: internshipId);

  static Future<Uint8List> generateVisaPdf(
          BuildContext context, PdfPageFormat format,
          {required String internshipId}) async =>
      await _generateVisaPdf(context, format, internshipId: internshipId);

  static Future<Uint8List> generateSkillEvaluationPdf(
          BuildContext context, PdfPageFormat format,
          {required String internshipId, required int evaluationIndex}) async =>
      await _generateSkillEvaluationPdf(context, format,
          internshipId: internshipId, evaluationIndex: evaluationIndex);

  static Future<Uint8List> generateAttitudeEvaluationPdf(
          BuildContext context, PdfPageFormat format,
          {required String internshipId, required int evaluationIndex}) async =>
      await _generateAttitudeEvaluationPdf(context, format,
          internshipId: internshipId, evaluationIndex: evaluationIndex);
}

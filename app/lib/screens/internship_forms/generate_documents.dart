import 'dart:typed_data';

import 'package:common/models/internships/internship.dart';
import 'package:common/models/persons/student.dart' as student_model;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

part 'package:crcrme_banque_stages/screens/internship_forms/pdf_templates/attitude_evaluation_pdf_template.dart';
part 'package:crcrme_banque_stages/screens/internship_forms/pdf_templates/internship_contract_pdf_template.dart';
part 'package:crcrme_banque_stages/screens/internship_forms/pdf_templates/skill_evaluation_pdf_template.dart';
part 'package:crcrme_banque_stages/screens/internship_forms/pdf_templates/visa_pdf_template.dart';

class GenerateDocuments {
  static Future<Uint8List> generateInternshipContractPdf(format,
          {required Internship internship, required int versionIndex}) async =>
      await _generateInternshipContractPdf(format,
          internship: internship, versionIndex: versionIndex);

  static Future<Uint8List> generateVisaPdf(format,
          {required Internship internship}) async =>
      await _generateVisaPdf(format, internship: internship);

  static Future<Uint8List> generateSkillEvaluationPdf(format,
          {required Internship internship,
          required int evaluationIndex}) async =>
      await _generateSkillEvaluationPdf(format,
          internship: internship, evaluationIndex: evaluationIndex);

  static Future<Uint8List> generateAttitudeEvaluationPdf(format,
          {required Internship internship,
          required int evaluationIndex}) async =>
      await _generateAttitudeEvaluationPdf(format,
          internship: internship, evaluationIndex: evaluationIndex);
}

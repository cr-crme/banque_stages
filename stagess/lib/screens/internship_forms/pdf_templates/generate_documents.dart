import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stagess_common/models/enterprises/enterprise.dart';
import 'package:stagess_common/models/enterprises/job.dart';
import 'package:stagess_common/models/internships/internship.dart';
import 'package:stagess_common/models/internships/schedule.dart';
import 'package:stagess_common/models/internships/transportation.dart';
import 'package:stagess_common/models/persons/student.dart' as student_model;
import 'package:stagess_common/models/persons/teacher.dart';
import 'package:stagess_common/models/school_boards/school.dart';
import 'package:stagess_common/models/school_boards/school_board.dart';
import 'package:stagess_common/services/image_helpers.dart';
import 'package:stagess_common_flutter/providers/enterprises_provider.dart';
import 'package:stagess_common_flutter/providers/internships_provider.dart';
import 'package:stagess_common_flutter/providers/school_boards_provider.dart';
import 'package:stagess_common_flutter/providers/students_provider.dart';
import 'package:stagess_common_flutter/providers/teachers_provider.dart';

part 'package:stagess/screens/internship_forms/pdf_templates/internship_contract_pdf_template.dart';
part 'package:stagess/screens/internship_forms/pdf_templates/visa_pdf_template.dart';

final _logger = Logger('GenerateDocuments');

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
}

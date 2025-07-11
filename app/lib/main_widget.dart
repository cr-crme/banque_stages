import 'package:common/models/internships/internship.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common/models/persons/person.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/generate_documents.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:common/models/internships/time_utils.dart' as time_utils;

void main() async {
  runApp(MaterialApp(
    home: Scaffold(
      body: MyWidget(),
    ),
  ));
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      allowPrinting: true,
      allowSharing: true,
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      build: (format) => GenerateDocuments.generateInternshipContractPdf(format,
          versionIndex: 0,
          internship: Internship(
            schoolBoardId: '0',
            studentId: '0',
            signatoryTeacherId: '0',
            extraSupervisingTeacherIds: [],
            enterpriseId: '0',
            jobId: '0',
            extraSpecializationIds: [],
            creationDate: DateTime(2025, 5, 2),
            supervisor: Person(
              firstName: 'Me',
              middleName: null,
              lastName: 'AndI',
              dateBirth: null,
              phone: null,
              email: null,
              address: null,
            ),
            dates: time_utils.DateTimeRange(
                start: DateTime(2025, 5, 2), end: DateTime(2025, 6, 2)),
            weeklySchedules: [],
            expectedDuration: 100,
            achievedDuration: 0,
            visitingPriority: VisitingPriority.low,
            endDate: DateTime(2025, 6, 2),
          )),
    );
  }
}

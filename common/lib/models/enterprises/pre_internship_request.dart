part of 'package:common/models/enterprises/job.dart';

// TODO PreInternshipRequest was an actual class, but was changed to an enum. The holder of the list is not Job
enum PreInternshipRequest {
  soloInterview,
  judiciaryBackgroundCheck;

  int _toInt(String version) {
    if (version == '1.0.0') {
      return index;
    }
    throw WrongVersionException(version, '1.0.0');
  }

  static PreInternshipRequest _fromInt(int index, String version) {
    if (version == '1.0.0') {
      return PreInternshipRequest.values[index];
    }
    throw WrongVersionException(version, '1.0.0');
  }

  @override
  String toString() {
    switch (this) {
      case PreInternshipRequest.soloInterview:
        return 'Une entrevue de recrutement de l\'élève en solo';
      case PreInternshipRequest.judiciaryBackgroundCheck:
        return 'Une vérification des antécédents judiciaires pour les élèves majeurs';
    }
  }
}

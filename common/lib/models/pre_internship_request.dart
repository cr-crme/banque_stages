// TODO PreInternshipRequest was an actual class, but was changed to an enum. The holder of the list is not Job
enum PreInternshipRequest {
  soloInterview,
  judiciaryBackgroundCheck;

  static PreInternshipRequest fromString(String name) {
    return PreInternshipRequest.values
        .firstWhere((element) => element.name == name);
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

import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';

enum PreInternshipRequestType {
  soloInterview,
  judiciaryBackgroundCheck;

  @override
  String toString() {
    switch (this) {
      case PreInternshipRequestType.soloInterview:
        return 'Une entrevue de recrutement de l\'élève en solo';
      case PreInternshipRequestType.judiciaryBackgroundCheck:
        return 'Une vérification des antécédents judiciaires pour les élèves majeurs';
    }
  }
}

class PreInternshipRequest extends ItemSerializable {
  List<String> requests;

  PreInternshipRequest({super.id, required this.requests});

  PreInternshipRequest.fromSerialized(super.map)
      : requests =
            (map['requests'] as List? ?? []).map<String>((e) => e).toList(),
        super.fromSerialized();

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'requests': requests,
      };
}

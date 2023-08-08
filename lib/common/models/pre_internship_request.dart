import 'package:enhanced_containers/enhanced_containers.dart';

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

  PreInternshipRequest({required this.requests});

  PreInternshipRequest.fromSerialized(map)
      : requests =
            (map['requests'] as List? ?? []).map<String>((e) => e).toList(),
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() => {
        'id': id,
        'requests': requests,
      };

  PreInternshipRequest deepCopy() {
    return PreInternshipRequest(requests: [...requests]);
  }
}

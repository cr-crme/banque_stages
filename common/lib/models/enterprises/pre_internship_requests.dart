part of 'package:common/models/enterprises/job.dart';

enum PreInternshipRequestTypes {
  soloInterview,
  judiciaryBackgroundCheck;

  @override
  String toString() {
    switch (this) {
      case soloInterview:
        return 'Une entrevue de recrutement de l\'élève en solo';
      case judiciaryBackgroundCheck:
        return 'Une vérification des antécédents judiciaires pour les élèves majeurs';
    }
  }

  int _toInt(String version) {
    if (version == '1.0.0') {
      return index;
    }
    throw WrongVersionException(version, '1.0.0');
  }

  static PreInternshipRequestTypes _fromInt(int index, String version) {
    if (version == '1.0.0') {
      return PreInternshipRequestTypes.values[index];
    }
    throw WrongVersionException(version, '1.0.0');
  }
}

class PreInternshipRequests extends ItemSerializable {
  final List<PreInternshipRequestTypes> requests;
  final String? other;
  final bool isApplicable;

  PreInternshipRequests({
    super.id,
    required this.requests,
    required this.other,
    required this.isApplicable,
  });

  factory PreInternshipRequests.fromStrings(List<String> values) {
    final requests = <PreInternshipRequestTypes>[];
    bool isApplicable = true;
    String? other;
    for (final e in values) {
      if (e == '__NOT_APPLICABLE_INTERNAL__') {
        isApplicable = false;
        continue;
      }
      final asNum = int.tryParse(e);
      if (asNum == null) {
        other = e;
      } else {
        final type =
            PreInternshipRequestTypes._fromInt(asNum, Job._currentVersion);
        requests.add(type);
      }
    }

    return PreInternshipRequests(
        requests: requests, other: other, isApplicable: isApplicable);
  }

  PreInternshipRequests copyWith({
    String? id,
    List<PreInternshipRequestTypes>? requests,
    String? other,
    bool? isApplicable,
  }) {
    return PreInternshipRequests(
      id: id ?? this.id,
      requests: requests ?? this.requests,
      other: other ?? this.other,
      isApplicable: isApplicable ?? this.isApplicable,
    );
  }

  @override
  Map<String, dynamic> serializedMap() {
    return {
      'requests': requests.map((e) => e._toInt(Job._currentVersion)).toList(),
      'other': other,
      'is_applicable': isApplicable,
    };
  }

  static PreInternshipRequests fromSerialized(
    Map<String, dynamic> map,
    String version,
  ) {
    return PreInternshipRequests(
      id: map['id'] as String?,
      requests: ((map['requests'] as List<dynamic>?) ?? [])
          .map((e) => PreInternshipRequestTypes._fromInt(e, version))
          .toList(),
      other: map['other'] as String?,
      isApplicable: map['is_applicable'] as bool? ?? true,
    );
  }
}

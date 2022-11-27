import 'package:enhanced_containers/enhanced_containers.dart';

import '/common/models/internship.dart';

class InternshipsProvider extends FirebaseListProvided<Internship> {
  InternshipsProvider() : super(pathToData: "internships");

  @override
  Internship deserializeItem(data) {
    return Internship.fromSerialized(data);
  }
}

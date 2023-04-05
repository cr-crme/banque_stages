import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';

class EnterprisesProvider extends FirebaseListProvided<Enterprise> {
  EnterprisesProvider() : super(pathToData: 'enterprises') {
    initializeFetchingData();
  }

  static EnterprisesProvider of(BuildContext context, {listen = false}) =>
      Provider.of<EnterprisesProvider>(context, listen: listen);

  @override
  Enterprise deserializeItem(data) {
    return Enterprise.fromSerialized(data);
  }

  void replaceJob(enterprise, Job job) {
    this[enterprise].jobs.replace(job);
    replace(this[enterprise]);
  }
}

import 'package:common/communication_protocol.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/backend_list_provided.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnterprisesProvider extends BackendListProvided<Enterprise> {
  EnterprisesProvider({required super.uri, super.mockMe});

  static EnterprisesProvider of(BuildContext context, {listen = true}) =>
      Provider.of<EnterprisesProvider>(context, listen: listen);

  @override
  Enterprise deserializeItem(data) {
    return Enterprise.fromSerialized(data);
  }

  void replaceJob(enterprise, Job job) {
    this[enterprise].jobs.replace(job);
    replace(this[enterprise]);
  }

  @override
  RequestFields getField([bool asList = false]) =>
      asList ? RequestFields.enterprises : RequestFields.enterprise;

  void initializeAuth(AuthProvider auth) {
    initializeFetchingData(authProvider: auth);
  }
}

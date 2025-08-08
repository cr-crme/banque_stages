import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/enterprise_status.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/persons/person.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/program_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';
import '../utils.dart';

void main() {
  group('EnterprisesProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    ProgramInitializer.initialize(mockMe: true);

    test('"replaceJob" works', () {
      final enterprises =
          EnterprisesProvider(uri: Uri.parse('ws://localhost'), mockMe: true);
      enterprises.add(Enterprise(
        schoolBoardId: 'Test',
        name: 'Test Enterprise',
        status: EnterpriseStatus.active,
        activityTypes: {},
        recruiterId: 'Nobody',
        jobs: JobList()..add(dummyJob()),
        contact: Person(
          firstName: 'Not',
          middleName: 'A',
          lastName: 'Person',
          dateBirth: null,
          phone: PhoneNumber.empty,
          address: Address.empty,
          email: null,
        ),
      ));

      final enterprise = enterprises[0];
      expect(enterprise.jobs[0].minimumAge, 12);
      enterprises.replaceJob(
          enterprise, enterprise.jobs[0].copyWith(minimumAge: 2));
      expect(enterprise.jobs[0].minimumAge, 2);
    });

    test('"deserializeItem" works', () {
      final enterprises =
          EnterprisesProvider(uri: Uri.parse('ws://localhost'), mockMe: true);
      final enterprise =
          enterprises.deserializeItem({'name': 'Test Enterprise'});
      expect(enterprise.name, 'Test Enterprise');
    });

    testWidgets('can get "of" context', (tester) async {
      final context = await tester.contextWithNotifiers(withEnterprises: true);
      final enterprises = EnterprisesProvider.of(context, listen: false);
      expect(enterprises, isNotNull);
    });
  });
}

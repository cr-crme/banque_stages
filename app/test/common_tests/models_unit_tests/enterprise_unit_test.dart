import 'package:common/models/generic/phone_number.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job_list.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';
import '../utils.dart';

void main() {
  group('Enterprise', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('"copyWith" changes the requested elements', () {
      final enterprise = dummyEnterprise(addJob: true);

      final enterpriseSame = enterprise.copyWith();
      expect(enterpriseSame.id, enterprise.id);
      expect(enterpriseSame.name, enterprise.name);
      expect(enterpriseSame.activityTypes, enterprise.activityTypes);
      expect(enterpriseSame.recrutedBy, enterprise.recrutedBy);
      expect(enterpriseSame.shareWith, enterprise.shareWith);
      expect(enterpriseSame.jobs, enterprise.jobs);
      expect(enterpriseSame.contact, enterprise.contact);
      expect(enterpriseSame.contactFunction, enterprise.contactFunction);
      expect(enterpriseSame.address, enterprise.address);
      expect(enterpriseSame.phone, enterprise.phone);
      expect(enterpriseSame.fax, enterprise.fax);
      expect(enterpriseSame.website, enterprise.website);
      expect(
          enterpriseSame.headquartersAddress, enterprise.headquartersAddress);
      expect(enterpriseSame.neq, enterprise.neq);

      final enterpriseDifferent = enterprise.copyWith(
        id: 'newId',
        name: 'newName',
        activityTypes: {'newActivity'},
        recrutedBy: 'newRecrutedBy',
        shareWith: 'newShareWith',
        jobs: JobList()..add(dummyJob(id: 'newJobId')),
        contact: Person(firstName: 'Pariterre', lastName: 'Nobody'),
        contactFunction: 'newContactFunction',
        address: dummyAddress().copyWith(id: 'newAddressId'),
        phone: PhoneNumber.fromString('866-666-6666'),
        fax: PhoneNumber.fromString('866-666-6666'),
        website: 'newWebsite',
        headquartersAddress:
            dummyAddress().copyWith(id: 'newHeadquartersAddressId'),
        neq: 'newNeq',
      );

      expect(enterpriseDifferent.id, 'newId');
      expect(enterpriseDifferent.name, 'newName');
      expect(enterpriseDifferent.activityTypes, {'newActivity'});
      expect(enterpriseDifferent.recrutedBy, 'newRecrutedBy');
      expect(enterpriseDifferent.shareWith, 'newShareWith');
      expect(enterpriseDifferent.jobs[0].id, 'newJobId');
      expect(enterpriseDifferent.contact.fullName, 'Pariterre Nobody');
      expect(enterpriseDifferent.contactFunction, 'newContactFunction');
      expect(enterpriseDifferent.address!.id, 'newAddressId');
      expect(enterpriseDifferent.phone.toString(), '(866) 666-6666');
      expect(enterpriseDifferent.fax.toString(), '(866) 666-6666');
      expect(enterpriseDifferent.website, 'newWebsite');
      expect(enterpriseDifferent.headquartersAddress!.id,
          'newHeadquartersAddressId');
      expect(enterpriseDifferent.neq, 'newNeq');
    });

    testWidgets('"interships" behaves properly', (tester) async {
      final enterprise = dummyEnterprise(addJob: true);
      final context = await tester.contextWithNotifiers(withInternships: true);
      final internships = InternshipsProvider.of(context, listen: false);

      // Add an internship to another enterprise, which should not be counted
      internships.add(dummyInternship(
          id: 'anotherInternshipId',
          enterpriseId: 'anotherEnterpriseId',
          jobId: 'anotherJobId'));

      // No internships
      expect(enterprise.internships(context, listen: false).length, 0);

      // One internship
      internships.add(dummyInternship(
          enterpriseId: enterprise.id, jobId: enterprise.jobs[0].id));
      expect(enterprise.internships(context, listen: false).length, 1);

      // Two internships
      internships.add(dummyInternship(
          id: 'anotherInternshipId',
          enterpriseId: enterprise.id,
          jobId: enterprise.jobs[0].id));
      expect(enterprise.internships(context, listen: false).length, 2);

      // One internship is terminated, but still counts as an internship
      internships.replace(internships[1]
          .copyWith(endDate: DateTime.now().subtract(const Duration(days: 1))));
      expect(enterprise.internships(context, listen: false).length, 2);
    });

    testWidgets('"availableJobs" behaves properly', (tester) async {
      final enterprise = dummyEnterprise(addJob: true);
      final context = await tester.contextWithNotifiers(withInternships: true);
      final internships = InternshipsProvider.of(context, listen: false);

      // Add an internship to another enterprise, which should not be counted
      internships.add(dummyInternship(
          id: 'anotherInternshipId',
          enterpriseId: 'anotherEnterpriseId',
          jobId: 'anotherJobId'));

      // One job with two positions was created, so it should be available
      expect(enterprise.availableJobs(context).length, 1);

      // Fill one of that position, so it should still be available
      internships.add(dummyInternship(
          enterpriseId: enterprise.id, jobId: enterprise.jobs[0].id));
      expect(enterprise.availableJobs(context).length, 1);

      // Fill the remainning one, so it should not be available anymore
      internships.add(dummyInternship(
          id: 'anotherInternshipId',
          enterpriseId: enterprise.id,
          jobId: enterprise.jobs[0].id));
      expect(enterprise.availableJobs(context).length, 0);

      // Terminate one the of job, so it should be available again
      await internships.replace(internships[1]
          .copyWith(endDate: DateTime.now().subtract(const Duration(days: 1))));
      expect(enterprise.availableJobs(context).length, 1);
    });

    test('serialization and deserialization works', () {
      final enterprise = dummyEnterprise(addJob: true);
      final serialized = enterprise.serialize();
      final deserialized = Enterprise.fromSerialized(serialized);

      expect(serialized, {
        'id': enterprise.id,
        'name': enterprise.name,
        'activityTypes': enterprise.activityTypes.toList(),
        'recrutedBy': enterprise.recrutedBy,
        'shareWith': enterprise.shareWith,
        'jobs': enterprise.jobs.serialize(),
        'contact': enterprise.contact.serialize(),
        'contactFunction': enterprise.contactFunction,
        'address': enterprise.address?.serialize(),
        'phone': enterprise.phone.toString(),
        'fax': enterprise.fax.toString(),
        'website': enterprise.website,
        'headquartersAddress': enterprise.headquartersAddress?.serialize(),
        'neq': enterprise.neq,
      });

      expect(deserialized.id, enterprise.id);
      expect(deserialized.name, enterprise.name);
      expect(deserialized.activityTypes, enterprise.activityTypes);
      expect(deserialized.recrutedBy, enterprise.recrutedBy);
      expect(deserialized.shareWith, enterprise.shareWith);
      expect(deserialized.jobs[0].id, enterprise.jobs[0].id);
      expect(deserialized.contact.id, enterprise.contact.id);
      expect(deserialized.contactFunction, enterprise.contactFunction);
      expect(deserialized.address?.id, enterprise.address?.id);
      expect(deserialized.phone, enterprise.phone);
      expect(deserialized.fax, enterprise.fax);
      expect(deserialized.website, enterprise.website);
      expect(deserialized.headquartersAddress?.id,
          enterprise.headquartersAddress?.id);
      expect(deserialized.neq, enterprise.neq);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Enterprise.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.name, 'Unnamed enterprise');
      expect(emptyDeserialized.activityTypes, []);
      expect(emptyDeserialized.recrutedBy, 'Unnamed recruiter');
      expect(emptyDeserialized.shareWith, 'Unnamed sharing');
      expect(emptyDeserialized.jobs.length, 0);
      expect(emptyDeserialized.contact.firstName, 'Unnamed');
      expect(emptyDeserialized.contactFunction, '');
      expect(emptyDeserialized.address, isNull);
      expect(emptyDeserialized.phone, PhoneNumber.empty);
      expect(emptyDeserialized.fax, PhoneNumber.empty);
      expect(emptyDeserialized.website, '');
      expect(emptyDeserialized.headquartersAddress, isNull);
      expect(emptyDeserialized.neq, isNull);
    });
  });
}

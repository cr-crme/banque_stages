import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job_list.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/phone_number.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';
import 'utils.dart';

void main() {
  // TODO: Add tests for Person
  // TODO: Add tests for PhoneNumber
  // TODO: Add tests for JobList

  group('Address', () {
    test('is shown properly', () {
      expect(
          dummyAddress().toString(), '100 Wunderbar #A, Wonderland, H0H 0H0');
      expect(dummyAddress(skipAppartment: true).toString(),
          '100 Wunderbar, Wonderland, H0H 0H0');
    });

    test('"copyWith" changes the requested elements', () {
      final address = dummyAddress();

      final addressSame = address.copyWith();
      expect(addressSame.id, address.id);
      expect(addressSame.civicNumber, address.civicNumber);
      expect(addressSame.street, address.street);
      expect(addressSame.appartment, address.appartment);
      expect(addressSame.city, address.city);
      expect(addressSame.postalCode, address.postalCode);

      final addressDifferent = address.copyWith(
        id: 'newId',
        civicNumber: 200,
        street: 'Wonderbar',
        appartment: 'B',
        city: 'Wunderland',
        postalCode: 'H0H 0H1',
      );
      expect(addressDifferent.id, 'newId');
      expect(addressDifferent.civicNumber, 200);
      expect(addressDifferent.street, 'Wonderbar');
      expect(addressDifferent.appartment, 'B');
      expect(addressDifferent.city, 'Wunderland');
      expect(addressDifferent.postalCode, 'H0H 0H1');
    });

    test('"isEmpty" returns true when all fields are null', () {
      expect(Address().isEmpty, isTrue);
      expect(Address(civicNumber: 100).isEmpty, isFalse);
    });

    test('"isValid" if all fields are not null expect appartment', () {
      expect(dummyAddress().isValid, isTrue);
      expect(dummyAddress(skipCivicNumber: true).isValid, isFalse);
      expect(dummyAddress(skipAppartment: true).isValid, isTrue);
      expect(dummyAddress(skipStreet: true).isValid, isFalse);
      expect(dummyAddress(skipCity: true).isValid, isFalse);
      expect(dummyAddress(skipPostalCode: true).isValid, isFalse);
    });

    test('serialization and deserialization works', () {
      final address = dummyAddress();
      final serialized = address.serialize();
      final deserialized = Address.fromSerialized(serialized);

      expect(serialized, {
        'id': address.id,
        'number': address.civicNumber,
        'street': address.street,
        'appartment': address.appartment,
        'city': address.city,
        'postalCode': address.postalCode
      });

      expect(deserialized.id, address.id);
      expect(deserialized.civicNumber, address.civicNumber);
      expect(deserialized.street, address.street);
      expect(deserialized.appartment, address.appartment);
      expect(deserialized.city, address.city);
      expect(deserialized.postalCode, address.postalCode);
    });
  });

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
      internships.replace(internships[1]
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
    });
  });
}

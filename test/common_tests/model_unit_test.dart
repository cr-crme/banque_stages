import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/incidents.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/models/job_list.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/phone_number.dart';
import 'package:crcrme_banque_stages/common/models/pre_internship_request.dart';
import 'package:crcrme_banque_stages/common/models/protections.dart';
import 'package:crcrme_banque_stages/common/models/uniform.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';
import 'utils.dart';

void main() {
  group('Person', () {
    test('default is empty', () {
      final person = Person.empty;
      expect(person.firstName, '');
      expect(person.middleName, isNull);
      expect(person.lastName, '');
      expect(person.dateBirth, isNull);
      expect(person.phone, PhoneNumber.empty);
      expect(person.email, isNull);
      expect(person.address, isNull);

      expect(person.toString(), '');
      expect(person.fullName, '');
    });

    test('is shown properly', () {
      final person = dummyPerson();
      expect(person.toString(), 'Jeanne Kathlin Doe');
      expect(person.fullName, 'Jeanne Doe');
    });

    test('"copyWith" changes the requested elements', () {
      final person = dummyPerson();

      final personSame = person.copyWith();
      expect(personSame.id, person.id);
      expect(personSame.firstName, person.firstName);
      expect(personSame.lastName, person.lastName);
      expect(personSame.email, person.email);
      expect(personSame.phone, person.phone);
      expect(personSame.address, person.address);

      final personDifferent = person.copyWith(
        id: 'newId',
        firstName: 'newFirstName',
        lastName: 'newLastName',
        email: 'newEmail',
        phone: PhoneNumber.fromString('866-666-6666'),
        address: dummyAddress().copyWith(id: 'newAddressId'),
      );

      expect(personDifferent.id, 'newId');
      expect(personDifferent.firstName, 'newFirstName');
      expect(personDifferent.lastName, 'newLastName');
      expect(personDifferent.email, 'newEmail');
      expect(personDifferent.phone.toString(), '(866) 666-6666');
      expect(personDifferent.address!.id, 'newAddressId');
    });

    test('serialize and deserialize works', () {
      final person = dummyPerson();
      final serialized = person.serialize();
      final deserialized = Person.fromSerialized(serialized);

      expect(serialized, {
        'id': person.id,
        'firstName': person.firstName,
        'middleName': person.middleName,
        'lastName': person.lastName,
        'birthDate': person.dateBirth?.millisecondsSinceEpoch ?? -1,
        'phone': person.phone.toString(),
        'email': person.email,
        'address': person.address?.serialize(),
      });

      expect(deserialized.id, person.id);
      expect(deserialized.firstName, person.firstName);
      expect(deserialized.middleName, person.middleName);
      expect(deserialized.lastName, person.lastName);
      expect(deserialized.dateBirth, person.dateBirth);
      expect(deserialized.phone.toString(), person.phone.toString());
      expect(deserialized.email, person.email);
      expect(deserialized.address?.id, person.address?.id);
    });
  });

  group('PhoneNumber', () {
    test('is valid', () {
      expect(PhoneNumber.isValid('8005555555'), isTrue);
      expect(PhoneNumber.isValid('800-555-5555'), isTrue);
      expect(PhoneNumber.isValid('800 555 5555'), isTrue);
      expect(PhoneNumber.isValid('800.555.5555'), isTrue);
      expect(PhoneNumber.isValid('(800) 555-5555'), isTrue);
      expect(PhoneNumber.isValid('(800) 555-5555 poste 1234'), isTrue);
      expect(PhoneNumber.isValid('8005555555 poste 123456'), isTrue);
    });

    test('is invalid', () {
      expect(PhoneNumber.isValid('800-555-555'), isFalse);
      expect(PhoneNumber.isValid('800-555-55555'), isFalse);
      expect(PhoneNumber.isValid('800-555-5555 poste 1234567'), isFalse);
    });

    test('is shown properly', () {
      expect(
          PhoneNumber.fromString('800-555-5555').toString(), '(800) 555-5555');
      expect(
          PhoneNumber.fromString('800 555 5555').toString(), '(800) 555-5555');
      expect(
          PhoneNumber.fromString('800.555.5555').toString(), '(800) 555-5555');
      expect(PhoneNumber.fromString('8005555555').toString(), '(800) 555-5555');
      expect(PhoneNumber.fromString('800-555-5555 poste 123456').toString(),
          '(800) 555-5555 poste 123456');
    });
  });

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

  group('Uniform', () {
    test('serialization and deserialization works', () {
      final uniform = dummyUniform();
      final serialized = uniform.serialize();
      final deserialized = Uniform.fromSerialized(serialized);

      expect(serialized, {
        'id': uniform.id,
        'status': uniform.status.index,
        'uniform': uniform.uniforms.join('\n'),
      });

      expect(deserialized.id, uniform.id);
      expect(deserialized.status, uniform.status);
      expect(deserialized.uniforms, uniform.uniforms);
    });
  });

  group('Protections', () {
    test('serialization and deserialization works', () {
      final protections = dummyProtections();
      final serialized = protections.serialize();
      final deserialized = Protections.fromSerialized(serialized);

      expect(serialized, {
        'id': protections.id,
        'protections': protections.protections,
        'status': protections.status.index,
      });

      expect(deserialized.id, protections.id);
      expect(deserialized.protections, protections.protections);
    });
  });

  group('Incidents', () {
    test('serialization and deserialization works', () {
      final incidents = dummyIncidents();
      final serialized = incidents.serialize();
      final deserialized = Incidents.fromSerialized(serialized);

      expect(serialized, {
        'id': incidents.id,
        'severeInjuries': incidents.severeInjuries.map((e) => e.serialize()),
        'verbalAbuses': incidents.verbalAbuses.map((e) => e.serialize()),
        'minorInjuries': incidents.minorInjuries.map((e) => e.serialize()),
      });

      expect(deserialized.id, incidents.id);
      expect(deserialized.severeInjuries, incidents.severeInjuries);
      expect(deserialized.verbalAbuses.toString(),
          incidents.verbalAbuses.toString());
      expect(deserialized.minorInjuries.toString(),
          incidents.minorInjuries.toString());
    });
  });

  group('SstEvaluation', () {
    test('empty one is tagged non-filled', () {
      final sstEvaluation = JobSstEvaluation.empty;
      expect(sstEvaluation.isFilled, isFalse);

      sstEvaluation.update(questions: {'Q1': 'My answer'});
      expect(sstEvaluation.isFilled, isTrue);
    });

    test('"update" erases old answers', () {
      final sstEvaluation = JobSstEvaluation.empty;
      sstEvaluation.update(questions: {'Q1': 'My first answer'});
      expect(sstEvaluation.questions.length, 1);

      sstEvaluation.update(questions: {'Q2': 'My second first answer'});
      expect(sstEvaluation.questions.length, 1);

      sstEvaluation.update(
          questions: {'Q1': 'My first answer', 'Q2': 'My true second answer'});
      expect(sstEvaluation.questions.length, 2);
    });

    test('serialization and deserialization works', () {
      final sstEvaluation = dummyJobSstEvaluation();
      final serialized = sstEvaluation.serialize();
      final deserialized = JobSstEvaluation.fromSerialized(serialized);

      expect(serialized, {
        'id': sstEvaluation.id,
        'questions': sstEvaluation.questions,
        'date': DateTime(2000, 1, 1).millisecondsSinceEpoch,
      });

      expect(deserialized.id, sstEvaluation.id);
      expect(deserialized.questions, sstEvaluation.questions);
    });
  });

  group('PreInternshipRequest', () {
    test('serialization and deserialization works', () {
      final preInternshipRequest = dummyPreInternshipRequest();
      final serialized = preInternshipRequest.serialize();
      final deserialized = PreInternshipRequest.fromSerialized(serialized);

      expect(serialized, {
        'id': preInternshipRequest.id,
        'requests': preInternshipRequest.requests,
      });

      expect(deserialized.id, preInternshipRequest.id);
      expect(deserialized.requests, preInternshipRequest.requests);
    });
  });

  group('JobList', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('has the rigt amount', () {
      final jobList = dummyJobList();
      expect(jobList.length, 1);
    });

    test('serialize and deserialize works', () {
      final jobList = dummyJobList();
      jobList.add(dummyJob(id: 'newJobId'));
      final serialized = jobList.serialize();
      final deserialized = JobList.fromSerialized(serialized);

      expect(serialized, {
        for (var e in jobList)
          e.id: {
            'id': e.id,
            'specialization': e.specialization.id,
            'positionsOffered': e.positionsOffered,
            'minimumAge': e.minimumAge,
            'preInternshipRequest': e.preInternshipRequest.serialize(),
            'uniform': e.uniform.serialize(),
            'protections': e.protections.serialize(),
            'photosUrl': e.photosUrl,
            'sstEvaluations': e.sstEvaluation.serialize(),
            'incidents': e.incidents.serialize(),
            'comments': e.comments,
          }
      });

      expect(deserialized[0].id, jobList[0].id);
      expect(deserialized[0].specialization.id, jobList[0].specialization.id);
      expect(deserialized[0].positionsOffered, jobList[0].positionsOffered);
      expect(deserialized[0].sstEvaluation.id, jobList[0].sstEvaluation.id);
      expect(deserialized[0].incidents.id, jobList[0].incidents.id);
      expect(deserialized[0].minimumAge, jobList[0].minimumAge);
      expect(deserialized[0].preInternshipRequest.id,
          jobList[0].preInternshipRequest.id);
      expect(deserialized[0].uniform.id, jobList[0].uniform.id);
      expect(deserialized[0].protections.id, jobList[0].protections.id);
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

import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/incidents.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/models/job_list.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/phone_number.dart';
import 'package:crcrme_banque_stages/common/models/pre_internship_request.dart';
import 'package:crcrme_banque_stages/common/models/protections.dart';
import 'package:crcrme_banque_stages/common/models/school.dart';
import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/models/task_appreciation.dart';
import 'package:crcrme_banque_stages/common/models/teacher.dart';
import 'package:crcrme_banque_stages/common/models/uniform.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/common/models/waypoints.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:routing_client_dart/routing_client_dart.dart';

import '../utils.dart';
import 'utils.dart';

void main() {
  group('School', () {
    test('"copyWith" changes the requested elements', () {
      final school = dummySchool();

      final schoolSame = school.copyWith();
      expect(schoolSame.id, school.id);
      expect(schoolSame.name, school.name);
      expect(schoolSame.address, school.address);

      final schoolDifferent = school.copyWith(
        id: 'newId',
        name: 'newName',
        address: dummyAddress().copyWith(id: 'newAddressId'),
      );

      expect(schoolDifferent.id, 'newId');
      expect(schoolDifferent.name, 'newName');
      expect(schoolDifferent.address.id, 'newAddressId');
    });

    test('serialization and deserialization works', () {
      final school = dummySchool();
      final serialized = school.serialize();
      final deserialized = School.fromSerialized(serialized);

      expect(serialized, {
        'id': school.id,
        'name': school.name,
        'address': school.address.serialize(),
      });

      expect(deserialized.id, school.id);
      expect(deserialized.name, school.name);
      expect(deserialized.address.id, school.address.id);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = School.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.name, 'Unnamed school');
      expect(emptyDeserialized.address.toString(), Address.empty.toString());
    });
  });

  group('Teacher', () {
    test('"copyWith" changes the requested elements', () {
      final teacher = dummyTeacher();

      final teacherSame = teacher.copyWith();
      expect(teacherSame.id, teacher.id);
      expect(teacherSame.firstName, teacher.firstName);
      expect(teacherSame.middleName, teacher.middleName);
      expect(teacherSame.lastName, teacher.lastName);
      expect(teacherSame.schoolId, teacher.schoolId);
      expect(teacherSame.groups, teacher.groups);
      expect(teacherSame.email, teacher.email);
      expect(teacherSame.phone, teacher.phone);

      expect(teacherSame.address, isNull);
      expect(teacherSame.dateBirth, isNull);

      final teacherDifferent = teacher.copyWith(
        id: 'newId',
        firstName: 'newFirstName',
        middleName: 'newMiddleName',
        lastName: 'newLastName',
        schoolId: 'newSchoolId',
        groups: ['newGroup'],
        email: 'newEmail',
        phone: PhoneNumber.fromString('866-666-6666'),
      );

      expect(teacherDifferent.id, 'newId');
      expect(teacherDifferent.firstName, 'newFirstName');
      expect(teacherDifferent.middleName, 'newMiddleName');
      expect(teacherDifferent.lastName, 'newLastName');
      expect(teacherDifferent.schoolId, 'newSchoolId');
      expect(teacherDifferent.groups, ['newGroup']);
      expect(teacherDifferent.email, 'newEmail');
      expect(teacherDifferent.phone.toString(), '(866) 666-6666');

      // Expect throw on changes
      expect(
          () => teacher.copyWith(address: dummyAddress()), throwsArgumentError);
      expect(
          () => teacher.copyWith(dateBirth: DateTime(0)), throwsArgumentError);
    });

    test('serialization and deserialization works', () {
      final teacher = dummyTeacher();
      final serialized = teacher.serialize();
      final deserialized = Teacher.fromSerialized(serialized);

      expect(serialized, {
        'id': teacher.id,
        'firstName': teacher.firstName,
        'middleName': teacher.middleName,
        'lastName': teacher.lastName,
        'schoolId': teacher.schoolId,
        'groups': teacher.groups,
        'email': teacher.email,
        'phone': teacher.phone.toString(),
        'dateBirth': null,
        'address': null,
      });

      expect(deserialized.id, teacher.id);
      expect(deserialized.firstName, teacher.firstName);
      expect(deserialized.middleName, teacher.middleName);
      expect(deserialized.lastName, teacher.lastName);
      expect(deserialized.schoolId, teacher.schoolId);
      expect(deserialized.groups, teacher.groups);
      expect(deserialized.email, teacher.email);
      expect(deserialized.phone.toString(), teacher.phone.toString());

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Teacher.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.firstName, 'Unnamed');
      expect(emptyDeserialized.middleName, isNull);
      expect(emptyDeserialized.lastName, 'Unnamed');
      expect(emptyDeserialized.schoolId, '');
      expect(emptyDeserialized.groups, []);
      expect(emptyDeserialized.email, isNull);
      expect(emptyDeserialized.phone, PhoneNumber.empty);
    });
  });

  group('Student', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('"Program" is shown properly', () {
      expect(Program.values.length, 3);
      expect(Program.fpt.toString(), 'FPT');
      expect(Program.fms.toString(), 'FMS');
      expect(Program.undefined.toString(), 'Undefined');
    });

    testWidgets('"asActive" behaves properly', (tester) async {
      final context = await tester.contextWithNotifiers(withInternships: true);
      final student = dummyStudent();

      // Add an internship to another student
      InternshipsProvider.of(context, listen: false)
          .add(dummyInternship(studentId: 'anotherStudentId'));

      // Start without an internship
      expect(student.hasActiveInternship(context), isFalse);

      // Add an internship to the student
      InternshipsProvider.of(context, listen: false)
          .add(dummyInternship(studentId: student.id));

      // Now the student has an internship
      expect(student.hasActiveInternship(context), isTrue);
    });

    test('"limitedInfo" provides less information', () {
      final student = dummyStudent();
      final limitedInfo = student.limitedInfo;

      expect(limitedInfo.id, student.id);
      expect(limitedInfo.firstName, student.firstName);
      expect(limitedInfo.middleName, student.middleName);
      expect(limitedInfo.lastName, student.lastName);
      expect(limitedInfo.group, student.group);
      expect(limitedInfo.program, student.program);
      expect(limitedInfo.address, isNull);
      expect(limitedInfo.contact.toString(), Person.empty.toString());
      expect(limitedInfo.contactLink, '');
      expect(limitedInfo.dateBirth, isNull);
      expect(limitedInfo.email, isNull);
      expect(limitedInfo.phone, PhoneNumber.empty);
    });

    test('"copyWith" behave properly', () {
      final student = dummyStudent();

      final studentSame = student.copyWith();
      expect(studentSame.id, student.id);
      expect(studentSame.firstName, student.firstName);
      expect(studentSame.middleName, student.middleName);
      expect(studentSame.lastName, student.lastName);
      expect(studentSame.dateBirth, student.dateBirth);
      expect(studentSame.phone, student.phone);
      expect(studentSame.email, student.email);
      expect(studentSame.group, student.group);
      expect(studentSame.address, student.address);
      expect(studentSame.photo, student.photo);
      expect(studentSame.program, student.program);
      expect(studentSame.contact, student.contact);
      expect(studentSame.contactLink, student.contactLink);

      final studentDifferent = student.copyWith(
        id: 'newId',
        firstName: 'newFirstName',
        middleName: 'newMiddleName',
        lastName: 'newLastName',
        dateBirth: DateTime(2001, 1, 1),
        phone: PhoneNumber.fromString('866-666-6666'),
        email: 'newEmail',
        address: dummyAddress().copyWith(id: 'newAddressId'),
        photo: '0xFF0000',
        program: Program.fms,
        group: 'newGroup',
        contact: dummyPerson().copyWith(id: 'newContactId'),
        contactLink: 'newContactLink',
      );

      expect(studentDifferent.id, 'newId');
      expect(studentDifferent.firstName, 'newFirstName');
      expect(studentDifferent.middleName, 'newMiddleName');
      expect(studentDifferent.lastName, 'newLastName');
      expect(studentDifferent.dateBirth, DateTime(2001, 1, 1));
      expect(studentDifferent.phone.toString(), '(866) 666-6666');
      expect(studentDifferent.email, 'newEmail');
      expect(studentDifferent.address!.id, 'newAddressId');
      expect(studentDifferent.photo.toString(), '0xFF0000');
      expect(studentDifferent.program, Program.fms);
      expect(studentDifferent.group, 'newGroup');
      expect(studentDifferent.contact.id, 'newContactId');
      expect(studentDifferent.contactLink, 'newContactLink');
    });

    test('serialization and deserialization works', () {
      final student = dummyStudent();
      final serialized = student.serialize();
      final deserialized = Student.fromSerialized(serialized);

      expect(serialized, {
        'id': student.id,
        'firstName': student.firstName,
        'middleName': student.middleName,
        'lastName': student.lastName,
        'dateBirth': student.dateBirth!.millisecondsSinceEpoch,
        'phone': student.phone.toString(),
        'email': student.email,
        'address': student.address?.serialize(),
        'photo': student.photo,
        'program': student.program.index,
        'group': student.group,
        'contact': student.contact.serialize(),
        'contactLink': student.contactLink,
      });

      expect(deserialized.id, student.id);
      expect(deserialized.firstName, student.firstName);
      expect(deserialized.middleName, student.middleName);
      expect(deserialized.lastName, student.lastName);
      expect(deserialized.dateBirth, student.dateBirth);
      expect(deserialized.phone.toString(), student.phone.toString());
      expect(deserialized.email, student.email);
      expect(deserialized.address?.id, student.address?.id);
      expect(deserialized.photo, student.photo);
      expect(deserialized.program, student.program);
      expect(deserialized.group, student.group);
      expect(deserialized.contact.id, student.contact.id);
      expect(deserialized.contactLink, student.contactLink);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Student.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.firstName, 'Unnamed');
      expect(emptyDeserialized.middleName, isNull);
      expect(emptyDeserialized.lastName, 'Unnamed');
      expect(emptyDeserialized.dateBirth, isNull);
      expect(emptyDeserialized.phone, PhoneNumber.empty);
      expect(emptyDeserialized.email, isNull);
      expect(emptyDeserialized.address, isNull);
      expect(int.parse(emptyDeserialized.photo), greaterThanOrEqualTo(0));
      expect(int.parse(emptyDeserialized.photo), lessThanOrEqualTo(0xFFFFFF));
      expect(emptyDeserialized.program, Program.undefined);
      expect(emptyDeserialized.group, '');
      expect(emptyDeserialized.contact.toString(), Person.empty.toString());
      expect(emptyDeserialized.contactLink, '');
    });
  });

  group('Person', () {
    test('default is empty', () {
      final person = Person.empty;
      expect(person.firstName, 'Unnamed');
      expect(person.middleName, isNull);
      expect(person.lastName, 'Unnamed');
      expect(person.dateBirth, isNull);
      expect(person.phone, PhoneNumber.empty);
      expect(person.email, isNull);
      expect(person.address, isNull);

      expect(person.toString(), Person.empty.toString());
      expect(person.fullName, 'Unnamed Unnamed');
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

    test('serialization and deserialization works', () {
      final person = dummyPerson();
      final serialized = person.serialize();
      final deserialized = Person.fromSerialized(serialized);

      expect(serialized, {
        'id': person.id,
        'firstName': person.firstName,
        'middleName': person.middleName,
        'lastName': person.lastName,
        'dateBirth': person.dateBirth?.millisecondsSinceEpoch ?? -1,
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

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Person.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.firstName, 'Unnamed');
      expect(emptyDeserialized.middleName, isNull);
      expect(emptyDeserialized.lastName, 'Unnamed');
      expect(emptyDeserialized.dateBirth, isNull);
      expect(emptyDeserialized.phone, PhoneNumber.empty);
      expect(emptyDeserialized.email, isNull);
      expect(emptyDeserialized.address, isNull);
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
      expect(Address.empty.isEmpty, isTrue);
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

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Address.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.civicNumber, isNull);
      expect(emptyDeserialized.street, isNull);
      expect(emptyDeserialized.appartment, isNull);
      expect(emptyDeserialized.city, isNull);
      expect(emptyDeserialized.postalCode, isNull);
    });
  });

  group('Uniform', () {
    test('"statuses" are the right label', () {
      expect(UniformStatus.values.length, 3);
      expect(UniformStatus.suppliedByEnterprise.toString(),
          'Oui et l\'entreprise la fournit');
      expect(UniformStatus.suppliedByStudent.toString(),
          'Oui mais l\'entreprise ne la fournit pas');
      expect(UniformStatus.none.toString(), 'Non');
    });

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

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Uniform.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.status, UniformStatus.none);
      expect(emptyDeserialized.uniforms, []);
    });
  });

  group('Protections', () {
    test('"statuses" are the right label', () {
      expect(ProtectionsStatus.values.length, 3);
      expect(ProtectionsStatus.suppliedByEnterprise.toString(),
          'Oui et l\'entreprise les fournit');
      expect(ProtectionsStatus.suppliedBySchool.toString(),
          'Oui mais l\'entreprise ne les fournit pas');
      expect(ProtectionsStatus.none.toString(), 'Non');
    });

    test('"types" are the right lable', () {
      expect(ProtectionsType.values.length, 7);
      expect(ProtectionsType.steelToeShoes.toString(),
          'Chaussures à cap d\'acier');
      expect(ProtectionsType.nonSlipSoleShoes.toString(),
          'Chaussures à semelles antidérapantes');
      expect(ProtectionsType.safetyGlasses.toString(), 'Lunettes de sécurité');
      expect(ProtectionsType.earProtection.toString(), 'Protections auditives');
      expect(ProtectionsType.mask.toString(), 'Masque');
      expect(ProtectionsType.helmet.toString(), 'Casque');
      expect(ProtectionsType.gloves.toString(), 'Gants');
    });

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

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Protections.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.protections, []);
      expect(emptyDeserialized.status, ProtectionsStatus.none);
    });
  });

  group('Incidents', () {
    test('"isEmpty" behaves properly', () {
      expect(Incidents().isEmpty, isTrue);
      expect(Incidents().isNotEmpty, isFalse);
      expect(Incidents(severeInjuries: [Incident('Not important')]).isEmpty,
          isFalse);
      expect(Incidents(verbalAbuses: [Incident('Not important')]).isEmpty,
          isFalse);
      expect(Incidents(minorInjuries: [Incident('Not important')]).isEmpty,
          isFalse);
    });

    test('can get all', () {
      final incidents = dummyIncidents();
      expect(incidents.all.length, 3);
    });

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

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Incidents.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.severeInjuries, []);
      expect(emptyDeserialized.verbalAbuses, []);
      expect(emptyDeserialized.minorInjuries, []);
    });

    test('serialization and deserialization of Incident works', () {
      final incident =
          Incident('Je ne désire pas décrire...', date: DateTime(2000));
      final serialized = incident.serialize();
      final deserialized = Incident.fromSerialized(serialized);

      expect(serialized, {
        'id': incident.id,
        'incident': incident.incident,
        'date': incident.date.millisecondsSinceEpoch,
      });

      expect(deserialized.id, incident.id);
      expect(deserialized.incident, incident.incident);
      expect(deserialized.date, incident.date);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Incident.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.incident, '');
      expect(emptyDeserialized.date, DateTime(0));
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

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized =
          JobSstEvaluation.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.questions, {});
      expect(emptyDeserialized.date.millisecondsSinceEpoch, 0);
    });
  });

  group('PreInternshipRequest', () {
    test('"types" are the right label', () {
      expect(PreInternshipRequestType.values.length, 2);
      expect(PreInternshipRequestType.soloInterview.toString(),
          'Une entrevue de recrutement de l\'élève en solo');
      expect(PreInternshipRequestType.judiciaryBackgroundCheck.toString(),
          'Une vérification des antécédents judiciaires pour les élèves majeurs');
    });

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

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized =
          PreInternshipRequest.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.requests, []);
    });
  });

  group('TaskAppreciation', () {
    test('"abbreviations" are the right label', () {
      expect(TaskAppreciationLevel.values.length, 6);
      expect(TaskAppreciationLevel.autonomous.abbreviation(), 'A');
      expect(TaskAppreciationLevel.withReminder.abbreviation(), 'B');
      expect(TaskAppreciationLevel.withHelp.abbreviation(), 'C');
      expect(TaskAppreciationLevel.withConstantHelp.abbreviation(), 'D');
      expect(TaskAppreciationLevel.notEvaluated.abbreviation(), 'NF');
      expect(TaskAppreciationLevel.evaluated.abbreviation(), '');
    });

    test('is shown properly', () {
      expect(TaskAppreciationLevel.autonomous.toString(), 'De façon autonome');
      expect(TaskAppreciationLevel.withReminder.toString(), 'Avec rappel');
      expect(TaskAppreciationLevel.withHelp.toString(),
          'Avec de l\'aide occasionnelle');
      expect(TaskAppreciationLevel.withConstantHelp.toString(),
          'Avec de l\'aide constante');
      expect(
          TaskAppreciationLevel.notEvaluated.toString(),
          'Non faite (élève ne fait pas encore la tâche ou cette tâche '
          'n\'est pas offerte dans le milieu)');
      expect(TaskAppreciationLevel.evaluated.toString(), '');
    });

    test('serialization and deserialization works', () {
      final taskAppreciation = TaskAppreciation(
          title: 'Task title', level: TaskAppreciationLevel.autonomous);
      final serialized = taskAppreciation.serialize();
      final deserialized = TaskAppreciation.fromSerialized(serialized);

      expect(serialized, {
        'id': taskAppreciation.id,
        'title': taskAppreciation.title,
        'level': taskAppreciation.level.index,
      });

      expect(deserialized.id, taskAppreciation.id);
      expect(deserialized.title, taskAppreciation.title);
      expect(deserialized.level, taskAppreciation.level);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized =
          TaskAppreciation.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.title, '');
      expect(emptyDeserialized.level, TaskAppreciationLevel.notEvaluated);
    });
  });

  group('VisitingPriorities', () {
    test('"next" behaves properly', () {
      expect(VisitingPriority.low.next, VisitingPriority.high);
      expect(VisitingPriority.mid.next, VisitingPriority.low);
      expect(VisitingPriority.high.next, VisitingPriority.mid);

      // Test the side effects as well
      expect(VisitingPriority.school.next, VisitingPriority.low);
      expect(VisitingPriority.notApplicable.next, VisitingPriority.high);
    });

    test('is the right color', () {
      expect(VisitingPriority.low.color, Colors.green);
      expect(VisitingPriority.mid.color, Colors.orange);
      expect(VisitingPriority.high.color, Colors.red);
      expect(VisitingPriority.school.color, Colors.purple);
      expect(VisitingPriority.notApplicable.color, Colors.grey);
    });

    test('is the right icon', () {
      expect(VisitingPriority.low.icon, Icons.looks_3);
      expect(VisitingPriority.mid.icon, Icons.looks_two);
      expect(VisitingPriority.high.icon, Icons.looks_one);
      expect(VisitingPriority.school.icon, Icons.school);
      expect(VisitingPriority.notApplicable.icon, Icons.cancel);
    });
  });

  group('Job and JobList', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    testWidgets('can get evaluation of all enterprises', (tester) async {
      final context = await tester.contextWithNotifiers(withInternships: true);
      final job = dummyJob();

      // No evaluation yet
      expect(job.postInternshipEnterpriseEvaluations(context).length, 0);

      // Add an evaluation
      InternshipsProvider.of(context, listen: false).add(dummyInternship());
      expect(job.postInternshipEnterpriseEvaluations(context).length, 1);
    });

    test('"copyWith" behaves properly', () {
      final job = dummyJob();

      final jobSame = job.copyWith();
      expect(jobSame.id, job.id);
      expect(jobSame.specialization, job.specialization);
      expect(jobSame.positionsOffered, job.positionsOffered);
      expect(jobSame.minimumAge, job.minimumAge);
      expect(jobSame.preInternshipRequest, job.preInternshipRequest);
      expect(jobSame.uniform, job.uniform);
      expect(jobSame.protections, job.protections);
      expect(jobSame.photosUrl, job.photosUrl);
      expect(jobSame.sstEvaluation, job.sstEvaluation);
      expect(jobSame.incidents, job.incidents);
      expect(jobSame.comments, job.comments);

      final jobDifferent = job.copyWith(
        id: 'newId',
        specialization: ActivitySectorsService.sectors[2].specializations[8],
        positionsOffered: 2,
        minimumAge: 12,
        preInternshipRequest:
            dummyPreInternshipRequest(id: 'newPreInternshipId'),
        uniform: dummyUniform(id: 'newUniformId'),
        protections: dummyProtections(id: 'newProtectionsId'),
        photosUrl: ['newUrl'],
        sstEvaluation: dummyJobSstEvaluation(id: 'newSstEvaluationId'),
        incidents: dummyIncidents(id: 'newIncidentsId'),
        comments: ['newComment'],
      );

      expect(jobDifferent.id, 'newId');
      expect(jobDifferent.specialization.id,
          ActivitySectorsService.sectors[2].specializations[8].id);
      expect(jobDifferent.positionsOffered, 2);
      expect(jobDifferent.minimumAge, 12);
      expect(jobDifferent.preInternshipRequest.id, 'newPreInternshipId');
      expect(jobDifferent.uniform.id, 'newUniformId');
      expect(jobDifferent.protections.id, 'newProtectionsId');
      expect(jobDifferent.photosUrl, ['newUrl']);
      expect(jobDifferent.sstEvaluation.id, 'newSstEvaluationId');
      expect(jobDifferent.incidents.id, 'newIncidentsId');
      expect(jobDifferent.comments, ['newComment']);
    });

    test('has the rigt amount', () {
      final jobList = dummyJobList();
      expect(jobList.length, 1);
    });

    test('serialization and deserialization works', () {
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

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = JobList.fromSerialized({});
      expect(emptyDeserialized.length, 0);
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

  group('Waypoint', () {
    test('"toString" behaves properly', () {
      final waypoint = dummyWaypoint();
      expect(waypoint.toString(), 'Subtitle\n123 rue de la rue\nVille H0H 0H0');
    });

    test('"fromCoordinates" constructor behaves properly', () async {
      // This test is expected to build a Waypoint different from the sent dummy
      // because it uses the geocoding service which we can't test so far
      final waypoint = await Waypoint.fromCoordinates(
        latitude: 1.0,
        longitude: 2.0,
        title: 'title',
      );

      // Test that the waypoint is the default value for the Placemark (address)
      expect(waypoint.id, isNotEmpty);
      expect(waypoint.title, 'title');
      expect(waypoint.subtitle, isNull);
      expect(waypoint.latitude, 1.0);
      expect(waypoint.longitude, 2.0);
      expect(waypoint.address.toString(), Placemark().toString());
      expect(waypoint.priority, VisitingPriority.notApplicable);
      expect(waypoint.showTitle, isTrue);
    });

    test('"fromAddress" constructor behaves properly', () async {
      // This test is expected to build a Waypoint different from the sent dummy
      // because it uses the geocoding service which we can't test so far
      final waypoint = await Waypoint.fromAddress(
          title: 'My wonderful place', address: 'Here');

      // Test that the waypoint is the default value for the Placemark (address)
      expect(waypoint.id, isNotEmpty);
      expect(waypoint.title, 'My wonderful place');
      expect(waypoint.subtitle, isNull);
      expect(waypoint.latitude, 0.0);
      expect(waypoint.longitude, 0.0);
      expect(waypoint.address.toString(), Placemark().toString());
      expect(waypoint.priority, VisitingPriority.notApplicable);
      expect(waypoint.showTitle, isTrue);
    });

    test('"fromLatLng" constructor behaves properly', () async {
      // This test is expected to build a Waypoint different from the sent dummy
      // because it uses the geocoding service which we can't test so far
      final waypoint = await Waypoint.fromLatLng(
          title: 'My wonderful place', point: LatLng(1.0, 2.0));

      // Test that the waypoint is the default value for the Placemark (address)
      expect(waypoint.id, isNotEmpty);
      expect(waypoint.title, 'My wonderful place');
      expect(waypoint.subtitle, isNull);
      expect(waypoint.latitude, 1.0);
      expect(waypoint.longitude, 2.0);
      expect(waypoint.address.toString(), Placemark().toString());
      expect(waypoint.priority, VisitingPriority.notApplicable);
      expect(waypoint.showTitle, isTrue);
    });

    test('"fromLngLat" constructor behaves properly', () async {
      // This test is expected to build a Waypoint different from the sent dummy
      // because it uses the geocoding service which we can't test so far
      final waypoint = await Waypoint.fromLngLat(
          title: 'My wonderful place', point: LngLat(lat: 1.0, lng: 2.0));

      // Test that the waypoint is the default value for the Placemark (address)
      expect(waypoint.id, isNotEmpty);
      expect(waypoint.title, 'My wonderful place');
      expect(waypoint.subtitle, isNull);
      expect(waypoint.latitude, 1.0);
      expect(waypoint.longitude, 2.0);
      expect(waypoint.address.toString(), Placemark().toString());
      expect(waypoint.priority, VisitingPriority.notApplicable);
      expect(waypoint.showTitle, isTrue);
    });

    test('"toLatLng" and "toLngLat" behave properly', () {
      final waypoint = dummyWaypoint();
      final latLng = waypoint.toLatLng();
      final lngLat = waypoint.toLngLat();

      expect(latLng.latitude, waypoint.latitude);
      expect(latLng.longitude, waypoint.longitude);
      expect(lngLat.lat, waypoint.latitude);
      expect(lngLat.lng, waypoint.longitude);
    });

    test('"copyWith" behaves properly', () {
      final waypoint = dummyWaypoint();

      final waypointSame = waypoint.copyWith();
      expect(waypointSame.id, waypoint.id);
      expect(waypointSame.title, waypoint.title);
      expect(waypointSame.subtitle, waypoint.subtitle);
      expect(waypointSame.latitude, waypoint.latitude);
      expect(waypointSame.longitude, waypoint.longitude);
      expect(waypointSame.address, waypoint.address);
      expect(waypointSame.priority, waypoint.priority);
      expect(waypointSame.showTitle, waypoint.showTitle);

      final waypointDifferent = waypoint.copyWith(
        id: 'newId',
        title: 'newTitle',
        subtitle: 'newSubtitle',
        latitude: 1.0,
        longitude: 2.0,
        address: Placemark(street: 'newStreet'),
        priority: VisitingPriority.high,
        showTitle: false,
      );

      expect(waypointDifferent.id, 'newId');
      expect(waypointDifferent.title, 'newTitle');
      expect(waypointDifferent.subtitle, 'newSubtitle');
      expect(waypointDifferent.latitude, 1.0);
      expect(waypointDifferent.longitude, 2.0);
      expect(waypointDifferent.address.toString(),
          Placemark(street: 'newStreet').toString());
      expect(waypointDifferent.priority, VisitingPriority.high);
      expect(waypointDifferent.showTitle, isFalse);
    });

    test('serialization and deserialization works', () {
      final waypoint = dummyWaypoint();
      final serialized = waypoint.serialize();
      final deserialized = Waypoint.fromSerialized(serialized);

      expect(serialized, {
        'id': waypoint.id,
        'title': waypoint.title,
        'subtitle': waypoint.subtitle,
        'latitude': waypoint.latitude,
        'longitude': waypoint.longitude,
        'street': waypoint.address.street,
        'locality': waypoint.address.locality,
        'postalCode': waypoint.address.postalCode,
        'priority': waypoint.priority.index,
      });

      expect(deserialized.id, waypoint.id);
      expect(deserialized.title, waypoint.title);
      expect(deserialized.subtitle, waypoint.subtitle);
      expect(deserialized.latitude, waypoint.latitude);
      expect(deserialized.longitude, waypoint.longitude);
      expect(deserialized.address.toString(), waypoint.address.toString());
      expect(deserialized.priority, waypoint.priority);
      expect(deserialized.showTitle, waypoint.showTitle);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Waypoint.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.title, '');
      expect(emptyDeserialized.subtitle, '');
      expect(emptyDeserialized.latitude, 0);
      expect(emptyDeserialized.longitude, 0);
      expect(emptyDeserialized.address.toString(), Placemark().toString());
      expect(emptyDeserialized.priority, VisitingPriority.notApplicable);
      expect(emptyDeserialized.showTitle, isTrue);
    });
  });

}

import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/schools_provider.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';

import 'package:crcrme_banque_stages/screens/student/JsonToPdf/tag_system/tag_handler.dart';

class MockContext extends Mock implements BuildContext {}

class MockSchoolsProvider extends Mock implements SchoolsProvider {}

class MockEnterpriseProvider extends Mock implements EnterprisesProvider {}

class MockStudentsProvider extends Mock implements StudentsProvider {}

class MockTeachersProvider extends Mock implements TeachersProvider {}

class MockInternship extends Mock implements Internship {}

void main() {
  group('TagHandler', () {
    late TagHandler tagHandler;
    late MockContext mockContext;
    late MockSchoolsProvider mockSchoolsProvider;
    late MockEnterpriseProvider mockEnterpriseProvider;
    late MockStudentsProvider mockStudentsProvider;
    late MockTeachersProvider mockTeachersProvider;
    late MockInternship mockInternship;

    setUp(() {
      mockContext = MockContext();
      mockSchoolsProvider = MockSchoolsProvider();
      mockEnterpriseProvider = MockEnterpriseProvider();
      mockStudentsProvider = MockStudentsProvider();
      mockInternship = MockInternship();
      tagHandler = TagHandler(context: mockContext, internship: mockInternship);
    });
    testWidgets('replaces SCHOOL_NAME tag with correct value',
        (WidgetTester tester) async {
      // Arrange
      var mockSchoolsProvider = MockSchoolsProvider();
      when(mockSchoolsProvider[0].name).thenReturn('Test School Name');

      // Act
      await tester.pumpWidget(
        Provider<SchoolsProvider>.value(
          value: mockSchoolsProvider,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                var tagHandler =
                    TagHandler(context: context, internship: mockInternship);
                return Container();
              },
            ),
          ),
        ),
      );

      var result = await tagHandler.replaceTag('__SCHOOL_NAME__');

      // Assert
      expect(result, equals('Test School Name'));
    });
    testWidgets('replaces SCHOOL_ADDRESS tag with correct value',
        (WidgetTester tester) async {
      // Arrange
      var mockSchoolsProvider = MockSchoolsProvider();
      var mockAddress = Address(
          civicNumber: 123,
          street: 'Test Street',
          appartment: 'Test Appartment',
          city: 'Test City',
          postalCode: 'Test Postal Code');
      when(mockSchoolsProvider[0].address).thenReturn(mockAddress);
      // Act
      await tester.pumpWidget(
        Provider<SchoolsProvider>.value(
          value: mockSchoolsProvider,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                var tagHandler =
                    TagHandler(context: context, internship: mockInternship);
                return Container();
              },
            ),
          ),
        ),
      );

      var result = await tagHandler.replaceTag('__SCHOOL_ADDRESS__');

      // Assert
      expect(result, equals(mockAddress.toString()));
    });
  });
}

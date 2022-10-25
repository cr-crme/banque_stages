import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await JobDataFileService.loadData();

  group("Activity Sectors", () {
    test("Loaded with valid ids and name.", () async {
      expect(JobDataFileService.sectors, isNotEmpty);

      for (final sector in JobDataFileService.sectors) {
        expect(sector.name, isNotEmpty);
        expect(int.tryParse(sector.id), isNotNull);
      }
    });

    test("'fromId' returns the good Activity Sector or null", () async {
      final sector = JobDataFileService.sectors.first;

      expect(JobDataFileService.fromId(sector.id), sector);
      expect(JobDataFileService.fromId(""), null);
    });

    group("Filter Activity Sectors", () {
      test("Works with valid String and int.", () async {
        final sector = JobDataFileService.sectors.first;

        expect(
          JobDataFileService.filterActivitySectors(sector.id),
          contains(sector),
        );
        expect(
          JobDataFileService.filterActivitySectors(sector.name),
          contains(sector),
        );
        expect(
          JobDataFileService.filterActivitySectors(sector.idWithName),
          contains(sector),
        );
        expect(
          JobDataFileService.filterActivitySectors(sector.name.substring(2, 5)),
          contains(sector),
        );
      });

      test("Works with invalid int and empty String.", () async {
        expect(
          JobDataFileService.filterActivitySectors(""),
          JobDataFileService.sectors,
        );
        expect(
            JobDataFileService.filterActivitySectors("99999999999"), isEmpty);
      });
    });
  });

  group("Specializations", () {
    test("Loaded with valid ids and name.", () async {
      for (final sector in JobDataFileService.sectors) {
        for (final specialization in sector.specializations) {
          expect(specialization.name, isNotEmpty);
          expect(int.tryParse(specialization.id), isNotNull);
        }
      }
    });

    test("'fromId' returns the good Specialization or null", () async {
      final sector = JobDataFileService.sectors.first;
      final specialization = sector.specializations.first;

      expect(sector.fromId(specialization.id), specialization);
      expect(sector.fromId(""), null);
    });

    group("Filter Specializations", () {
      final sector = JobDataFileService.sectors.first;
      final specialization = sector.specializations.first;

      test("Works with valid String and int.", () async {
        expect(
          JobDataFileService.filterSpecializations(
            specialization.id,
            sector,
          ),
          contains(specialization),
        );
        expect(
          JobDataFileService.filterSpecializations(
            specialization.name,
            sector,
          ),
          contains(specialization),
        );
        expect(
          JobDataFileService.filterSpecializations(
            specialization.idWithName,
            sector,
          ),
          contains(specialization),
        );
      });

      test("Works with invalid int and empty String.", () async {
        expect(
          JobDataFileService.filterSpecializations("", sector),
          sector.specializations,
        );
        expect(
          JobDataFileService.filterSpecializations("99999999999", sector),
          isEmpty,
        );
      });
    });
  });

  group("Skills", () {
    test("Loaded with valid ids and name.", () {
      for (final sector in JobDataFileService.sectors) {
        for (final specialization in sector.specializations) {
          for (final skill in specialization.skills) {
            expect(skill.name, isNotEmpty);
            expect(int.tryParse(skill.id), isNotNull);
          }
        }
      }
    });
  });
}

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

    group("Filter Data with Activity Sectors", () {
      test("Works with valid String and int.", () async {
        final sector = JobDataFileService.sectors.first;

        expect(
          JobDataFileService.filterData(
            query: sector.id,
            data: JobDataFileService.sectors,
          ),
          contains(sector),
        );
        expect(
          JobDataFileService.filterData(
            query: sector.name,
            data: JobDataFileService.sectors,
          ),
          contains(sector),
        );
        expect(
          JobDataFileService.filterData(
            query: sector.idWithName,
            data: JobDataFileService.sectors,
          ),
          contains(sector),
        );
        expect(
          JobDataFileService.filterData(
            query: sector.name.substring(2, 5),
            data: JobDataFileService.sectors,
          ),
          contains(sector),
        );
      });

      test("Works with invalid int and empty String.", () async {
        expect(
          JobDataFileService.filterData(
            query: "",
            data: JobDataFileService.sectors,
          ),
          JobDataFileService.sectors,
        );
        expect(
          JobDataFileService.filterData(
            query: "99999999999",
            data: JobDataFileService.sectors,
          ),
          isEmpty,
        );
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

    group("Filter Data with Specializations", () {
      final specializations = JobDataFileService.sectors.first.specializations;
      final specialization = specializations.first;

      test("Works with valid String and int.", () async {
        expect(
          JobDataFileService.filterData(
            query: specialization.id,
            data: specializations,
          ),
          contains(specialization),
        );
        expect(
          JobDataFileService.filterData(
            query: specialization.name,
            data: specializations,
          ),
          contains(specialization),
        );
        expect(
          JobDataFileService.filterData(
            query: specialization.idWithName,
            data: specializations,
          ),
          contains(specialization),
        );
      });

      test("Works with invalid int and empty String.", () async {
        expect(
          JobDataFileService.filterData(
            query: "",
            data: specializations,
          ),
          specializations,
        );
        expect(
          JobDataFileService.filterData(
            query: "99999999999",
            data: specializations,
          ),
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

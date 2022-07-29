import '/common/models/activity_type.dart';
import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/models/job_list.dart';
import '/common/providers/enterprises_provider.dart';

T dummyData<T>(T dataToPopulate) {
  if (dataToPopulate is EnterprisesProvider) {
    JobList jobs = JobList();
    jobs.add(
      Job(
        activitySector: jobActivitySectors[1],
        specialization: jobSpecializations[3],
        totalSlot: 2,
        occupiedSlot: 1,
      ),
    );
    jobs.add(
      Job(
        activitySector: jobActivitySectors[0],
        specialization: jobSpecializations[2],
      ),
    );

    dataToPopulate.add(
      Enterprise(
        name: "Fausse Entreprise",
        neq: "2395375015",
        activityTypes: {ActivityType.activity1, ActivityType.activity7},
        recrutedBy: "John Doe",
        shareWith: "Tout le monde",
        jobs: jobs,
        contactName: "Sarah White",
        contactFunction: "Secrétaire",
        contactPhone: "514 321 9876",
        contactEmail: "white.sarah@fausse.ca",
        address: "1 rue Vide, Québec, QC A4A 4A4",
      ),
    );

    jobs = JobList();
    jobs.add(
      Job(
        activitySector: jobActivitySectors[0],
        specialization: jobSpecializations[0],
        totalSlot: 3,
        occupiedSlot: 3,
      ),
    );
    dataToPopulate.add(
      Enterprise(
        name: "Test",
        neq: "1234567890",
        activityTypes: {ActivityType.activity1, ActivityType.activity7},
        recrutedBy: "Nom Rectruté Par",
        shareWith: "Personne",
        jobs: jobs,
        contactName: "Nom Contact",
        contactFunction: "Fonction",
        contactPhone: "123 123 1234",
        contactEmail: "email@test.ca",
        address: "0 rue XYZ, Montréal, QC A1A 1A1",
      ),
    );
  }

  return dataToPopulate;
}

import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/models/job_list.dart';
import '/common/providers/enterprises_provider.dart';

T dummyData<T>(T dataToPopulate) {
  if (dataToPopulate is EnterprisesProvider) {
    // TODO: Add missing fields in the dummy jobs
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
        activityTypes: {activityTypes[0], activityTypes[3]},
        recrutedBy: "John Doe",
        shareWith: "Tout le monde",
        jobs: jobs,
        contactName: "Sarah White",
        contactFunction: "Secrétaire",
        contactPhone: "514 321 9876 poste 234",
        contactEmail: "white.sarah@fausse.ca",
        address: "1 rue Vide, Québec, QC A4A 4A4",
        phone: "514 321 9876",
        fax: "514 321 9870",
        website: "fausse.ca",
        headquartersAddress: "1 rue Vide, Québec, QC A4A 4A4",
        neq: "2395375015",
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
        activityTypes: {activityTypes[2], activityTypes[5]},
        recrutedBy: "Nom Rectruté Par",
        shareWith: "Personne",
        jobs: jobs,
        contactName: "Nom Contact",
        contactFunction: "Fonction",
        contactPhone: "123 123 1234",
        contactEmail: "email@test.ca",
        address: "Adresse de l'entreprise",
        phone: "456 456 4567",
        fax: "789 789 7890",
        website: "example.com",
        headquartersAddress: "Adresse du HQ",
        neq: "1234567890",
      ),
    );
  }

  return dataToPopulate;
}

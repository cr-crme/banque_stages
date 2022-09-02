//! Remove this file before production

import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/models/job_list.dart';
import '/common/providers/enterprises_provider.dart';

void addDummyEnterprises(EnterprisesProvider enterprises) {
  // TODO: Add missing fields in the dummy jobs
  JobList jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[1],
      specialization: JobDataFileService.sectors[1].specializations[3],
      positionsOffered: 2,
      positionsOccupied: 1,
    ),
  );
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[0],
      specialization: JobDataFileService.sectors[0].specializations[2],
    ),
  );

  enterprises.add(
    Enterprise(
      name: "Fausse Entreprise",
      activityTypes: {
        JobDataFileService.sectors[0].name,
        JobDataFileService.sectors[3].name
      },
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
      activitySector: JobDataFileService.sectors[0],
      specialization: JobDataFileService.sectors[0].specializations[0],
      positionsOffered: 3,
      positionsOccupied: 3,
    ),
  );
  enterprises.add(
    Enterprise(
      name: "Test",
      activityTypes: {
        JobDataFileService.sectors[3].name,
        JobDataFileService.sectors[8].name
      },
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

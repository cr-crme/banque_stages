//! Remove this file before production

import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/models/job_list.dart';
import '/common/models/student.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/students_provider.dart';

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
      activitySector: JobDataFileService.sectors[0],
      specialization: JobDataFileService.sectors[0].specializations[0],
      positionsOffered: 3,
      positionsOccupied: 3,
    ),
  );
  enterprises.add(
    Enterprise(
      name: "Test",
      activityTypes: {activityTypes[6], activityTypes[8]},
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

void addDummyStudents(StudentsProvider students) {
  students.add(
    Student(
      name: "Jonathan D",
      dateBirth: DateTime.now(),
      email: "",
      program: "TSA",
      group: "3",
      contactName: "Sarah White",
      contactLink: "Père",
      contactPhone: "514 321 9876 poste 234",
      contactEmail: "white.sarah@fausse.ca",
      address: "1 rue Vide, Québec, QC A4A 4A4",
      phone: "514 321 9876",
    ),
  );

  students.add(
    Student(
      name: "Nom élève",
      email: "email@eleve.com",
      program: "Program",
      group: "Group",
      dateBirth: DateTime.now(),
      contactName: "Nom Contact",
      contactLink: "Role Contact",
      contactPhone: "123 123 1234",
      contactEmail: "email@contact.ca",
      address: "Adresse de l'entreprise",
      phone: "456 456 4567",
    ),
  );
}

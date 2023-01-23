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
      activitySector: JobDataFileService.sectors[2],
      specialization: JobDataFileService.sectors[2].specializations[9],
      positionsOffered: 1,
      positionsOccupied: 1,
    ),
  );
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[0],
      specialization: JobDataFileService.sectors[0].specializations[7],
    ),
  );

  enterprises.add(
    Enterprise(
      name: "Metro Gagnon",
      activityTypes: {activityTypes[2], activityTypes[5], activityTypes[10]},
      recrutedBy: "Louise Talbot",
      shareWith: "Tout le monde",
      jobs: jobs,
      contactName: "Marc Arcand",
      contactFunction: "Directeur",
      contactPhone: "514 999 6655",
      contactEmail: "m.arcand@email.com",
      address: "1853 Chem. Rockland, Mont-Royal, QC H3P 2Y7",
      phone: "514 999 6655",
      fax: "514 999 6600",
      website: "fausse.ca",
      headquartersAddress: "1853 Chem. Rockland, Mont-Royal, QC H3P 2Y7",
      neq: "4567900954",
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[0],
      specialization: JobDataFileService.sectors[0].specializations[7],
      positionsOffered: 3,
      positionsOccupied: 3,
    ),
  );
  enterprises.add(
    Enterprise(
      name: "Jean Coutu",
      activityTypes: {activityTypes[20], activityTypes[5]},
      recrutedBy: "Judith Larivée",
      shareWith: "Personne",
      jobs: jobs,
      contactName: "Caroline Mercier",
      contactFunction: "Assistante-gérante",
      contactPhone: "514 123 4567 poste 123",
      contactEmail: "c.mercier@email.com",
      address: "4885 Henri-Bourassa Blvd Ouest, Montréal, QC H3L 1P3",
      phone: "514 123 4567",
      fax: "514 123 4560",
      website: "example.com",
      headquartersAddress:
          "4885 Henri-Bourassa Blvd Ouest, Montréal, QC H3L 1P3",
      neq: "1234567891",
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[9],
      specialization: JobDataFileService.sectors[9].specializations[3],
      positionsOffered: 1,
      positionsOccupied: 1,
    ),
  );
  enterprises.add(
    Enterprise(
      name: "Auto Care",
      activityTypes: {activityTypes[12], activityTypes[18]},
      recrutedBy: "François Duchemin",
      shareWith: "Tout le monde",
      jobs: jobs,
      contactName: "Denis Rondeau",
      contactFunction: "Propriétaire",
      contactPhone: "438 987 6543",
      contactEmail: "d.rondeau@email.com",
      address: "8490 Rue Saint-Dominique, Montréal, QC H2P 2L5",
      phone: "438 987 6543",
      fax: "",
      website: "",
      headquartersAddress: "8490 Rue Saint-Dominique, Montréal, QC H2P 2L5",
      neq: "5679011975",
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[9],
      specialization: JobDataFileService.sectors[9].specializations[3],
      positionsOffered: 2,
      positionsOccupied: 1,
    ),
  );
  enterprises.add(
    Enterprise(
      name: "Auto Repair",
      activityTypes: {activityTypes[12], activityTypes[18]},
      recrutedBy: "Charlène Cantin",
      shareWith: "Tout le monde",
      jobs: jobs,
      contactName: "Claudio Brodeur",
      contactFunction: "Propriétaire",
      contactPhone: "514 235 6789",
      contactEmail: "c.brodeur@email.com",
      address: "10142 Boul. Saint-Laurent, Montréal, QC H3L 2N7",
      phone: "514 235 6789",
      fax: "514 321 9870",
      website: "fausse.ca",
      headquartersAddress: "10142 Boul. Saint-Laurent, Montréal, QC H3L 2N7",
      neq: "2345678912",
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[2],
      specialization: JobDataFileService.sectors[2].specializations[9],
      positionsOffered: 2,
      positionsOccupied: 1,
    ),
  );

  enterprises.add(
    Enterprise(
      name: "Boucherie Marien",
      activityTypes: {activityTypes[2], activityTypes[5]},
      recrutedBy: "Stéphane Tremblay",
      shareWith: "Tout le monde",
      jobs: jobs,
      contactName: "Brigitte Samson",
      contactFunction: "Gérante",
      contactPhone: "438 888 2222",
      contactEmail: "b.samson@email.com",
      address: "8921 Rue Lajeunesse, Montréal, QC H2M 1S1",
      phone: "514 321 9876",
      fax: "514 321 9870",
      website: "fausse.ca",
      headquartersAddress: "8921 Rue Lajeunesse, Montréal, QC H2M 1S1",
      neq: "1234567080",
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[2],
      specialization: JobDataFileService.sectors[2].specializations[7],
      positionsOffered: 1,
      positionsOccupied: 1,
    ),
  );

  enterprises.add(
    Enterprise(
      name: "IGA",
      activityTypes: {activityTypes[10], activityTypes[29]},
      recrutedBy: "Christian Perez",
      shareWith: "Tout le monde",
      jobs: jobs,
      contactName: "Gabrielle Fortin",
      contactFunction: "Gérante",
      contactPhone: "514 111 2222",
      contactEmail: "g.fortin@email.com",
      address: "1415 Rue Jarry E, Montréal, QC H2E 1A7",
      phone: "514 111 2222",
      fax: "514 111 2200",
      website: "fausse.ca",
      headquartersAddress: "7885 Rue Lajeunesse, Montréal, QC H2M 1S1",
      neq: "1234560522",
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[0],
      specialization: JobDataFileService.sectors[0].specializations[7],
      positionsOffered: 2,
      positionsOccupied: 1,
    ),
  );

  enterprises.add(
    Enterprise(
      name: "Pharmaprix",
      activityTypes: {activityTypes[20], activityTypes[5]},
      recrutedBy: "Louise Talbot",
      shareWith: "Tout le monde",
      jobs: jobs,
      contactName: "Jessica Marcotte",
      contactFunction: "Pharmacienne",
      contactPhone: "514 111 2222",
      contactEmail: "g.fortin@email.com",
      address: "3611 Rue Jarry E, Montréal, QC H1Z 2G1",
      phone: "514 654 5444",
      fax: "514 654 5445",
      website: "fausse.ca",
      headquartersAddress: "3611 Rue Jarry E, Montréal, QC H1Z 2G1",
      neq: "3456789933",
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[2],
      specialization: JobDataFileService.sectors[2].specializations[14],
      positionsOffered: 1,
      positionsOccupied: 1,
    ),
  );

  enterprises.add(
    Enterprise(
      name: "Subway",
      activityTypes: {activityTypes[24], activityTypes[27]},
      recrutedBy: "Patricia Filion",
      shareWith: "Tout le monde",
      jobs: jobs,
      contactName: "Carlos Rodriguez",
      contactFunction: "Gérant",
      contactPhone: "514 555 3333",
      contactEmail: "c.rodriguez@email.com",
      address: "775 Rue Chabanel O, Montréal, QC H4N 3J7",
      phone: "514 555 7891",
      fax: "",
      website: "fausse.ca",
      headquartersAddress: "",
      neq: "6790122996",
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[0],
      specialization: JobDataFileService.sectors[0].specializations[7],
      positionsOffered: 3,
      positionsOccupied: 2,
    ),
  );

  enterprises.add(
    Enterprise(
      name: "Walmart",
      activityTypes: {activityTypes[5], activityTypes[15], activityTypes[29]},
      recrutedBy: "Caroline Mercier",
      shareWith: "Tout le monde",
      jobs: jobs,
      contactName: "France Boissonneau",
      contactFunction: "Directrice des Ressources Humaines",
      contactPhone: "514 879 8654 poste 1112",
      contactEmail: "f.boissonneau@email.com",
      address: "10345 Ave Christophe-Colomb, Montreal, QC H2C 2V1",
      phone: "514 879 8654",
      fax: "514 879 8000",
      website: "fausse.ca",
      headquartersAddress: "10345 Ave Christophe-Colomb, Montreal, QC H2C 2V1",
      neq: "9012345038",
    ),
  );
}

void addDummyStudents(StudentsProvider students) {
  students.add(
    Student(
      name: "Jonathan D",
      dateBirth: DateTime.now(),
      email: "",
      program: "FMS",
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
      name: "FPT student",
      dateBirth: DateTime.now(),
      email: "",
      program: "FPT",
      group: "0005",
      contactName: "Joe",
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

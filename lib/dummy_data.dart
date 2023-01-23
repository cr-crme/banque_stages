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
      name: "Cedric Masson",
      dateBirth: DateTime.now(),
      email: "c.masson@email.com",
      program: "FPT2",
      group: "550",
      contactName: "Paul Masson",
      contactLink: "Père",
      contactPhone: "514 321 9876",
      contactEmail: "p.masson@email.com",
      address: "7248 Rue D'Iberville, Montréal, QC H2E 2Y6",
      phone: "514 321 8888",
    ),
  );

  students.add(
    Student(
      name: "Thomas Caron",
      dateBirth: DateTime.now(),
      email: "t.caron@email.com",
      program: "FPT3",
      group: "885",
      contactName: "Joe Caron",
      contactLink: "Père",
      contactPhone: "514 321 9876",
      contactEmail: "j.caron@email.com",
      address: "6622 16e Avenue, Montréal, QC H1X 2T2",
      phone: "514 222 3344",
    ),
  );

  students.add(
    Student(
      name: "Mikael Boucher",
      dateBirth: DateTime.now(),
      email: "m.boucher@email.com",
      program: "FPT3",
      group: "885",
      contactName: "Nicole Lefranc",
      contactLink: "Mère",
      contactPhone: "514 321 9876",
      contactEmail: "n.lefranc@email.com",
      address: "6723 25e Ave, Montréal, QC H1T 3M1",
      phone: "514 333 4455",
    ),
  );

  students.add(
    Student(
      name: "Kevin Leblanc",
      dateBirth: DateTime.now(),
      email: "k.leblanc@email.com",
      program: "FPT2",
      group: "550",
      contactName: "Martine Gagnon",
      contactLink: "Mère",
      contactPhone: "514 321 9876",
      contactEmail: "m.gagnon@email.com",
      address: "6655 33e Avenue, Montréal, QC H1T 3B9",
      phone: "514 999 8877",
    ),
  );

  students.add(
    Student(
      name: "Simon Gingras",
      dateBirth: DateTime.now(),
      email: "s.gingras@email.com",
      program: "FMS",
      group: "789",
      contactName: "Raoul Gingras",
      contactLink: "Père",
      contactPhone: "514 321 9876",
      contactEmail: "r.gingras@email.com",
      address: "4517 Rue d'Assise, Saint-Léonard, QC H1R 1W2",
      phone: "514 888 7766",
    ),
  );

  students.add(
    Student(
      name: "Diego Vargas",
      dateBirth: DateTime.now(),
      email: "d.vargas@email.com",
      program: "FMS",
      group: "789",
      contactName: "Laura Vargas",
      contactLink: "Mère",
      contactPhone: "514 321 9876",
      contactEmail: "l.vargas@email.com",
      address: "8204 Rue de Blois, Saint-Léonard, QC H1R 2X1",
      phone: "514 444 5566",
    ),
  );

  students.add(
    Student(
      name: "Geneviève Tremblay",
      dateBirth: DateTime.now(),
      email: "g.tremblay@email.com",
      program: "FPT3",
      group: "885",
      contactName: "Vincent Tremblay",
      contactLink: "Père",
      contactPhone: "514 321 9876",
      contactEmail: "v.tremblay@email.com",
      address: "8358 Rue Jean-Nicolet, Saint-Léonard, QC H1R 2R2",
      phone: "514 555 9988",
    ),
  );

  students.add(
    Student(
      name: "Vincent Picard",
      dateBirth: DateTime.now(),
      email: "v.picard@email.com",
      program: "FMS",
      group: "789",
      contactName: "Jean-François Picard",
      contactLink: "Père",
      contactPhone: "514 321 9876",
      contactEmail: "jp.picard@email.com",
      address: "8382 Rue du Laus, Saint-Léonard, QC H1R 2P4",
      phone: "514 778 8899",
    ),
  );

  students.add(
    Student(
      name: "Vanessa Monette",
      dateBirth: DateTime.now(),
      email: "v.monette@email.com",
      program: "FMS",
      group: "789",
      contactName: "Stéphane Monette",
      contactLink: "Père",
      contactPhone: "514 321 9876",
      contactEmail: "s.monette@email.com",
      address: "6865 Rue Chaillot, Saint-Léonard, QC H1T 3R5",
      phone: "514 321 6655",
    ),
  );

  students.add(
    Student(
      name: "Mélissa Poulain",
      dateBirth: DateTime.now(),
      email: "m.poulain@email.com",
      program: "FMS",
      group: "789",
      contactName: "Mathieu Poulain",
      contactLink: "Père",
      contactPhone: "514 321 9876",
      contactEmail: "m.poulain@email.com",
      address: "6585 Rue Lemay, Montréal, QC H1T 2L8",
      phone: "514 567 9999",
    ),
  );
}

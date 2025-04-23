import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/models/job_list.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';
import '../utils.dart';

void main() {
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

    test('"specialization" behaves properly', () {
      expect(dummyJob().specialization, isNotNull);
      expect(() => Job.fromSerialized({}).specialization, throwsArgumentError);
    });

    test('serialization and deserialization works for Job', () {
      final job = dummyJob();
      final serialized = job.serialize();
      final deserialized = Job.fromSerialized(serialized);

      expect(serialized, {
        'id': job.id,
        'specialization': job.specialization.id,
        'positionsOffered': job.positionsOffered,
        'minimumAge': job.minimumAge,
        'preInternshipRequest': job.preInternshipRequest.serialize(),
        'uniform': job.uniform.serialize(),
        'protections': job.protections.serialize(),
        'photosUrl': job.photosUrl,
        'sstEvaluations': job.sstEvaluation.serialize(),
        'incidents': job.incidents.serialize(),
        'comments': job.comments,
      });

      expect(deserialized.id, job.id);
      expect(deserialized.specialization.id, job.specialization.id);
      expect(deserialized.positionsOffered, job.positionsOffered);
      expect(deserialized.minimumAge, job.minimumAge);
      expect(deserialized.preInternshipRequest.id, job.preInternshipRequest.id);
      expect(deserialized.uniform.id, job.uniform.id);
      expect(deserialized.protections.id, job.protections.id);
      expect(deserialized.photosUrl, job.photosUrl);
      expect(deserialized.sstEvaluation.id, job.sstEvaluation.id);
      expect(deserialized.incidents.id, job.incidents.id);
      expect(deserialized.comments, job.comments);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = Job.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.positionsOffered, 0);
      expect(emptyDeserialized.minimumAge, 0);
      expect(emptyDeserialized.preInternshipRequest.id, isNotNull);
      expect(emptyDeserialized.uniform.id, isNotNull);
      expect(emptyDeserialized.protections.id, isNotNull);
      expect(emptyDeserialized.photosUrl, []);
      expect(emptyDeserialized.sstEvaluation.id, isNotNull);
      expect(emptyDeserialized.incidents.id, isNotNull);
      expect(emptyDeserialized.comments, []);
    });

    test('serialization and deserialization works for JobList', () {
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
}

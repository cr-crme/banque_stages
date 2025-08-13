import 'package:flutter_test/flutter_test.dart';
import 'package:stagess/misc/risk_data_file_service.dart';
import 'package:stagess/program_helpers.dart';

void main() {
  group('RiskDataFileService', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    ProgramInitializer.initialize(mockMe: true);

    test('risks are loaded properly', () async {
      await RiskDataFileService.loadData();
      expect(RiskDataFileService.risks, isNotEmpty);
    });

    test('can get a risk from id', () async {
      await RiskDataFileService.loadData();

      final risk = RiskDataFileService.risks[0];
      expect(RiskDataFileService.fromId(risk.id), risk);

      // Is null if not found
      expect(RiskDataFileService.fromId('not found'), isNull);
    });

    test('can get a risk from abbrv', () async {
      await RiskDataFileService.loadData();

      final risk = RiskDataFileService.risks[0];
      expect(RiskDataFileService.fromAbbrv(risk.abbrv), risk);

      // Is null if not found
      expect(RiskDataFileService.fromAbbrv('not found'), isNull);
    });
  });
}

import 'package:crcrme_banque_stages/misc/risk_data_file_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async{
  TestWidgetsFlutterBinding.ensureInitialized();
  await RiskDataFileService.loadData();

  group("Get informations", ()
  {
    test("Loaded with valid ids and name.", () async {
        expect(RiskDataFileService.risks, isNotEmpty);
        for(final risk in RiskDataFileService.risks) {
          expect(risk.name, isNotEmpty);
          expect(risk.id, isNotNull);
        }
    });

    test("'fromId' returns the good Risk or null", () async {
      final sector = RiskDataFileService.risks.first;

      expect(RiskDataFileService.fromId(sector.id), sector);
      expect(RiskDataFileService.fromId(""), null);

    });
  });
}
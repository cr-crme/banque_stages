import 'package:crcrme_banque_stages/misc/storage_service.dart';
import 'package:crcrme_banque_stages/program_initializer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StorageService', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    ProgramInitializer.initialize(mockMe: true);

    test('singleton is properly initialized', () async {
      expect(StorageService.instance, StorageService.instance);
    });

    test('can upload a file to storage', () async {
      // create a file to upload
      final path =
          await StorageService.instance.uploadJobImage('test_image.png');
      expect(path, isNotEmpty);
    });

    test('can delete a file from storae', () async {
      // remove the file from storage
      expect(
          await StorageService.instance.removeJobImage(
              'https://some_fancy_address/enterprises%2Fjobs%2Ftest.png?alt=media&token=1'),
          isTrue);

      // Try to remove non conformant url
      expect(
          await StorageService.instance.removeJobImage(
              'https://some_fancy_address/enterprises%2Fjobs%2Ftest.png'),
          isFalse);
    });
  });
}

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

abstract class StorageService {
  static void uploadEnterpriseImage(String imagePath) {
    _uploadFile("enterprises/images/", File(imagePath));
  }

  static void _uploadFile(String destination, File file) {
    FirebaseStorage.instance.ref(destination).putFile(file);
  }
}

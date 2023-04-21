import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:nanoid/nanoid.dart';
import 'package:path/path.dart';

abstract class StorageService {
  static Future<String> uploadJobImage(String path) async {
    return await _uploadFile('enterprises/jobs/', File(path));
  }

  static Future<String> _uploadFile(String destination, File file) async {
    var ref = FirebaseStorage.instance.ref(destination +
        nanoid() +
        file.hashCode.toString() +
        extension(file.path));

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:nanoid/nanoid.dart';
import 'package:path/path.dart';

abstract class StorageService {
  static Future<String> uploadJobImage(String path) async {
    return await _uploadFile('enterprises/jobs/', File(path));
  }

  static Future<void> removeJobImage(String url) async {
    final match = RegExp(r'^.*enterprises%2Fjobs%2F(.*)\?.*$').firstMatch(url);
    if (match == null) return;

    // This is unauthorized
    // final imageName = match.group(1)!;
    // await FirebaseStorage.instance.ref('entreprises/jobs/$imageName').delete();
    return;
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

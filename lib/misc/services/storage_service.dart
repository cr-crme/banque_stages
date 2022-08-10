import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

abstract class StorageService {
  static Future<String> uploadJobImage(XFile image) async {
    return await _uploadFile("enterprises/jobs/", File(image.path));
  }

  static Future<String> _uploadFile(String destination, File file) async {
    var ref = FirebaseStorage.instance.ref(destination +
        Random().nextDouble().hashCode.toString() +
        file.hashCode.toString() +
        extension(file.path));

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}

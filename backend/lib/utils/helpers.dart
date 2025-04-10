import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

bool isJwtValid(String token) {
  try {
    // TODO: Store "secret passphrase" in the environment variables
    JWT.verify(token, SecretKey('secret passphrase'));
    return true;
  } catch (e) {
    return false;
  }
}

bool isListEqual<T>(List<T> list1, List<T> list2) {
  if (list1.length != list2.length) return false;

  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) return false;
  }

  return true;
}

bool isNotListEqual<T>(List<T> list1, List<T> list2) {
  return !isListEqual(list1, list2);
}

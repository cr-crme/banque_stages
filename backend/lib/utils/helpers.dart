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

import 'package:common/utils.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

dynamic extractJwt(String token) {
  try {
    // TODO: Store "secret passphrase" in the environment variables
    final jwt = JWT.verify(token, SecretKey('secret passphrase'));

    if (jwt.payload['app_secret'] != DevAuth.devMyAppSecret ||
        _decryptJwtSchoolBoardId(jwt.payload['school_board_id']) !=
            _getMySchoolBoardId()) {
      return null;
    } else {
      return jwt.payload;
    }
  } catch (e) {
    return null;
  }
}

String _getMySchoolBoardId() {
  // TODO: This should fetch expected values from the database
  return DevAuth.devMySchoolBoardId;
}

String _decryptJwtSchoolBoardId(String id) {
  // TODO: Should we have to school_board_id encrypted in the JWT?
  return id;
}

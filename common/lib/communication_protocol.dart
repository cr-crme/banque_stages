import 'package:common/exceptions.dart';

enum RequestFields {
  schoolBoard,
  schoolBoards,
  teacher,
  teachers,
  student,
  students,
  enterprise,
  enterprises,
  internships,
  internship,
}

enum RequestType {
  handshake,
  get,
  post,
  delete,
  response,
  update,
}

enum Response {
  success,
  failure,
  connexionRefused,
}

const String _currentVersion = '1.0.0';

class CommunicationProtocol {
  final String version = _currentVersion;
  final RequestType requestType;
  final RequestFields? field;
  final Map<String, dynamic>? data;
  final Response? response;
  final int? socketId;

  CommunicationProtocol({
    required this.requestType,
    this.field,
    this.data,
    this.response,
    this.socketId,
  });

  Map<String, dynamic> serialize() {
    return {
      'version': version,
      'type': requestType.index,
      'field': field?.index,
      'data': data,
      'response': response?.index,
      'socket_id': socketId,
    };
  }

  static CommunicationProtocol deserialize(Map<String, dynamic> map) {
    if (map['version'] != _currentVersion) {
      throw WrongVersionException(map['version'], _currentVersion);
    }
    return CommunicationProtocol(
      requestType: RequestType.values[map['type'] as int],
      field: map['field'] != null
          ? RequestFields.values[map['field'] as int]
          : null,
      data: map['data'] as Map<String, dynamic>?,
      response: map['response'] != null
          ? Response.values[map['response'] as int]
          : null,
      socketId: map['socket_id'] as int?,
    );
  }

  CommunicationProtocol copyWith({
    RequestType? requestType,
    RequestFields? field,
    Map<String, dynamic>? data,
    Response? response,
    int? socketId,
  }) {
    return CommunicationProtocol(
      requestType: requestType ?? this.requestType,
      field: field ?? this.field,
      data: data ?? this.data,
      response: response ?? this.response,
      socketId: socketId ?? this.socketId,
    );
  }

  @override
  String toString() {
    return 'CommunicationProtocol(version: $version, requestType: $requestType, field: $field, data: $data, response: $response)';
  }
}

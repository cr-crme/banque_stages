import 'package:backend/connexions.dart';
import 'package:backend/database_manager.dart';
import 'package:backend/database_teachers.dart';
import 'package:backend/http_request_handler.dart';
import 'package:test/test.dart';

import 'http_request_mock.dart';

Connexions get _mockedConnexions => Connexions(
    database: DatabaseManager(teacherDatabase: DatabaseTeachersMock()));

void main() {
  test('Send an a preflight request', () async {
    final request = HttpRequestMock(method: 'OPTIONS', uri: Uri.parse('/'));
    final requestHandler = HttpRequestHandler(connexions: _mockedConnexions);
    await requestHandler.answer(request);

    final response = request.response as HttpResponseMock;
    final responseHeaders = response.headers as HttpHeadersMock;
    expect(responseHeaders.current.length, 3);
    expect(responseHeaders.current['Access-Control-Allow-Origin'], '*');
    expect(responseHeaders.current['Access-Control-Allow-Methods'],
        'GET, OPTIONS');
    expect(responseHeaders.current['Access-Control-Allow-Headers'],
        'Content-Type, Authorization');
  });

  test('Send a POST request', () async {
    final request = HttpRequestMock(method: 'POST', uri: Uri.parse('/'));
    final requestHandler = HttpRequestHandler(connexions: _mockedConnexions);
    await requestHandler.answer(request);

    final response = request.response as HttpResponseMock;
    expect(response.response, 'Unauthorized');
  });

  test('Send a GET resquest to an invalid endpoit', () async {
    final request = HttpRequestMock(method: 'GET', uri: Uri.parse('/'));
    final requestHandler = HttpRequestHandler(connexions: _mockedConnexions);
    await requestHandler.answer(request);

    final response = request.response as HttpResponseMock;
    expect(response.response, 'Unauthorized: Invalid endpoint');
  });

  test('Simulate internal error while connecting', () async {
    final request = HttpRequestMock(
        method: 'GET',
        uri: Uri.parse('/connect'),
        forceFailToUpgradeToWebSocket: true);
    final requestHandler = HttpRequestHandler(connexions: _mockedConnexions);
    await requestHandler.answer(request);

    final response = request.response as HttpResponseMock;
    expect(response.response, 'Unauthorized: WebSocket upgrade failed');
  });

  test('Send a GET request to the /connect endpoint', () async {
    final request = HttpRequestMock(method: 'GET', uri: Uri.parse('/connect'));
    final requestHandler = HttpRequestHandler(connexions: _mockedConnexions);
    await requestHandler.answer(request);

    // This test creates a true WebSocket connection (as opposed to a mock)
    // so we cannot check if the response is correct. But returning a null
    // response is a good indication that the connection was successful.
    final response = request.response as HttpResponseMock;
    expect(response.response, null);
  });

  test(
      'Send a GET request to the /admin endpoint (refused as not implemented yet)',
      () async {
    final request = HttpRequestMock(method: 'GET', uri: Uri.parse('/admin'));
    final requestHandler = HttpRequestHandler(connexions: _mockedConnexions);
    await requestHandler.answer(request);

    final response = request.response as HttpResponseMock;
    expect(response.response, 'Unauthorized: Invalid endpoint');
  });
}

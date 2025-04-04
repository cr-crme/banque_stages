import 'package:backend/answer_http_request.dart';
import 'package:test/test.dart';

import 'http_request_mock.dart';

void main() {
  test('Send an a preflight request', () async {
    final request = HttpRequestMock(method: 'OPTIONS', uri: Uri.parse('/'));
    await answerHttpRequest(request);

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
    await answerHttpRequest(request);

    final response = request.response as HttpResponseMock;
    expect(response.response, 'Unauthorized');
  });

  test('Send a GET resquest to an invalid endpoit', () async {
    final request = HttpRequestMock(method: 'GET', uri: Uri.parse('/'));
    await answerHttpRequest(request);

    final response = request.response as HttpResponseMock;
    expect(response.response, 'Unauthorized');
  });

  test('Send a GET request to the /connect endpoint', () async {
    final request = HttpRequestMock(method: 'GET', uri: Uri.parse('/connect'));
    await answerHttpRequest(request);

    // This test creates a true WebSocket connection (as opposed to a mock)
    // so we cannot check if the response is correct. But returning a null
    // response is a good indication that the connection was successful.
    final response = request.response as HttpResponseMock;
    expect(response.response, null);
  });

  test('Send a GET request to the /admin endpoint', () async {
    final request = HttpRequestMock(method: 'GET', uri: Uri.parse('/admin'));
    await answerHttpRequest(request);

    final response = request.response as HttpResponseMock;
    expect(response.response, 'Unauthorized');
  });
}

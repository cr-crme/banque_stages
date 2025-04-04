import 'dart:math';

import 'package:backend/answer_http_request.dart';
import 'package:test/test.dart';

import 'http_request_mock.dart';

void main() {
  test('Send an HttpRequest to an invalid endpoint', () async {
    final request = HttpRequestMock(method: 'OPTIONS');
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
}

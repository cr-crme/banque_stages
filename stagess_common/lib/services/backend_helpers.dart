class BackendHelpers {
  static String backendProtocol({required bool isSecured}) =>
      isSecured ? 'wss' : 'ws';
  static String backendIp({required bool useLocal}) =>
      useLocal ? 'localhost' : '159.203.9.197';
  static const int backendPort = 3456;
  static String connectEndpoint({required bool isDev}) =>
      '${isDev ? 'dev-' : ''}connect';
  static String get bugReportEndpoint => 'bug-report';

  static Uri backendUri(
          {required bool isLocal,
          required bool isSecured,
          required bool isDev}) =>
      Uri.parse(
          '${backendProtocol(isSecured: isSecured)}://${backendIp(useLocal: isLocal)}:$backendPort/${connectEndpoint(isDev: isDev)}');
  static Uri backendUriForBugReport(
          {required bool isLocal, required bool isSecured}) =>
      Uri.parse(
          '${isSecured ? 'https' : 'http'}://${backendIp(useLocal: isLocal)}:$backendPort/$bugReportEndpoint');
}

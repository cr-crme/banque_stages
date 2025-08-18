class BackendHelpers {
  static String backendProtocol({required bool useSsl}) =>
      useSsl ? 'wss' : 'ws';
  static String backendIp({required bool useLocal}) =>
      useLocal ? 'localhost' : '159.203.9.197';
  static const int backendPort = 3456;
  static String connectEndpoint({required bool isDev}) =>
      '${isDev ? 'dev-' : ''}connect';
  static String get bugReportEndpoint => 'bug-report';

  static Uri backendUri(
          {required bool isLocal, required bool useSsl, required bool isDev}) =>
      Uri.parse(
          '${backendProtocol(useSsl: useSsl)}://${backendIp(useLocal: isLocal)}:$backendPort/${connectEndpoint(isDev: isDev)}');
  static Uri backendUriForBugReport(
          {required bool isLocal, required bool useSsl}) =>
      Uri.parse(
          '${useSsl ? 'https' : 'http'}://${backendIp(useLocal: isLocal)}:$backendPort/$bugReportEndpoint');
}

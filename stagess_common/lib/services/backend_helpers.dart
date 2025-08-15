class BackendHelpers {
  static String backendProtocol({required bool isSecured}) =>
      isSecured ? 'wss' : 'ws';
  static const String backendIp = 'localhost';
  static const int backendPort = 3456;
  static String connectEndpoint({required bool isDev}) =>
      '${isDev ? 'dev-' : ''}connect';
  static String get bugReportEndpoint => 'bug-report';

  static Uri backendUri({required bool isSecured, required bool isDev}) =>
      Uri.parse(
          '${backendProtocol(isSecured: isSecured)}://$backendIp:$backendPort/${connectEndpoint(isDev: isDev)}');
  static Uri backendUriForBugReport({required bool isSecured}) => Uri.parse(
      '${isSecured ? 'https' : 'http'}://$backendIp:$backendPort/$bugReportEndpoint');
}

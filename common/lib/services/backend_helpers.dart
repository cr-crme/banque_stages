class BackendHelpers {
  static String backendProtocol({required bool isSecured}) =>
      isSecured ? 'wss' : 'ws';
  static const String backendIp = 'localhost';
  static const int backendPort = 3456;
  static String backendEndpoint({required bool isDev}) =>
      '${isDev ? 'dev-' : ''}connect';
  static Uri backendUri({required bool isSecured, required bool isDev}) =>
      Uri.parse(
          '${backendProtocol(isSecured: isSecured)}://$backendIp:$backendPort/${backendEndpoint(isDev: isDev)}');
  static Uri backendUriForBugReport({required bool isSecured}) => Uri.parse(
      '${isSecured ? 'https' : 'http'}://$backendIp:$backendPort/bug-report');

  static const String devDatabaseName = 'dev_db';
  static const int devDatabasePort = 3306;

  static const String productionDatabaseName = 'production_db';
  static const int productionDatabasePort = 3307;
}

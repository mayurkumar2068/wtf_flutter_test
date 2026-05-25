import 'sync_host_resolver.dart';

/// Base URL for local sync + token server.
class ApiConfig {
  ApiConfig({String? overrideBaseUrl, int port = 3000})
      : baseUrl = overrideBaseUrl ??
            (SyncHostResolver.isResolved
                ? SyncHostResolver.baseUrl
                : 'http://${SyncHostResolver.defaultHosts.first}:$port');

  final String baseUrl;

  String get tokenUrl => '$baseUrl/token';
  String get wsUrl =>
      baseUrl.replaceFirst('http', 'ws').replaceFirst('https', 'wss');
}

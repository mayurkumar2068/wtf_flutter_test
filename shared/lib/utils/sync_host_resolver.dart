import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'app_logger.dart';

/// Finds the Mac/local sync server from the phone.
class SyncHostResolver {
  SyncHostResolver._();

  static String? _resolvedBaseUrl;
  static int _port = 3000;
  static Future<bool>? _resolveInFlight;

  static String get baseUrl =>
      _resolvedBaseUrl ?? 'http://${defaultHosts.first}:$_port';

  static bool get isResolved => _resolvedBaseUrl != null;

  static List<String> get defaultHosts {
    const fromEnv = String.fromEnvironment('SYNC_HOST');
    if (fromEnv.isNotEmpty) return [fromEnv];

    if (Platform.isAndroid) {
      return ['127.0.0.1', '10.0.2.2'];
    }
    return ['localhost'];
  }

  /// Parallel probe — max ~1.5s instead of serial 6s+ timeouts.
  static Future<bool> resolve({
    int port = 3000,
    Duration timeout = const Duration(milliseconds: 1500),
  }) async {
    if (_resolvedBaseUrl != null) return true;
    _resolveInFlight ??= _probe(port: port, timeout: timeout);
    try {
      return await _resolveInFlight!;
    } finally {
      _resolveInFlight = null;
    }
  }

  static Future<bool> _probe({required int port, required Duration timeout}) async {
    _port = port;
    final completer = Completer<bool>();
    var pending = defaultHosts.length;

    for (final host in defaultHosts) {
      unawaited(_checkHost(host, port, timeout).then((ok) {
        if (ok && !completer.isCompleted) {
          completer.complete(true);
        } else if (--pending == 0 && !completer.isCompleted) {
          completer.complete(false);
        }
      }));
    }

    final ok = await completer.future.timeout(
      timeout + const Duration(milliseconds: 400),
      onTimeout: () => false,
    );

    if (!ok) {
      _resolvedBaseUrl = null;
      AppLogger.instance.log(LogTag.general, 'Sync server offline');
    }
    return ok;
  }

  static Future<bool> _checkHost(
    String host,
    int port,
    Duration timeout,
  ) async {
    final url = 'http://$host:$port/health';
    try {
      final res = await http.get(Uri.parse(url)).timeout(timeout);
      if (res.statusCode == 200) {
        _resolvedBaseUrl = 'http://$host:$port';
        AppLogger.instance.log(LogTag.general, 'Sync OK $_resolvedBaseUrl');
        return true;
      }
    } catch (e) {
      AppLogger.instance.log(LogTag.general, 'Probe $url: $e');
    }
    return false;
  }

  static void reset() => _resolvedBaseUrl = null;

  static String get setupHint {
    if (!Platform.isAndroid) {
      return 'Terminal: cd token_server && npm start';
    }
    return '1) ./scripts/start_android_dev.sh\n'
        '2) Hot restart app (R)\n'
        'Wi‑Fi: flutter run --dart-define=SYNC_HOST=MAC_IP';
  }
}

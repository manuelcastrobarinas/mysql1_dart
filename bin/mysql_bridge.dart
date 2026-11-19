import 'dart:io';

import 'package:mysql2/src/bridge/mysql_bridge.dart';

/// Carry MySQL connections for a browser.
///
/// A Flutter web app cannot open port 3306. It connects to this process over
/// a WebSocket, and this process opens the database socket. The database host
/// comes from the environment below, never from the page.
///
/// Two addresses are involved. `MYSQL_BRIDGE_BIND` and `MYSQL_BRIDGE_PORT`
/// are the WebSocket the page opens (`ConnectionSettings.bridgeUrl`).
/// `MYSQL_HOST` and `MYSQL_PORT` are the database this process dials. The
/// page does not send that second address.
///
///     MYSQL_BRIDGE_TOKEN   required, at least 16 characters. The page's
///                          bridgeToken. Never printed. The process exits
///                          if it is missing or shorter.
///     MYSQL_HOST           where this process finds MySQL. Default
///                          127.0.0.1, meaning MySQL is on this computer.
///     MYSQL_PORT           MySQL's TCP port. Default 3306. Set it when
///                          MySQL listens somewhere else, such as 3307.
///     MYSQL_BRIDGE_BIND    interface of the WebSocket. Default 127.0.0.1,
///                          so only this computer can open it.
///     MYSQL_BRIDGE_PORT    port of the WebSocket. Default 8080. This is
///                          the port in bridgeUrl, not MySQL's port.
///     MYSQL_BRIDGE_ORIGIN  if set, the only Origin header which is upgraded.
///
/// A bridge for MySQL on port 3307, reachable only from this computer:
///
///     $env:MYSQL_BRIDGE_TOKEN = 'a-long-random-secret'
///     $env:MYSQL_HOST = '127.0.0.1'
///     $env:MYSQL_PORT = '3307'
///     $env:MYSQL_BRIDGE_BIND = '127.0.0.1'
///     $env:MYSQL_BRIDGE_PORT = '8080'
///     dart run mysql2:mysql_bridge
///
/// That prints `ws://127.0.0.1:8080/mysql` and `forwarding to 127.0.0.1:3307`.
/// The path is always `/mysql`. The token, the database user and the password
/// all end up inside the built web app. Anyone who can load the app can read
/// them. Bind this to loopback unless the people who can open that WebSocket
/// are the people who should be able to log in to that database.
///
/// The README section "Flutter Web" is the full walk-through, including the
/// diagrams of these two hops and of the token handshake.
Future<void> main() async {
  final token = Platform.environment['MYSQL_BRIDGE_TOKEN'] ?? '';
  if (token.length < 16) {
    stderr.writeln(
      'MYSQL_BRIDGE_TOKEN must be set to at least 16 characters. '
      'The value is not printed.',
    );
    exitCode = 64;
    return;
  }

  final bridge = await MysqlBridge.start(
    token: token,
    mysqlHost: Platform.environment['MYSQL_HOST'] ?? '127.0.0.1',
    mysqlPort: _port('MYSQL_PORT', 3306),
    bindHost: Platform.environment['MYSQL_BRIDGE_BIND'] ?? '127.0.0.1',
    port: _port('MYSQL_BRIDGE_PORT', 8080),
    origin: _optional('MYSQL_BRIDGE_ORIGIN'),
  );
  stdout.writeln('mysql2 bridge listening on ${bridge.url}');
  stdout.writeln('forwarding to ${bridge.mysqlHost}:${bridge.mysqlPort}');
}

int _port(String name, int fallback) {
  final value = Platform.environment[name];
  if (value == null || value.isEmpty) {
    return fallback;
  }
  final port = int.tryParse(value);
  if (port == null || port < 0 || port > 65535) {
    stderr.writeln('$name must be a port from 0 to 65535. It was $value');
    exit(64);
  }
  return port;
}

String? _optional(String name) {
  final value = Platform.environment[name];
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}

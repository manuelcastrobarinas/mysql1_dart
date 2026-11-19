import 'package:mysql2/mysql2.dart';

/// The same calls as `example.dart`, carried through the WebSocket bridge.
///
/// Start the bridge first, in PowerShell, on the machine that can reach
/// MySQL. These four settings are the picture in `doc/web-bridge-layout.svg`.
/// The token is a fifth setting: the process refuses to listen without it,
/// and it has to be the same string as [ConnectionSettings.bridgeToken].
///
///     $env:MYSQL_BRIDGE_TOKEN = 'replace-with-a-long-secret'
///     $env:MYSQL_HOST = '127.0.0.1'       // bridge dials MySQL here
///     $env:MYSQL_PORT = '3307'            // not the default 3306
///     $env:MYSQL_BRIDGE_BIND = '127.0.0.1' // only this computer can connect
///     $env:MYSQL_BRIDGE_PORT = '8080'     // the port inside bridgeUrl
///     dart run mysql2:mysql_bridge
///
/// The process prints `ws://127.0.0.1:8080/mysql` and
/// `forwarding to 127.0.0.1:3307`. The page uses the first line. It does not
/// send 3307. `host` and `port` below are unused while `bridgeUrl` is set:
/// the browser cannot open that TCP port, and the bridge ignores them so a
/// page cannot aim it at some other machine.
///
/// `$env:` applies to that terminal only. `useSSL` stays false. The user, the
/// password and the token are inside the built web app.
Future<void> main() async {
  final conn = await MySqlConnection.connect(
    ConnectionSettings(
      user: 'root',
      password: 'secret',
      db: 'testdb',
      bridgeUrl: 'ws://127.0.0.1:8080/mysql',
      bridgeToken: 'replace-with-a-long-secret',
    ),
  );

  await conn.query(
    'CREATE TABLE users (id int NOT NULL AUTO_INCREMENT PRIMARY KEY, '
    'name varchar(255), email varchar(255), age int)',
  );

  final result = await conn.query(
    'insert into users (name, email, age) values (?, ?, ?)',
    ['Bob', 'bob@bob.com', 25],
  );
  print('Inserted row id=${result.insertId}');

  final results = await conn.query(
    'select name, email, age from users where id = ?',
    [result.insertId],
  );
  for (final row in results) {
    print('Name: ${row[0]}, email: ${row[1]} age: ${row[2]}');
  }

  await conn.close();
}

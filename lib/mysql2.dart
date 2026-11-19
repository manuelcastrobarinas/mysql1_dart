// Results and Field are deprecated and still exported, which is the point of
// keeping them. The analyzer in Dart 3.0 reports naming them here.
// ignore_for_file: deprecated_member_use_from_same_package

/// A MySQL and MariaDB driver for Dart and Flutter.
///
/// On a server, on Flutter mobile and on the desktop, [MySqlConnection.connect]
/// opens `ConnectionSettings.host` and `port` directly. From the browser it
/// cannot: a page has no TCP sockets. Set `bridgeUrl` and `bridgeToken` and
/// run `bin/mysql_bridge.dart`. That process listens on
/// `MYSQL_BRIDGE_BIND`:`MYSQL_BRIDGE_PORT` and dials `MYSQL_HOST`:`MYSQL_PORT`.
/// Those are different addresses. The README section "Flutter Web" draws both.
library mysql2;

export 'src/blob.dart';
export 'src/mysql_client_error.dart' show MySqlClientError;
export 'src/mysql_exception.dart' hide createMySqlException;
export 'src/mysql_protocol_error.dart' hide createMySqlProtocolError;
export 'src/single_connection.dart'
    show
        MySqlConnection,
        TransactionContext,
        Result,
        Results,
        ConnectionSettings;

export 'src/constants.dart' show CharacterSet;

export 'src/results/field.dart' show ResultSchemaColumn, Field;
export 'src/results/row.dart';
export 'src/results/schema.dart';

// ignore_for_file: lines_longer_than_80_chars

import 'package:sqlite_db/sqlite_db.dart';

void main() async {
  final db = const SQLiteDbFactory().create(
    const DbConnectionData(
      hostDirectoryPath: '.',
      name: 'example.db',
      version: 1,
    ),
    const DbInitializerScripts(
      creationScripts: [
        SingleVersionedDbScript(
          scriptText:
              'CREATE TABLE IF NOT EXISTS users (id TEXT PRIMARY KEY, name TEXT)',
          targetVersion: 1,
        ),
      ],
    ),
  );

  await db.initialize();
  await db.insert('users', [
    {'id': '1', 'name': 'Alice'},
  ]);

  final rows = await db.get('users', 'id', ['1']);
  print('User: ${rows.first['name']}');

  await db.dispose();
}

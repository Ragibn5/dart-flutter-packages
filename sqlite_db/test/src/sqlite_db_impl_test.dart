import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common/sqflite.dart';
import 'package:sqlite_db/sqlite_db.dart';
import 'package:sqlite_db/src/sqlite_db_impl.dart';

class _MockDbInitializationScripts extends Mock
    implements DbInitializerScripts {}

class _MockDatabaseFactory extends Mock implements DatabaseFactory {}

class _MockBatch extends Mock implements Batch {}

class _MockTransaction extends Mock implements Transaction {
  final Database db;

  _MockTransaction(this.db);

  @override
  Batch batch() => db.batch();
}

class _MockDatabase extends Mock implements Database {
  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction) action, {
    bool? exclusive,
  }) {
    final transaction = _MockTransaction(this);
    return action(transaction);
  }
}

void main() {
  const connectionData = DbConnectionData(
    hostDirectoryPath: 'a/b/c',
    name: 'APP_DB',
    version: 1,
  );

  late _MockDbInitializationScripts mockDbInitializationScripts;
  late _MockDatabaseFactory mockDatabaseFactory;
  late _MockDatabase mockDatabase;

  setUpAll(() {
    registerFallbackValue(connectionData);
  });

  setUp(() {
    mockDbInitializationScripts = _MockDbInitializationScripts();
    mockDatabaseFactory = _MockDatabaseFactory();
    mockDatabase = _MockDatabase();

    when(() => mockDbInitializationScripts.configurationScripts).thenReturn([]);
    when(() => mockDbInitializationScripts.creationScripts).thenReturn([]);
    when(() => mockDbInitializationScripts.upgradeScripts).thenReturn([]);
    when(() => mockDbInitializationScripts.openScripts).thenReturn([]);
    when(
      () => mockDatabaseFactory.openDatabase(
        any(),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => mockDatabase);
  });

  group('Initialization', () {
    test('Opens database with correct path, name and version', () async {
      final sut = SQLiteDbImpl.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );

      await sut.initialize();

      verify(
        () => mockDatabaseFactory.openDatabase(
          path.join(connectionData.hostDirectoryPath, connectionData.name),
          options: any(
            named: 'options',
            that: isA<OpenDatabaseOptions>().having(
              (d) => d.version,
              'version',
              connectionData.version,
            ),
          ),
        ),
      ).called(1);
    });
  });

  group('Guard against uninitialized usage', () {
    late SQLiteDbImpl sut;

    setUp(() {
      sut = SQLiteDbImpl.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );
    });

    for (final args in [
      ('async', 'get', () => sut.get('t', 'id', ['1'])),
      (
        'async',
        'insert',
        () => sut.insert('t', [
              {'c': 'v'}
            ])
      ),
      ('async', 'delete', () => sut.delete('t', 'id', ['1'])),
      ('async', 'deleteAll', () => sut.deleteAll('t')),
      ('sync', 'query', () => sut.query('t')),
      ('sync', 'rawQuery', () => sut.rawQuery('SELECT 1')),
      ('sync', 'execute', () => sut.execute('DROP TABLE t')),
    ]) {
      test('${args.$2} throws StateError', () {
        if (args.$1 == 'async') {
          expectLater(args.$3(), throwsA(isA<StateError>()));
        } else {
          expect(args.$3, throwsA(isA<StateError>()));
        }
      });
    }
  });

  group('get', () {
    late SQLiteDbImpl sut;

    setUp(() async {
      sut = SQLiteDbImpl.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );
      when(() => mockDatabase.isOpen).thenReturn(true);
      await sut.initialize();
    });

    test('Returns empty list when ids is empty', () async {
      final result = await sut.get('t', 'id', []);

      expect(result, isEmpty);
      verifyNever(() => mockDatabase.query(any()));
    });

    test('Queries with escaped column name and placeholders', () async {
      when(
        () => mockDatabase.query(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenAnswer((_) async => []);

      await sut.get('users', 'id', ['1', '2']);

      verify(
        () => mockDatabase.query(
          'users',
          where: '"id" IN (?, ?)',
          whereArgs: ['1', '2'],
        ),
      ).called(1);
    });

    test('Escapes double quotes in column name', () async {
      when(
        () => mockDatabase.query(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenAnswer((_) async => []);

      await sut.get('t', 'col"name', ['1']);

      verify(
        () => mockDatabase.query(
          any(),
          where: '"col""name" IN (?)',
          whereArgs: any(named: 'whereArgs'),
        ),
      ).called(1);
    });
  });

  group('insert', () {
    late SQLiteDbImpl sut;

    setUp(() async {
      sut = SQLiteDbImpl.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );
      when(() => mockDatabase.isOpen).thenReturn(true);
      await sut.initialize();
    });

    test('Returns 0 when entities is empty', () async {
      final result = await sut.insert('t', []);

      expect(result, 0);
    });

    test('Inserts via batch and returns count', () async {
      final mockBatch = _MockBatch();
      when(() => mockDatabase.batch()).thenReturn(mockBatch);
      when(
        () => mockBatch.insert(
          any(),
          any(),
          conflictAlgorithm: any(named: 'conflictAlgorithm'),
        ),
      ).thenReturn(null);
      when(() => mockBatch.commit(noResult: false))
          .thenAnswer((_) async => [1, 1]);

      final result = await sut.insert('t', [
        {'name': 'a'},
        {'name': 'b'},
      ]);

      expect(result, 2);
      verify(
        () => mockBatch.insert(
          't',
          {'name': 'a'},
          conflictAlgorithm: any(named: 'conflictAlgorithm'),
        ),
      ).called(1);
      verify(
        () => mockBatch.insert(
          't',
          {'name': 'b'},
          conflictAlgorithm: any(named: 'conflictAlgorithm'),
        ),
      ).called(1);
    });
  });

  group('delete', () {
    late SQLiteDbImpl sut;

    setUp(() async {
      sut = SQLiteDbImpl.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );
      when(() => mockDatabase.isOpen).thenReturn(true);
      await sut.initialize();
    });

    test('Returns 0 when ids is empty', () async {
      final result = await sut.delete('t', 'id', []);

      expect(result, 0);
    });

    test('Deletes via batch with escaped column', () async {
      final mockBatch = _MockBatch();
      when(() => mockDatabase.batch()).thenReturn(mockBatch);
      when(
        () => mockBatch.delete(
          any(),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenReturn(null);
      when(() => mockBatch.commit(noResult: false))
          .thenAnswer((_) async => [2]);

      final result = await sut.delete('t', 'id', ['1', '2']);

      expect(result, 2);
      verify(
        () => mockBatch.delete(
          't',
          where: '"id" IN (?, ?)',
          whereArgs: ['1', '2'],
        ),
      ).called(1);
    });
  });

  group('deleteAll', () {
    test('Delegates to db.delete', () async {
      when(() => mockDatabase.isOpen).thenReturn(true);
      when(() => mockDatabase.delete(any())).thenAnswer((_) async => 5);
      final sut = SQLiteDbImpl.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );
      await sut.initialize();

      final result = await sut.deleteAll('users');

      expect(result, 5);
      verify(() => mockDatabase.delete('users')).called(1);
    });
  });

  group('query', () {
    test('Delegates all parameters to db.query', () async {
      when(() => mockDatabase.isOpen).thenReturn(true);
      when(
        () => mockDatabase.query(
          any(),
          distinct: any(named: 'distinct'),
          columns: any(named: 'columns'),
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
          groupBy: any(named: 'groupBy'),
          having: any(named: 'having'),
          orderBy: any(named: 'orderBy'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [
            {'id': 1}
          ]);
      final sut = SQLiteDbImpl.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );
      await sut.initialize();

      final result = await sut.query(
        'users',
        distinct: true,
        columns: ['id', 'name'],
        where: 'age > ?',
        whereArgs: [18],
        groupBy: 'city',
        having: 'count > 1',
        orderBy: 'name',
        limit: 10,
        offset: 20,
      );

      expect(result, [
        {'id': 1}
      ]);
      verify(
        () => mockDatabase.query(
          'users',
          distinct: true,
          columns: ['id', 'name'],
          where: 'age > ?',
          whereArgs: [18],
          groupBy: 'city',
          having: 'count > 1',
          orderBy: 'name',
          limit: 10,
          offset: 20,
        ),
      ).called(1);
    });
  });

  group('rawQuery', () {
    test('Delegates to db.rawQuery', () async {
      when(() => mockDatabase.isOpen).thenReturn(true);
      when(() => mockDatabase.rawQuery(any(), any())).thenAnswer((_) async => [
            {'id': 1}
          ]);
      final sut = SQLiteDbImpl.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );
      await sut.initialize();

      final result = await sut.rawQuery('SELECT * FROM t WHERE id = ?', [1]);

      expect(result, [
        {'id': 1}
      ]);
      verify(() => mockDatabase.rawQuery('SELECT * FROM t WHERE id = ?', [1]))
          .called(1);
    });
  });

  group('execute', () {
    test('Delegates to db.execute', () async {
      when(() => mockDatabase.isOpen).thenReturn(true);
      when(() => mockDatabase.execute(any(), any())).thenAnswer((_) async {});
      final sut = SQLiteDbImpl.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );
      await sut.initialize();

      await sut.execute('DELETE FROM t');

      verify(() => mockDatabase.execute('DELETE FROM t')).called(1);
    });
  });

  group('executeTransaction', () {
    late SQLiteDbImpl sut;

    setUp(() async {
      sut = SQLiteDbImpl.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );
      when(() => mockDatabase.isOpen).thenReturn(true);
      await sut.initialize();
    });

    test('Passes self as scoped db inside transaction', () async {
      SQLiteDb? scoped;
      await sut.executeTransaction((db) async {
        scoped = db;
        return 42;
      });

      expect(scoped, same(sut));
    });

    test('Returns the scope result', () async {
      final result = await sut.executeTransaction((db) => 'hello');

      expect(result, 'hello');
    });
  });

  group('dispose', () {
    test('Closes the underlying database', () async {
      when(() => mockDatabase.isOpen).thenReturn(true);
      when(() => mockDatabase.close()).thenAnswer((_) async {});
      final sut = SQLiteDbImpl.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );
      await sut.initialize();

      await sut.dispose();

      verify(() => mockDatabase.close()).called(1);
    });

    test('Is safe to call when not initialized', () async {
      final sut = SQLiteDbImpl.test(
        connectionData,
        mockDbInitializationScripts,
        mockDatabaseFactory,
      );

      await expectLater(sut.dispose(), completes);
    });
  });
}

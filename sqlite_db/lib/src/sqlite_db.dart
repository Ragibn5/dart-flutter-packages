import 'dart:async';

import 'package:sqlite_db/src/enums/data_conflict_algorithm.dart';

/// A SQLite database.
abstract interface class SQLiteDb {
  /// Initializes the underlying database connection, running any
  /// configured creation, upgrade, migration, or any other database
  /// scripts.
  ///
  /// Must be called before any other method on this instance.
  Future<void> initialize();

  /// Closes the underlying database connection.
  ///
  /// No other operation on this database should be performed after
  /// calling this method.
  Future<void> dispose();

  /// Fetches rows by their IDs.
  ///
  /// Returns the rows whose [idColumnName] value is in [ids].
  /// If [ids] is empty, returns an empty list.
  ///
  /// **Params:**
  /// - [tableName] — the table to query.
  /// - [idColumnName] — the column to match against [ids]. Must be a single
  ///   bare column name, not a qualified name or any expression.
  ///   Escaped internally.
  /// - [ids] — the ID values to match. Rows whose [idColumnName] is in this
  ///   list are returned.
  /// - [distinct] / [groupBy] / [having] / [orderBy] — caller-trusted
  ///   SQL fragments passed as-is. Must be valid sql fragments - both
  ///   contextually and syntactically.
  ///
  /// | Use `get` for… | Use `query` for… |
  /// |---|---|
  /// | Fetch exact rows by known IDs. | Paginate all rows (`limit`/`offset`). |
  /// |  | Arbitrary `WHERE` filters. |
  /// |  | Complex joins or expressions. |
  Future<List<Map<String, Object?>>> get(
    String tableName,
    String idColumnName,
    List<String> ids, {
    bool? distinct,
    String? groupBy,
    String? having,
    String? orderBy,
  });

  /// Inserts or upserts rows.
  ///
  /// Returns the number of rows successfully inserted.
  /// This can be less than the size of [entities] depending
  /// on factors like the used conflict algorithm, and others.
  ///
  /// **Params:**
  /// - [tableName] — the table to insert into.
  /// - [entities] — the rows to insert. Each map's keys are column names
  ///   and values are bound via parameterized queries.
  /// - [conflictAlgorithm] — SQLite `ON CONFLICT` resolution:
  ///   `REPLACE` (default) / `IGNORE` / `ABORT` / `FAIL` / `ROLLBACK`.
  Future<int> insert(
    String tableName,
    List<Map<String, Object?>> entities, {
    DataConflictAlgorithm conflictAlgorithm = DataConflictAlgorithm.REPLACE,
  });

  /// Deletes rows by their IDs.
  ///
  /// Returns the number of deleted rows.
  /// This can be less than the size of [ids].
  ///
  /// **Params:**
  /// - [tableName] — the table to delete from.
  /// - [idColumnName] — the column to match against [ids]. Must be a single
  ///   bare column name, not a qualified name or any expression.
  ///   Escaped internally.
  /// - [ids] — the ID values to match. Rows whose [idColumnName] is in this
  ///   list are deleted.
  Future<int> delete(
    String tableName,
    String idColumnName,
    List<String> ids,
  );

  /// Deletes all rows from [tableName].
  ///
  /// **Warning:** The table structure, indexes, and schema remain intact.
  /// Use with extreme caution.
  ///
  /// **Params:**
  /// - [tableName] — the table to truncate.
  Future<int> deleteAll(String tableName);

  /// Queries rows with full SQL fragment support.
  ///
  /// **Params:**
  /// - [table] — the table to query.
  /// - [columns] — the columns to return in the result set.
  ///   `null` selects all columns.
  /// - [where] — the filter expression. Use `?` placeholders with [whereArgs].
  ///   Do not interpolate values directly — that creates SQL injection risk.
  /// - [whereArgs] — values bound to `?` in [where]. Count must match.
  /// - [distinct] / [groupBy] / [having] / [orderBy] / [limit] / [offset] —
  ///   caller-trusted SQL fragments passed as-is. Must be valid SQL
  ///   fragments — both contextually and syntactically.
  ///
  /// Note: Use when [get] does not cover your filtering needs.
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });

  /// Executes a raw SQL query that returns rows.
  ///
  /// Prefer [query] or [get] when possible — they handle escaping and
  /// parameter binding more safely.
  ///
  /// Only use for DML that returns data (`SELECT`, `PRAGMA`, etc.). Executing
  /// DDL via this method may corrupt the schema if misused.
  ///
  /// **Params:**
  /// - [query] — the full SQL query (e.g. `SELECT * FROM users WHERE id = ?`).
  ///   Use `?` as positional placeholders for [arguments].
  /// - [arguments] — values bound positionally to the `?` placeholders in
  ///   [query]. Count must match.
  Future<List<Map<String, Object?>>> rawQuery(
    String query, [
    List<Object?>? arguments,
  ]);

  /// Executes a raw SQL statement that does not return rows.
  ///
  /// Suitable for DDL (`CREATE`, `ALTER`, `DROP`), DML without results
  /// (`UPDATE`, `DELETE` without returning), or custom PRAGMA statements.
  /// Prefer [insert], [delete], or [deleteAll] when they cover the use case.
  ///
  /// **Params:**
  /// - [query] — the full SQL statement.
  ///   Use `?` as positional placeholders for [arguments].
  /// - [arguments] — values bound positionally to the `?` placeholders in
  ///   [query]. Count must match.
  Future<void> execute(String query, [List<Object?>? arguments]);

  /// Executes a function inside a SQLite transaction.
  ///
  /// The [scope] receives this database bound to the transaction's connection.
  /// All operations through it share the same transaction. If [scope] throws,
  /// everything rolls back atomically.
  ///
  /// **Params:**
  /// - [scope] — a function that performs database operations on the given
  ///   [SQLiteDb] instance within the transaction.
  ///
  /// **Example:**
  /// ```dart
  /// db.executeTransaction((tnxDb) async {
  ///   await tnxDb.insert('orders', [order]);
  ///   await tnxDb.insert('line_items', items);
  /// });
  /// ```
  Future<T> executeTransaction<T>(T Function(SQLiteDb db) scope);
}

# sqlite_db

A SQLite database client.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  sqlite_db: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  sqlite_db:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: sqlite_db
      ref: sqlite_db-1.0.0
```

## 📖 Usage

Workflows are built around a single `SQLiteDb` instance you create with `SQLiteDbFactory`.

### 🗄️ Creating a database

Creating a database instance requires two components.

- **`DbConnectionData`**  describes where the database lives, its current version, and other metadata about the database.
- **`DbInitializerScripts`** carries the schema, upgrade, migration, and other scripts to run when the database is opened.

```dart
import 'package:sqlite_db/sqlite_db.dart';

Future<void> main() async {
  final db = const SQLiteDbFactory().create(
    const DbConnectionData(
      hostDirectoryPath: '.',
      name: 'app.db',
      version: 1,
    ),
    const DbInitializerScripts(
      creationScripts: [
        SingleVersionedDbScript(
          // The script will only run if the current version of the database matches this one.
          targetVersion: 1,
          scriptText:
              'CREATE TABLE users('
              'id INTEGER PRIMARY KEY AUTOINCREMENT,'
              'name TEXT NOT NULL'
              ')',
        ),
      ],
      // Other scripts if needed ...
    ),
  );

  // ... initialize db
  
  // ... use db
}
```

### ▶️ Initializing the database (`initialize`)

After creating the database instance, you must initialize it before using it.

This is the phase where the underlying implementation runs the provided scripts, along with other things.

> **Use when** setting up the database at app startup, right after creating the instance and before any read or write. Call it once per instance — calling any other method beforehand will fail.

```dart
void main() async {
  // ...
  await db.initialize();
}
```

### ➕ Inserting rows (`insert`)

Inserts or upserts one or more rows. Each entity is a map of column name to value; values are always bound via parameterized queries.

```dart
void main() async {
  // ...
  
  // Insert returns the number of rows successfully written,
  // which can be less than the number of entities depending on the chosen conflict algorithm.
  final inserted = await db.insert(
    'users',
    [
      {'id': 1, 'name': 'Alice'},
      {'id': 2, 'name': 'Bob'},
    ],
    // Optional (Default: DataConflictAlgorithm.REPLACE)
    conflictAlgorithm: DataConflictAlgorithm.IGNORE,
  );
}
```

### 🔍 Fetching rows by ID (`get`)

Fetches rows whose ID column value is in the given list of IDs.

```dart
void main() async {
  // ...
  final users = await db.get('users', 'id', ['1', '2']);
}
```

### 🔎 Querying rows with filters (`query`)

Queries rows with full SQL fragment support — arbitrary `WHERE` filters, `GROUP BY`, `HAVING`, `ORDER BY`, joins, and pagination.

```dart
void main() async {
  // ...
  final matches = await db.query(
    'users',
    columns: ['id', 'name'],
    // Build filter expressions with `?` placeholders, and ...
    where: 'name LIKE ? AND id > ?',
    // Pass the matching values in `whereArgs`.
    whereArgs: ['A%', 5],
    orderBy: 'name ASC',
    limit: 20,
    offset: 0,
  );
}
```

> **Always** bind user input through `?` placeholders rather than interpolating it directly into the SQL string — this prevents SQL injection.
> **Use when** `get` isn't enough — filtering by non-ID attributes, searching, sorting, grouping, or loading a paginated list (e.g. a page of search results).

### 🗑️ Deleting rows by ID (`delete`)

Deletes rows whose ID column value is in the given list of IDs. Returns the number of rows deleted.

```dart
void main() async {
  // ...
  final deleted = await db.delete('users', 'id', ['2']);
}
```

### 🧹 Clearing a table (`deleteAll`)

Deletes all rows from a table, leaving its schema, indexes, and structure intact.

```dart
void main() async {
  // ...
  final deleted = await db.deleteAll('users');
}
```

### ⚙️ Executing a statement without results (`execute`)

Executes a raw SQL statement that does not return rows — DDL like `CREATE` or `ALTER`, or DML like `UPDATE` and `DELETE`.

```dart
void main() async {
  // ...
  await db.execute(
    // Use `?` placeholders with corresponding positional `arguments` in the arguments list (2nd param)
    'UPDATE users SET name = ? WHERE id = ?',
    // The corresponding arguments for each '?'
    ['Alice A.', '1'],
  );
}
```

### 👁️ Executing a query returning rows (`rawQuery`)

Executes a raw SQL statement that returns rows, such as `SELECT` or `PRAGMA`. Use `?` placeholders with positional `arguments`:

```dart
void main() async {
  // ...
  final version = await db.rawQuery('PRAGMA user_version');
}
```

> **Use when** you need free-form SELECTs the helpers can't express, like reading `PRAGMA` metadata, handwritten queries, writing high performance complex queries spanning over multiple tables and all sorts of things.

### 🔒 Grouping operations in a transaction (`executeTransaction`)

Runs a function inside a SQLite transaction. The callback receives a `SQLiteDb` bound to the transaction's connection; all operations through it share the transaction, and everything rolls back atomically if it throws.

```dart
void main() async {
  // ...
  final orderId = await db.executeTransaction((txn) async {
    final orderId = await txn.insert('orders', [
      {'total': 49.99},
    ]);
    await txn.insert('line_items', [
      {'order_id': orderId, 'name': 'Widget'},
    ]);
    return orderId;
  });
}
```

> **Use when** several writes must succeed or fail together — placing an order (insert the order plus its line items), transferring a balance, or performing a multistep sync. It also speeds up many sequential writes by grouping them into a single transaction.

### ♻️ Releasing the database (`dispose`)

Closes the underlying connection. No other operation should be performed after calling it.

> **Use when** the database is no longer needed — closing the screen that owns it or shutting down the app — to release the file handle and free resources.

```dart
void main() async {
  // ...
  await db.dispose();
}
```

## 🧪 Example

See the [example](example/example.dart) for a complete runnable demonstration.

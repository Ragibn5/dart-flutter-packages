# analysis_plugin_test_helper

Utilities to help write tests for the analyzer plugins.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  analysis_plugin_test_helper: ^1.0.5
```

#### Or, From Git repo

```yaml
dependencies:
  analysis_plugin_test_helper:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: analysis_plugin_test_helper
      ref: analysis_plugin_test_helper-1.0.5
```

---

# 🎯 Overview

Testing analyzer plugins means writing resolved Dart snippets and asserting on specific AST nodes. That requires a lot of repetitive setup: temp files, resolving the source tree, manual tree-walking, cleanup, and much more – over and over again. **analysis_plugin_helper** collapses all of it into two things: a one-call resolver and a set of helpers.

| Feature             | What it does                                                              |
|---------------------|---------------------------------------------------------------------------|
| `DartUnitResolver`  | Converts a Dart source string into a fully resolved `ResolvedUnitResult`. |
| Annotation parsers  | Find/get annotations by resolved type name.                               |
| Method parsers      | Find/get methods by name across classes, mixins, extensions, and enums.   |
| Constructor parsers | Find/get named, default, and factory constructors.                        |
| Import parsers      | Find/get import directives.                                               |

Every parser comes in two flavors: `find*` (returns `null`) and `get*` (fails the test via `fail()`).

## 🔧 Usage

### DartUnitResolver

Parsing Dart source with `analyzer`'s `parseString` gives you an **unresolved** AST — nodes are syntax only, not linked to declarations. Analyzer plugins need the *resolved* picture. Normally that means:

1. Creating an `AnalysisContextCollection`
2. Writing source to a temp file
3. Resolving it and extracting a `ResolvedUnitResult`
4. Cleaning up

`DartUnitResolver` does all of this in one call:

```dart
import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:test/test.dart';

void main() {
  final resolver = DartUnitResolver();

  setUpAll(() async => resolver.setUp());
  tearDownAll(() async => resolver.tearDown());

  test('resolve source', () async {
    final result = await resolver.resolveSource('''
      class MyAnnotation {
        const MyAnnotation();
      }

      @MyAnnotation()
      class Foo {
        void myMethod() {}
      }
    ''');

    expect(result.diagnostics, isEmpty);
    // result.unit — fully resolved CompilationUnit
  });
}
```

> ⚠️ The source must be **self-contained** — every class, annotation, and import it references must be declared inline. There's no surrounding project context.

> ℹ️ `resolveSource()` doesn't throw on errors in the source. Syntactically invalid code still returns a `ResolvedUnitResult`. Check `result.diagnostics` if you need to assert validity. It only throws `StateError` when the analyzer can't produce a result at all.

`setUp()` / `tearDown()` manage the temp directory only. Each `resolveSource()` call spins up its own `AnalysisContextCollection` — no state leaks between calls.

### 🔍 Parser Helpers

Once you have `result.unit`, these functions locate AST nodes without writing a visitor.

#### find\* vs. get\*

| Prefix  | Returns | When not found              |
|---------|---------|-----------------------------|
| `find*` | `null`  | returns `null`              |
| `get*`  | value   | fails the test via `fail()` |

Use `find*` when asserting something is **absent**; `get*` when you expect it to exist.

#### 📌 Annotations

```
Annotation? findAnnotation<D extends CompilationUnitMember>(
  CompilationUnit unit, {
  required String annotationName,
})
```

Matches by the annotation's **resolved type** (`computeConstantValue().type.element.name`), not source text. So these all match `annotationName: 'MyAnnotation'`:

```
@MyAnnotation()           // direct
@MY_ANNOTATION            // const variable
@MAN                      // typedef alias
```

Searches top-level declarations only (`unit.declarations`). Use the type parameter to narrow: `getAnnotation<ClassDeclaration>(...)`.

```
final annotation = getAnnotation(result.unit, annotationName: 'MyAnnotation');
```

#### 🔨 Methods

```
MethodDeclaration? findMethodDeclaration(CompilationUnit unit, String name)
```

Searches members of classes, mixins, extensions, extension types, and enums. Does **not** cover top-level functions.

```
final method = getMethodDeclaration(result.unit, 'myMethod');
```

#### 🏗️ Constructors

```
ConstructorDeclaration? findConstructorDeclaration(CompilationUnit unit, String? name)
```

`name` is the constructor's own name (`'named'`, not `'Foo.named'`). Pass `null` for the default constructor. Matches both regular and factory constructors — use `findFactoryConstructorDeclaration` when you need to distinguish.

```
final defaultCtor = getConstructorDeclaration(result.unit, null);
final namedCtor   = getConstructorDeclaration(result.unit, 'named');
```

#### 🏭 Factory Constructors

```
ConstructorDeclaration? findFactoryConstructorDeclaration(CompilationUnit unit, String? name)
```

Same as `findConstructorDeclaration`, restricted to `factory` constructors. `null` finds the default factory.

```
final factoryCtor = getFactoryConstructorDeclaration(result.unit, 'create');
```

#### 📥 Import Directives

```
ImportDirective? findImportDirective(CompilationUnit unit)
```

Returns the **first** import directive. No URI filtering.

```
final importDirective = getImportDirective(result.unit);
```

## 🧩 Putting it together

```
test('plugin flags classes annotated with @MyAnnotation', () async {
  final result = await resolver.resolveSource('''
    class MyAnnotation {
      const MyAnnotation();
    }

    @MyAnnotation()
    class Foo {
      void myMethod() {}
    }
  ''');

  final annotation = getAnnotation(result.unit, annotationName: 'MyAnnotation');
  final method = getMethodDeclaration(result.unit, 'myMethod');

  expect(annotation, isNotNull);
  expect(method.name.lexeme, 'myMethod');
});
```

This is the shape most plugin tests take: Resolve → pull nodes → assert. No temp files, no cleanup.

## 🧪 Example

See [`example/README.md`](example/README.md) for a complete demonstration.

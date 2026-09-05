# dev_tools

Shared developer tooling for Dart and Flutter projects.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dev_dependencies:
  dev_tools: ^1.0.0
```

#### Or, From Git repo

```yaml
dev_dependencies:
  dev_tools:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: dev_tools
      ref: dev_tools-1.0.0
```

## Usage

### CLI

This is developer tooling, so add it under `dev_dependencies` in your project. A single executable is exposed (plus per-domain subcommands):

```bash
# Resolve the Flutter/Dart command (honors fvm when present)
dart run dev_tools:flutter
dart run dev_tools:dart

# Coverage workflow
dart run dev_tools:coverage run
dart run dev_tools:coverage process --exclude lib/api/**
dart run dev_tools:coverage enforce --lcov-file coverage/lcov.info --threshold 100

# Publish a package
dart run dev_tools:publish --dry-run
dart run dev_tools:publish

# CI change detection
dart run dev_tools:git changes <folder> <from-ref> <to-ref>

# Replace text across files
dart run dev_tools:replace <src> <target>

# Discover and run tests for all packages
dart run dev_tools:test-all
```

### Library

Each utility is also available as a library under the `dev_tools` package.

```dart
import 'package:dev_tools/dev_tools.dart';

void main() async {
  final flutterCmd = await FlutterUtils.getFlutterCmd();
  final root = await ProjectUtils.findProjectRoot();
  final pct = await CoverageUtils.getCoveragePct('coverage/lcov.info');
}
```

## Example

See the [example](example) directory for a complete demonstration.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

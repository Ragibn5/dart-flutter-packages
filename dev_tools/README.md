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

This is developer tooling, so add it under `dev_dependencies` in your project. A single executable with per-domain subcommands is exposed:

| Command            | Description                                                                                                                   |
|--------------------|-------------------------------------------------------------------------------------------------------------------------------|
| `fvm-dart`         | Returns the fvm-aware dart executable prefix.                                                                                 |
| `fvm-flutter`      | Returns the fvm-aware flutter executable prefix.                                                                              |
| `coverage run`     | Runs tests with coverage (`--lcov-file`, default `coverage/lcov.info`).                                                       |
| `coverage process` | Filters lcov data using exclusion patterns relative to the project root (`-e`/`--exclude`, repeatable, e.g. `lib/api/**`).    |
| `coverage enforce` | Enforces the coverage threshold against an lcov file (`--lcov-file`, `--threshold`, defaults `coverage/lcov.info` and `100`). |
| `coverage genres`  | Generates an HTML coverage report with genhtml.                                                                               |
| `publish`          | Validates and publishes a package from a release branch (`--dry-run` for a dry run).                                          |
| `git changes`      | Detects changes in a folder between two refs: `git changes <folder> <from-ref> <to-ref>`.                                     |
| `replace`          | Replaces literal text across files: `replace <src> <target>`.                                                                 |

Examples:

```bash
# Resolve the Flutter/Dart executable (honors fvm when present)
dart run dev_tools fvm-dart
dart run dev_tools fvm-flutter

# Coverage workflow
dart run dev_tools coverage run --lcov-file coverage/lcov.info
dart run dev_tools coverage process --exclude lib/api/**
dart run dev_tools coverage enforce --lcov-file coverage/lcov.info --threshold 100
dart run dev_tools coverage genres

# Publish a package
dart run dev_tools publish --dry-run

# CI change detection
dart run dev_tools git changes lib <from-ref> <to-ref>

# Replace text across files
dart run dev_tools replace <src> <target>
```

## Example

See the [example](example) directory for a complete demonstration.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

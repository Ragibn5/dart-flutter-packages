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

A single executable with per-domain subcommands is exposed:

| Command              | Description                                                                                                                                                                       |
|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `fvm-dart`           | Returns the fvm-aware dart executable prefix.                                                                                                                                     |
| `fvm-flutter`        | Returns the fvm-aware flutter executable prefix.                                                                                                                                  |
| `coverage run`       | Runs tests with coverage (`--lcov-file`, default `coverage/lcov.info`).                                                                                                           |
| `coverage process`   | Filters lcov data using exclusion patterns relative to the project root (`-e`/`--exclude`, repeatable, e.g. `lib/api/**`).                                                        |
| `coverage enforce`   | Enforces the coverage threshold against an lcov file (`--lcov-file`, `--threshold`, defaults `coverage/lcov.info` and `100`).                                                     |
| `coverage genreport` | Generates an HTML coverage report with genhtml.                                                                                                                                   |
| `publish`            | Validates and publishes a package (`--path <dir>`, relative to the repo root, default the current directory; `--dry-run` for a dry run).                                          |
| `git changes`        | Detects changes in a folder (default: the whole repository) between two refs: `git changes` (`--folder <dir>`, `--from <ref>` (default `HEAD~1`), `--to <ref>` (default `HEAD`)). |
| `replace`            | Replaces text across files: `replace <src> <target>` (`--start <dir>`, `-e`/`--exclude`, `--follow-links`, `--ignore-case`, `--match-word`, `--regex`, `-y`/`--yes`).             |

> Note: Please see the files at `lib/src/commands` for full understanding.

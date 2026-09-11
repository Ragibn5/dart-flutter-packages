import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/release/verify_versioned_files.dart';

/// Builds the standard CHANGELOG.md/README.md checks `VerifyReleaseCompleteness`
/// runs by default: a CHANGELOG entry for the version, and README references
/// for both the git-install and pub-registry-install forms.
class BuildStandardReleaseChecksBuilder {
  static const _changelogPrefix = r'^#{1,6}\s*\[?';
  static const _changelogSuffix = r'\]?(\s+-.*)?\s*$';
  static const _boundaryOpen = r'(^|[^0-9A-Za-z-])';
  static const _boundaryClose = r'([^0-9A-Za-z-]|$)';
  static const _constraintSeparator = r':\s*\^';

  /// Matches a Markdown heading ending with `<version>`.
  static RegExp _changelogEntryPattern(String name, String version) {
    return RegExp(
      '$_changelogPrefix${RegExp.escape(version)}$_changelogSuffix',
    );
  }

  static String _changelogProblem(String name, String version) {
    return 'CHANGELOG.md has no entry for $version.';
  }

  /// Matches the git-install reference (built from [gitTagFormat]) only
  /// when surrounded by non-version characters, so similar strings inside
  /// docs or other references (e.g. `dev_tools: ^1.0.0`) are not counted as
  /// a reference.
  static RegExp _gitInstallPattern(
    GetTagFormat gitTagFormat, {
    required String name,
    required String version,
  }) {
    final escaped = RegExp.escape(gitTagFormat(name: name, version: version));
    return RegExp('$_boundaryOpen$escaped$_boundaryClose');
  }

  static String _gitInstallProblem(
    GetTagFormat gitTagFormat, {
    required String name,
    required String version,
  }) {
    final tag = gitTagFormat(name: name, version: version);
    return 'README.md does not reference $tag (git install).';
  }

  /// Matches the pub registry install form `<package>: ^<version>` only
  /// when surrounded by non-version characters.
  static RegExp _registryInstallPattern(String name, String version) {
    final escapedName = RegExp.escape(name);
    final escapedVersion = RegExp.escape(version);
    return RegExp(
      '$_boundaryOpen$escapedName$_constraintSeparator'
      '$escapedVersion$_boundaryClose',
    );
  }

  static String _registryInstallProblem(String name, String version) {
    return 'README.md does not reference $name: ^$version (registry install).';
  }

  const BuildStandardReleaseChecksBuilder();

  /// Params:
  /// - `gitTagFormat`: the git-tag naming convention the git-install check's
  ///   README reference must match.
  Map<String, VersionedFileCheck> build(GetTagFormat gitTagFormat) {
    return <String, VersionedFileCheck>{
      'changelog': const VersionedFileCheck(
        filePath: 'CHANGELOG.md',
        pattern: _changelogEntryPattern,
        problem: _changelogProblem,
        multiLine: true,
      ),
      'readme git install': VersionedFileCheck(
        filePath: 'README.md',
        pattern: (name, version) => _gitInstallPattern(
          gitTagFormat,
          name: name,
          version: version,
        ),
        problem: (name, version) => _gitInstallProblem(
          gitTagFormat,
          name: name,
          version: version,
        ),
      ),
      'readme registry install': const VersionedFileCheck(
        filePath: 'README.md',
        pattern: _registryInstallPattern,
        problem: _registryInstallProblem,
      ),
    };
  }
}

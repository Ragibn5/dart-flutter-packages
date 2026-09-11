import 'dart:io';

import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

class ReplaceTextInScope {
  final ConfirmYesNo _confirmYesNo;
  final IOSink _stdout;

  ReplaceTextInScope({
    ConfirmYesNo confirmYesNo = const ConfirmYesNo(),
    IOSink? stdOut,
  })  : _confirmYesNo = confirmYesNo,
        _stdout = stdOut ?? stdout;

  /// Replaces text across files in a directory tree.
  ///
  /// Params:
  /// - `srcText`: text to find, literal unless [regex] is set.
  /// - `targetText`: text to replace with.
  /// - `start`: directory to scan, absolute or relative to the current
  ///   working directory (default: the current directory).
  /// - `exclusions`: glob patterns defining exclusions under [start].
  /// - `followLinks`: follow directory symlinks while scanning
  ///   (default: false).
  /// - `ignoreCase`: match case-insensitively.
  /// - `matchWord`: only replace whole-word matches.
  /// - `regex`: treat [srcText] as a regular expression.
  /// - `interactive`: confirm before replacing when matches are found.
  ///
  /// Returns: the number of occurrences replaced (or found, when the
  /// change is declined or interactive is false).
  ///
  /// Throws:
  /// - [ArgumentError] when `srcText` or `targetText` is empty.
  ///
  /// Notes: an individual file that can't be read as text (binary,
  /// non-UTF-8, permission errors) is skipped, not thrown for.
  Future<int> call({
    required String srcText,
    required String targetText,
    String? start,
    List<String> exclusions = const [],
    bool followLinks = false,
    bool ignoreCase = false,
    bool matchWord = false,
    bool regex = false,
    bool interactive = true,
  }) async {
    if (srcText.isEmpty || targetText.isEmpty) {
      throw ArgumentError('Both source and target text are required.');
    }

    final excludedGlobs =
        exclusions.map(_normalizeGlobPattern).map(Glob.new).toList();
    final matcher = _buildMatcher(
      srcText,
      ignoreCase: ignoreCase,
      matchWord: matchWord,
      regex: regex,
    );

    var totalOccurrences = 0;
    final matches = <File, String>{};
    final root = Directory(start ?? Directory.current.path).absolute;

    final candidates =
        root.list(recursive: true, followLinks: followLinks).where(
              (entity) => !_isSkipped(
                p.relative(entity.path, from: root.path).replaceAll(r'\', '/'),
                excludedGlobs,
              ),
            );

    await for (final entity in candidates) {
      if (entity is! File) continue;

      final String content;
      try {
        content = await entity.readAsString();
      } catch (_) {
        // Skip unreadable files (binary, non-UTF-8, permission errors, etc).
        continue;
      }

      final count = matcher.allMatches(content).length;
      if (count > 0) {
        matches[entity] = content;
        totalOccurrences += count;
      }
    }

    if (totalOccurrences == 0) {
      _stdout.writeln('No occurrence(s) of given pattern.');
      return 0;
    }

    if (interactive &&
        !await _confirmYesNo(
          'Replace "$srcText" with "$targetText" in all the files?',
        )) {
      _stdout.writeln('Replaced $totalOccurrences occurrence(s).');
      return totalOccurrences;
    }

    for (final entry in matches.entries) {
      await entry.key
          .writeAsString(entry.value.replaceAll(matcher, targetText));
    }

    _stdout.writeln('Replaced $totalOccurrences occurrence(s).');
    return totalOccurrences;
  }

  RegExp _buildMatcher(
    String srcText, {
    required bool ignoreCase,
    required bool matchWord,
    required bool regex,
  }) {
    final sourcePattern = regex ? srcText : RegExp.escape(srcText);
    final pattern = matchWord ? '\\b(?:$sourcePattern)\\b' : sourcePattern;
    final matcher = RegExp(pattern, caseSensitive: !ignoreCase);
    return matcher;
  }

  bool _isSkipped(String relativePath, List<Glob> excludedGlobs) {
    var prefix = '';
    for (final segment in relativePath.split('/')) {
      prefix = prefix.isEmpty ? segment : '$prefix/$segment';
      for (final glob in excludedGlobs) {
        if (glob.matches(prefix)) return true;
      }
    }
    return false;
  }

  String _normalizeGlobPattern(String pattern) {
    return pattern.replaceFirst(RegExp(r'/+$'), '');
  }
}

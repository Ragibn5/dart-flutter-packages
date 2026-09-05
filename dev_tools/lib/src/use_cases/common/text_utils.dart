import 'dart:io';

import 'package:dev_tools/src/use_cases/common/confirm_yes_no.dart';

class TextUtils {
  final ConfirmYesNo _confirmYesNo;
  final IOSink _stdout;

  TextUtils({
    ConfirmYesNo confirmYesNo = const ConfirmYesNo(),
    IOSink? stdout,
  })  : _confirmYesNo = confirmYesNo,
        _stdout = stdout ?? TextUtils._stdOut;

  static IOSink get _stdOut => stdout;

  /// Replaces literal text across files in a directory tree.
  ///
  /// Params:
  /// - `srcText`: literal text to find.
  /// - `targetText`: literal text to replace with.
  /// - `start`: directory to scan, absolute or relative to the current
  ///   working directory (default: the current directory).
  /// - `interactive`: confirm before replacing when matches are found.
  /// - `isTextFile`: optional predicate to decide which files to scan.
  ///
  /// Returns: the number of occurrences replaced (or found, when the change
  /// is declined or interactive is false).
  ///
  /// Notes: binary-like files and build artifacts are skipped.
  Future<int> call({
    required String srcText,
    required String targetText,
    String? start,
    bool interactive = true,
    bool Function(File file)? isTextFile,
  }) async {
    if (srcText.isEmpty || targetText.isEmpty) {
      throw ArgumentError('Both source and target text are required.');
    }

    final root = Directory(start ?? Directory.current.path).absolute;
    final matches = <File>[];
    var totalOccurrences = 0;

    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      if (entity.path.contains('.dart_tool')) continue;
      if (entity.path.contains('${Platform.pathSeparator}build')) continue;
      if (!_isTextLike(entity, isTextFile)) continue;

      final content = await entity.readAsString();
      final count = _countOccurrences(content, srcText);
      if (count > 0) {
        matches.add(entity);
        totalOccurrences += count;
      }
    }

    if (totalOccurrences == 0) {
      return 0;
    }

    if (interactive &&
        !await _confirmYesNo(
          'Replace "$srcText" with "$targetText" in all the files?',
        )) {
      _stdout.writeln('Replaced $totalOccurrences occurrence(s).');
      return totalOccurrences;
    }

    for (final file in matches) {
      final content = await file.readAsString();
      await file.writeAsString(content.replaceAll(srcText, targetText));
    }

    _stdout.writeln('Replaced $totalOccurrences occurrence(s).');
    return totalOccurrences;
  }

  int _countOccurrences(String content, String needle) {
    if (needle.isEmpty) return 0;
    var count = 0;
    var index = 0;
    while ((index = content.indexOf(needle, index)) != -1) {
      count++;
      index += needle.length;
    }
    return count;
  }

  bool _isTextLike(File file, bool Function(File)? isTextFile) {
    if (isTextFile != null) return isTextFile(file);
    const binaryExtensions = {
      '.png',
      '.jpg',
      '.jpeg',
      '.gif',
      '.webp',
      '.ico',
      '.pdf',
      '.zip',
      '.gz',
      '.tar',
      '.apk',
      '.aab',
      '.ipa',
      '.dylib',
      '.so',
      '.dll',
    };
    final extension = file.path.split('.').last.toLowerCase();
    return !binaryExtensions.contains(extension);
  }
}

import 'dart:io';

import 'package:dev_tools/src/utils/prompt_utils.dart';

/// Utilities for finding and replacing literal text across files.
///
/// Mirrors `text_utils.sh`.
class TextUtils {
  final PromptUtils _promptUtils;

  const TextUtils({PromptUtils promptUtils = const PromptUtils()})
    : _promptUtils = promptUtils;

  /// Replaces every occurrence of [srcText] with [targetText] across all
  /// text files found beneath [start] (defaults to current working directory).
  ///
  /// When [interactive] is `true` (default), the user is prompted for
  /// confirmation before any file is modified.
  ///
  /// Returns the number of occurrences that were matched. If the user
  /// declines, no files are modified and the matched count is still returned.
  Future<int> replaceTextInFiles({
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
        !await _promptUtils.confirmYesNo(
          'Replace "$srcText" with "$targetText" in all the files?',
        )) {
      return totalOccurrences;
    }

    for (final file in matches) {
      final content = await file.readAsString();
      await file.writeAsString(content.replaceAll(srcText, targetText));
    }

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

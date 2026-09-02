import 'dart:io';

import 'package:dev_tools/dev_tools.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('text_utils_test'));

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('replaceTextInFiles', () {
    test('replaces text across files and returns the count', () async {
      final fileA = File('${tempDir.path}/a.dart')
        ..writeAsStringSync('hello world\nhello again\n');
      final fileB = File('${tempDir.path}/b.txt')
        ..writeAsStringSync('nothing here\n');

      final count = await const TextUtils().replaceTextInFiles(
        srcText: 'hello',
        targetText: 'goodbye',
        start: tempDir.path,
        interactive: false,
      );

      expect(count, 2);
      expect(fileA.readAsStringSync(), 'goodbye world\ngoodbye again\n');
      expect(fileB.readAsStringSync(), 'nothing here\n');
    });

    test('skips binary extensions', () async {
      final binary = File('${tempDir.path}/logo.png')
        ..writeAsBytesSync(List.filled(8, 0));
      final text = File('${tempDir.path}/readme.md')
        ..writeAsStringSync('foo bar\n');

      final count = await const TextUtils().replaceTextInFiles(
        srcText: 'foo',
        targetText: 'baz',
        start: tempDir.path,
        interactive: false,
      );

      expect(count, 1);
      expect(binary.readAsBytesSync(), List.filled(8, 0));
      expect(text.readAsStringSync(), 'baz bar\n');
    });

    test('throws when either text is empty', () {
      expect(
        () => const TextUtils().replaceTextInFiles(
          srcText: '',
          targetText: 'b',
          interactive: false,
        ),
        throwsArgumentError,
      );
    });
  });
}

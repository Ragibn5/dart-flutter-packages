import 'dart:io';

import 'package:dev_tools/src/use_cases/text_utils.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  late TextUtils sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('text_utils_test');

    sut = const TextUtils();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('should replace text across files and return the count', () async {
    final fileA = File('${tempDir.path}/a.dart')
      ..writeAsStringSync('hello world\nhello again\n');
    final fileB = File('${tempDir.path}/b.txt')
      ..writeAsStringSync('nothing here\n');

    final count = await sut(
      srcText: 'hello',
      targetText: 'goodbye',
      start: tempDir.path,
      interactive: false,
    );

    expect(count, 2);
    expect(fileA.readAsStringSync(), 'goodbye world\ngoodbye again\n');
    expect(fileB.readAsStringSync(), 'nothing here\n');
  });

  test('should skip binary files', () async {
    final binary = File('${tempDir.path}/logo.png')
      ..writeAsBytesSync(List.filled(8, 0));
    final text = File('${tempDir.path}/readme.md')
      ..writeAsStringSync('foo bar\n');

    final count = await sut(
      srcText: 'foo',
      targetText: 'baz',
      start: tempDir.path,
      interactive: false,
    );

    expect(count, 1);
    expect(binary.readAsBytesSync(), List.filled(8, 0));
    expect(text.readAsStringSync(), 'baz bar\n');
  });

  test('should skip files under .dart_tool and build directories', () async {
    File('${tempDir.path}/a.dart').writeAsStringSync('foo foo\n');
    final dartTool = Directory('${tempDir.path}/.dart_tool')..createSync();
    File('${dartTool.path}/cache.dart').writeAsStringSync('foo foo\n');

    final count = await sut(
      srcText: 'foo',
      targetText: 'bar',
      start: tempDir.path,
      interactive: false,
    );

    expect(count, 2);
    expect(File('${dartTool.path}/cache.dart').readAsStringSync(), 'foo foo\n');
  });

  test('should return 0 when no occurrences are found', () async {
    File('${tempDir.path}/a.txt').writeAsStringSync('no match here\n');

    final count = await sut(
      srcText: 'missing',
      targetText: 'x',
      start: tempDir.path,
      interactive: false,
    );

    expect(count, 0);
  });

  test('should throw ArgumentError when srcText is empty', () {
    expect(
      () => sut(srcText: '', targetText: 'b', interactive: false),
      throwsArgumentError,
    );
  });

  test('should throw ArgumentError when targetText is empty', () {
    expect(
      () => sut(srcText: 'a', targetText: '', interactive: false),
      throwsArgumentError,
    );
  });
}

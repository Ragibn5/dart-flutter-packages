import 'dart:convert';
import 'dart:io';

import 'package:dev_tools/src/use_cases/common/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/common/text_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockConfirmYesNo extends Mock implements ConfirmYesNo {}

class _BufferSink implements IOSink {
  final StringBuffer _buffer;

  _BufferSink(this._buffer);

  @override
  Encoding get encoding => utf8;

  @override
  set encoding(Encoding value) {}

  @override
  Future<void> get done => Future.value();

  @override
  void add(List<int> data) => _buffer.write(utf8.decode(data));

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      add(chunk);
    }
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> flush() async {}

  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = '']) => _buffer.writeln(object);
}

void main() {
  late Directory tempDir;

  late StringBuffer out;
  late _MockConfirmYesNo confirmYesNo;

  late TextUtils sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('text_utils_test');
    out = StringBuffer();
    confirmYesNo = _MockConfirmYesNo();

    when(() => confirmYesNo(any())).thenAnswer((_) async => true);

    sut = TextUtils(
      stdout: _BufferSink(out),
      confirmYesNo: confirmYesNo,
    );
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
    expect(out.toString(), contains('Replaced 2 occurrence(s).'));
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

  test(
    'should leave files unchanged and report the count when declined',
    () async {
      when(() => confirmYesNo(any())).thenAnswer((_) async => false);
      final file = File('${tempDir.path}/a.txt')
        ..writeAsStringSync('hello hello\n');

      final count = await sut(
        srcText: 'hello',
        targetText: 'goodbye',
        start: tempDir.path,
      );

      expect(count, 2);
      expect(file.readAsStringSync(), 'hello hello\n');
      expect(out.toString(), contains('Replaced 2 occurrence(s).'));
    },
  );

  test('should ask for confirmation before replacing when interactive',
      () async {
    File('${tempDir.path}/a.txt').writeAsStringSync('hello\n');

    await sut(
      srcText: 'hello',
      targetText: 'goodbye',
      start: tempDir.path,
    );

    verify(() =>
            confirmYesNo('Replace "hello" with "goodbye" in all the files?'))
        .called(1);
  });

  test('should honor an injected isTextFile callback', () async {
    final anyExtension = File('${tempDir.path}/data.bin')
      ..writeAsStringSync('hello hello\n');

    final count = await sut(
      srcText: 'hello',
      targetText: 'goodbye',
      start: tempDir.path,
      interactive: false,
      isTextFile: (file) => file.path.endsWith('.bin'),
    );

    expect(count, 2);
    expect(anyExtension.readAsStringSync(), 'goodbye goodbye\n');
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

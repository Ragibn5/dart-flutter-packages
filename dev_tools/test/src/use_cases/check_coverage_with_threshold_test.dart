// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';
import 'dart:io';

import 'package:dev_tools/src/use_cases/calculate_coverage.dart';
import 'package:dev_tools/src/use_cases/check_coverage_with_threshold.dart';
import 'package:dev_tools/src/use_cases/find_project_root.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFindProjectRoot extends Mock implements FindProjectRoot {}

class _MockCalculateCoverage extends Mock implements CalculateCoverage {}

void main() {
  const root = '/fake/root';

  late _MockFindProjectRoot findProjectRoot;
  late _MockCalculateCoverage coverageUtils;
  late StringBuffer out;

  late CheckCoverageWithThreshold sut;

  setUp(() {
    findProjectRoot = _MockFindProjectRoot();
    coverageUtils = _MockCalculateCoverage();
    out = StringBuffer();

    when(() => findProjectRoot()).thenAnswer((_) async => root);
    when(() => coverageUtils(any(), any())).thenAnswer((_) async => 100);

    sut = CheckCoverageWithThreshold(
      findProjectRoot: findProjectRoot,
      coverageUtils: coverageUtils,
      stdout: _BufferSink(out),
    );
  });

  test('should not throw when coverage meets the threshold', () async {
    await expectLater(sut(), completes);
  });

  test('should not throw when coverage exceeds the threshold', () async {
    when(() => coverageUtils(any(), any())).thenAnswer((_) async => 95);

    await expectLater(sut(threshold: 90), completes);
  });

  test('should write coverage message to stdout on success', () async {
    await sut();

    expect(out.toString(), contains('Coverage meets required 100%'));
  });

  test(
    'should throw CheckCoverageWithThresholdException when coverage is below threshold',
    () async {
      when(() => coverageUtils(any(), any())).thenAnswer((_) async => 80);

      await expectLater(
        sut(),
        throwsA(isA<CheckCoverageWithThresholdException>()),
      );
    },
  );
}

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

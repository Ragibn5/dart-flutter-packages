import 'dart:io';

import 'package:dev_tools/src/use_cases/calculate_coverage.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  late CalculateCoverage sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('calculate_coverage_test');
    Directory('${tempDir.path}/coverage').createSync();

    sut = const CalculateCoverage();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test(
    'should return rounded line coverage when lcov summary is parseable',
    () async {
      _writeLcovFile('${tempDir.path}/coverage/lcov.info');

      final pct = await sut('coverage/lcov.info', tempDir.path);
      expect(pct, 50);
    },
    skip: _lcovNotAvailable ? 'lcov not available' : null,
  );

  test(
    'should throw CoverageCalculationException when file does not exist',
    () async {
      expect(
        () => sut('coverage/missing.info', tempDir.path),
        throwsA(isA<CoverageCalculationException>()),
      );
    },
  );

  test(
    'should throw CoverageCalculationException when output cannot be parsed',
    () async {
      File(
        '${tempDir.path}/coverage/lcov.info',
      ).writeAsStringSync('garbage output without lines\n');

      expect(
        () => sut('coverage/lcov.info', tempDir.path),
        throwsA(isA<CoverageCalculationException>()),
      );
    },
    skip: _lcovNotAvailable ? 'lcov not available' : null,
  );
}

bool get _lcovNotAvailable => Process.runSync('which', ['lcov']).exitCode != 0;

void _writeLcovFile(String path) {
  File(path).writeAsStringSync(
    'TN:\n'
    'SF:lib/foo.dart\n'
    'DA:1,2\n'
    'DA:2,0\n'
    'LF:2\n'
    'LH:1\n'
    'end_of_record\n',
  );
}

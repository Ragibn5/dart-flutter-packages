// ignore_for_file: lines_longer_than_80_chars

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

  late CheckCoverageWithThreshold sut;

  setUp(() {
    findProjectRoot = _MockFindProjectRoot();
    coverageUtils = _MockCalculateCoverage();

    when(() => findProjectRoot()).thenAnswer((_) async => root);
    when(() => coverageUtils(any(), any())).thenAnswer((_) async => 100);

    sut = CheckCoverageWithThreshold(
      findProjectRoot: findProjectRoot,
      coverageUtils: coverageUtils,
    );
  });

  test('should not throw when coverage meets the threshold', () async {
    await expectLater(sut(), completes);
  });

  test('should not throw when coverage exceeds the threshold', () async {
    when(() => coverageUtils(any(), any())).thenAnswer((_) async => 95);

    await expectLater(sut(threshold: 90), completes);
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

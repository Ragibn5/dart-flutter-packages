// ignore_for_file: lines_longer_than_80_chars

import 'package:dev_tools/src/use_cases/calculate_coverage.dart';
import 'package:dev_tools/src/use_cases/check_coverage_with_threshold.dart';
import 'package:dev_tools/src/use_cases/find_project_root.dart';
import 'package:test/test.dart';

void main() {
  const root = '/fake/root';

  late _FakeFindProjectRoot findProjectRoot;
  late _FakeCalculateCoverage coverageUtils;

  late CheckCoverageWithThreshold sut;

  setUp(() {
    findProjectRoot = const _FakeFindProjectRoot(root);
    coverageUtils = _FakeCalculateCoverage(100);

    sut = CheckCoverageWithThreshold(
      findProjectRoot: findProjectRoot,
      coverageUtils: coverageUtils,
    );
  });

  test('should not throw when coverage meets the threshold', () async {
    await expectLater(sut(), completes);
  });

  test('should not throw when coverage exceeds the threshold', () async {
    coverageUtils.percent = 95;

    await expectLater(sut(threshold: 90), completes);
  });

  test(
    'should throw CheckCoverageWithThresholdException when coverage is below threshold',
    () async {
      coverageUtils.percent = 80;

      await expectLater(
        sut(),
        throwsA(isA<CheckCoverageWithThresholdException>()),
      );
    },
  );
}

class _FakeFindProjectRoot extends FindProjectRoot {
  const _FakeFindProjectRoot(this.root);

  final String root;

  @override
  Future<String> call([String? start]) async => root;
}

class _FakeCalculateCoverage extends CalculateCoverage {
  _FakeCalculateCoverage(this.percent);

  int percent;

  @override
  Future<int> call(String lcovFile, [String? projectRoot]) async => percent;
}

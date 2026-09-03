import 'package:dev_tools/src/use_cases/calculate_coverage.dart';
import 'package:dev_tools/src/use_cases/check_coverage_with_threshold.dart';
import 'package:dev_tools/src/use_cases/find_project_root.dart';
import 'package:test/test.dart';

void main() {
  const root = '/fake/root';

  test('should not throw when coverage meets the threshold', () async {
    const useCase = CheckCoverageWithThreshold(
      findProjectRoot: _FakeFindProjectRoot(root),
      coverageUtils: _FakeCalculateCoverage(100),
    );
    await expectLater(useCase(), completes);
  });

  test('should not throw when coverage exceeds the threshold', () async {
    const useCase = CheckCoverageWithThreshold(
      findProjectRoot: _FakeFindProjectRoot(root),
      coverageUtils: _FakeCalculateCoverage(95),
    );
    await expectLater(useCase(threshold: 90), completes);
  });

  test(
    'should throw CheckCoverageWithThresholdException when coverage is below threshold',
    () async {
      const useCase = CheckCoverageWithThreshold(
        findProjectRoot: _FakeFindProjectRoot(root),
        coverageUtils: _FakeCalculateCoverage(80),
      );
      await expectLater(
        useCase(),
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
  const _FakeCalculateCoverage(this.percent);

  final int percent;

  @override
  Future<int> call(String lcovFile, [String? projectRoot]) async => percent;
}

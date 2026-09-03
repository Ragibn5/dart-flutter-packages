import 'package:dev_tools/src/use_cases/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/get_current_branch.dart';
import 'package:dev_tools/src/use_cases/get_package_name.dart';
import 'package:dev_tools/src/use_cases/get_package_version.dart';
import 'package:dev_tools/src/use_cases/has_clean_working_tree.dart';
import 'package:dev_tools/src/use_cases/publish_validation_exception.dart';
import 'package:dev_tools/src/use_cases/run_publish_flow.dart';
import 'package:dev_tools/src/use_cases/validate_package_path.dart';
import 'package:test/test.dart';

void main() {
  test(
    'should throw PublishValidationException when in detached HEAD',
    () async {
      final useCase = _buildFlow(
        branch: null,
        name: 'foo',
        version: '1.0.0',
        clean: true,
      );
      await expectLater(
        useCase(repoRoot: '/fake'),
        throwsA(isA<PublishValidationException>()),
      );
    },
  );

  test(
    'should throw PublishValidationException when branch is not a release branch',
    () async {
      final useCase = _buildFlow(
        branch: 'main',
        name: 'foo',
        version: '1.0.0',
        clean: true,
      );
      await expectLater(
        useCase(repoRoot: '/fake'),
        throwsA(isA<PublishValidationException>()),
      );
    },
  );

  test(
    'should throw PublishValidationException when branch version mismatches pubspec',
    () async {
      final useCase = _buildFlow(
        branch: 'release/pkg-1.0.0',
        name: 'foo',
        version: '2.0.0',
        clean: true,
      );
      await expectLater(
        useCase(repoRoot: '/fake'),
        throwsA(isA<PublishValidationException>()),
      );
    },
  );

  test(
    'should cancel when working tree is dirty and user declines to continue',
    () async {
      final useCase = _buildFlow(
        branch: 'release/pkg-1.0.0',
        name: 'foo',
        version: '1.0.0',
        clean: false,
        confirm: false,
      );
      await expectLater(useCase(repoRoot: '/fake'), completes);
    },
  );
}

RunPublishFlow _buildFlow({
  required String? branch,
  required String name,
  required String version,
  required bool clean,
  bool confirm = true,
}) {
  return RunPublishFlow(
    getCurrentBranch: _FakeGetCurrentBranch(branch),
    validatePackagePath: const _FakeValidatePackagePath(),
    getPackageName: _FakeGetPackageName(name),
    getPackageVersion: _FakeGetPackageVersion(version),
    hasCleanWorkingTree: _FakeHasCleanWorkingTree(clean),
    confirmYesNo: _FakeConfirmYesNo(confirm),
  );
}

class _FakeGetCurrentBranch extends GetCurrentBranch {
  _FakeGetCurrentBranch(this.branch);

  final String? branch;

  @override
  Future<String?> call([String? repoRoot]) async => branch;
}

class _FakeValidatePackagePath extends ValidatePackagePath {
  const _FakeValidatePackagePath();

  @override
  void call(String repoRoot, String pkgPath) {}
}

class _FakeGetPackageName extends GetPackageName {
  _FakeGetPackageName(this.name);

  final String name;

  @override
  Future<String?> call(String repoRoot, String pkgPath) async => name;
}

class _FakeGetPackageVersion extends GetPackageVersion {
  _FakeGetPackageVersion(this.version);

  final String version;

  @override
  Future<String?> call(String repoRoot, String pkgPath) async => version;
}

class _FakeHasCleanWorkingTree extends HasCleanWorkingTree {
  _FakeHasCleanWorkingTree(this.clean);

  final bool clean;

  @override
  Future<bool> call([String? repoRoot]) async => clean;
}

class _FakeConfirmYesNo extends ConfirmYesNo {
  _FakeConfirmYesNo(this.response);

  final bool response;

  @override
  Future<bool> call(String question) async => response;
}

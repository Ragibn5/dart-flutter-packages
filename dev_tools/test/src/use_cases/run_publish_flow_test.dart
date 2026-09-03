// ignore_for_file: lines_longer_than_80_chars

import 'package:dev_tools/src/use_cases/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/get_current_branch.dart';
import 'package:dev_tools/src/use_cases/get_package_name.dart';
import 'package:dev_tools/src/use_cases/get_package_version.dart';
import 'package:dev_tools/src/use_cases/has_clean_working_tree.dart';
import 'package:dev_tools/src/use_cases/publish_validation_exception.dart';
import 'package:dev_tools/src/use_cases/run_publish_flow.dart';
import 'package:dev_tools/src/use_cases/validate_package_path.dart';
import 'package:test/test.dart';

class _FakeGetCurrentBranch extends GetCurrentBranch {
  _FakeGetCurrentBranch(this.branch);

  String? branch;

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

  String name;

  @override
  Future<String?> call(String repoRoot, String pkgPath) async => name;
}

class _FakeGetPackageVersion extends GetPackageVersion {
  _FakeGetPackageVersion(this.version);

  String version;

  @override
  Future<String?> call(String repoRoot, String pkgPath) async => version;
}

class _FakeHasCleanWorkingTree extends HasCleanWorkingTree {
  _FakeHasCleanWorkingTree({required this.clean});

  bool clean;

  @override
  Future<bool> call([String? repoRoot]) async => clean;
}

class _FakeConfirmYesNo extends ConfirmYesNo {
  _FakeConfirmYesNo({required this.response});

  bool response;

  @override
  Future<bool> call(String question) async => response;
}

void main() {
  late _FakeGetCurrentBranch getCurrentBranch;
  late _FakeGetPackageName getPackageName;
  late _FakeGetPackageVersion getPackageVersion;
  late _FakeHasCleanWorkingTree hasCleanWorkingTree;
  late _FakeConfirmYesNo confirmYesNo;

  late RunPublishFlow sut;

  setUp(() {
    getCurrentBranch = _FakeGetCurrentBranch('release/pkg-1.0.0');
    getPackageName = _FakeGetPackageName('foo');
    getPackageVersion = _FakeGetPackageVersion('1.0.0');
    hasCleanWorkingTree = _FakeHasCleanWorkingTree(clean: true);
    confirmYesNo = _FakeConfirmYesNo(response: true);

    sut = RunPublishFlow(
      getCurrentBranch: getCurrentBranch,
      validatePackagePath: const _FakeValidatePackagePath(),
      getPackageName: getPackageName,
      getPackageVersion: getPackageVersion,
      hasCleanWorkingTree: hasCleanWorkingTree,
      confirmYesNo: confirmYesNo,
    );
  });

  test(
    'should throw PublishValidationException when in detached HEAD',
    () async {
      getCurrentBranch.branch = null;

      await expectLater(
        sut(repoRoot: '/fake'),
        throwsA(isA<PublishValidationException>()),
      );
    },
  );

  test(
    'should throw PublishValidationException when branch is not a release branch',
    () async {
      getCurrentBranch.branch = 'main';

      await expectLater(
        sut(repoRoot: '/fake'),
        throwsA(isA<PublishValidationException>()),
      );
    },
  );

  test(
    'should throw PublishValidationException when branch version mismatches pubspec',
    () async {
      getPackageVersion.version = '2.0.0';

      await expectLater(
        sut(repoRoot: '/fake'),
        throwsA(isA<PublishValidationException>()),
      );
    },
  );

  test(
    'should cancel when working tree is dirty and user declines to continue',
    () async {
      hasCleanWorkingTree.clean = false;
      confirmYesNo.response = false;

      await expectLater(sut(repoRoot: '/fake'), completes);
    },
  );
}

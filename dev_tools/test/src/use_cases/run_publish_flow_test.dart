// ignore_for_file: lines_longer_than_80_chars

import 'package:dev_tools/src/use_cases/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/get_current_branch.dart';
import 'package:dev_tools/src/use_cases/get_package_name.dart';
import 'package:dev_tools/src/use_cases/get_package_version.dart';
import 'package:dev_tools/src/use_cases/has_clean_working_tree.dart';
import 'package:dev_tools/src/use_cases/publish_validation_exception.dart';
import 'package:dev_tools/src/use_cases/run_publish_flow.dart';
import 'package:dev_tools/src/use_cases/validate_package_path.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockGetCurrentBranch extends Mock implements GetCurrentBranch {}

class _MockValidatePackagePath extends Mock implements ValidatePackagePath {}

class _MockGetPackageName extends Mock implements GetPackageName {}

class _MockGetPackageVersion extends Mock implements GetPackageVersion {}

class _MockHasCleanWorkingTree extends Mock implements HasCleanWorkingTree {}

class _MockConfirmYesNo extends Mock implements ConfirmYesNo {}

void main() {
  late _MockGetCurrentBranch getCurrentBranch;
  late _MockValidatePackagePath validatePackagePath;
  late _MockGetPackageName getPackageName;
  late _MockGetPackageVersion getPackageVersion;
  late _MockHasCleanWorkingTree hasCleanWorkingTree;
  late _MockConfirmYesNo confirmYesNo;

  late RunPublishFlow sut;

  setUp(() {
    getCurrentBranch = _MockGetCurrentBranch();
    validatePackagePath = _MockValidatePackagePath();
    getPackageName = _MockGetPackageName();
    getPackageVersion = _MockGetPackageVersion();
    hasCleanWorkingTree = _MockHasCleanWorkingTree();
    confirmYesNo = _MockConfirmYesNo();

    when(() => getCurrentBranch(any()))
        .thenAnswer((_) async => 'release/pkg-1.0.0');
    when(() => validatePackagePath(any(), any())).thenReturn(null);
    when(() => getPackageName(any(), any())).thenAnswer((_) async => 'foo');
    when(() => getPackageVersion(any(), any()))
        .thenAnswer((_) async => '1.0.0');
    when(() => hasCleanWorkingTree(any())).thenAnswer((_) async => true);
    when(() => confirmYesNo(any())).thenAnswer((_) async => true);

    sut = RunPublishFlow(
      getCurrentBranch: getCurrentBranch,
      validatePackagePath: validatePackagePath,
      getPackageName: getPackageName,
      getPackageVersion: getPackageVersion,
      hasCleanWorkingTree: hasCleanWorkingTree,
      confirmYesNo: confirmYesNo,
    );
  });

  test(
    'should throw PublishValidationException when in detached HEAD',
    () async {
      when(() => getCurrentBranch(any())).thenAnswer((_) async => null);

      await expectLater(
        sut(repoRoot: '/fake'),
        throwsA(isA<PublishValidationException>()),
      );
    },
  );

  test(
    'should throw PublishValidationException when branch is not a release branch',
    () async {
      when(() => getCurrentBranch(any())).thenAnswer((_) async => 'main');

      await expectLater(
        sut(repoRoot: '/fake'),
        throwsA(isA<PublishValidationException>()),
      );
    },
  );

  test(
    'should throw PublishValidationException when branch version mismatches pubspec',
    () async {
      when(() => getPackageVersion(any(), any()))
          .thenAnswer((_) async => '2.0.0');

      await expectLater(
        sut(repoRoot: '/fake'),
        throwsA(isA<PublishValidationException>()),
      );
    },
  );

  test(
    'should cancel when working tree is dirty and user declines to continue',
    () async {
      when(() => hasCleanWorkingTree(any())).thenAnswer((_) async => false);
      when(() => confirmYesNo(any())).thenAnswer((_) async => false);

      await expectLater(sut(repoRoot: '/fake'), completes);
    },
  );
}

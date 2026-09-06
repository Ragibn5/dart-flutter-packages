// ignore_for_file: lines_longer_than_80_chars

import 'package:dev_tools/src/use_cases/git/has_clean_working_tree.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/publish/publish_validation_exception.dart';
import 'package:dev_tools/src/use_cases/publish/read_package_identity.dart';
import 'package:dev_tools/src/use_cases/publish/run_publish_flow.dart';
import 'package:dev_tools/src/use_cases/publish/validate_package_path.dart';
import 'package:dev_tools/src/use_cases/publish/verify_release_completeness.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockValidatePackagePath extends Mock implements ValidatePackagePath {}

class _MockReadPackageIdentity extends Mock implements ReadPackageIdentity {}

class _MockHasCleanWorkingTree extends Mock implements HasCleanWorkingTree {}

class _MockConfirmYesNo extends Mock implements ConfirmYesNo {}

class _MockVerifyReleaseCompleteness extends Mock
    implements VerifyReleaseCompleteness {}

class PublishAttempt {
  final String repoRoot;
  final String pkgPath;
  final bool dryRun;

  const PublishAttempt(this.repoRoot, this.pkgPath, {required this.dryRun});
}

List<(String, String, bool)> publishSignatures(List<PublishAttempt> calls) =>
    calls.map((call) => (call.repoRoot, call.pkgPath, call.dryRun)).toList();

PublishProcessRunner _okPublish(List<PublishAttempt> calls) {
  return (repoRoot, pkgPath, {required dryRun}) async {
    calls.add(PublishAttempt(repoRoot, pkgPath, dryRun: dryRun));
    return 0;
  };
}

PublishProcessRunner _failingPublish({
  required bool failingDryRun,
  required List<PublishAttempt> calls,
}) {
  return (repoRoot, pkgPath, {required dryRun}) async {
    calls.add(PublishAttempt(repoRoot, pkgPath, dryRun: dryRun));
    return dryRun == failingDryRun ? 1 : 0;
  };
}

void main() {
  const repoRoot = '/fake/repo';
  const pkgPath = 'pkg';
  const continuePrompt = 'Continue despite warnings?';
  const publishPrompt = 'Publish foo@1.0.0?';

  late _MockValidatePackagePath validatePackagePath;
  late _MockReadPackageIdentity readPackageIdentity;
  late _MockHasCleanWorkingTree hasCleanWorkingTree;
  late _MockConfirmYesNo confirmYesNo;
  late _MockVerifyReleaseCompleteness verifyReleaseCompleteness;

  late List<PublishAttempt> publishCalls;
  late PublishProcessRunner publish;
  late RunPublishFlow sut;

  RunPublishFlow buildSut() => RunPublishFlow(
        validatePackagePath: validatePackagePath,
        readPackageIdentity: readPackageIdentity,
        hasCleanWorkingTree: hasCleanWorkingTree,
        confirmYesNo: confirmYesNo,
        verifyReleaseCompleteness: verifyReleaseCompleteness,
        publish: publish,
      );

  setUp(() {
    validatePackagePath = _MockValidatePackagePath();
    readPackageIdentity = _MockReadPackageIdentity();
    hasCleanWorkingTree = _MockHasCleanWorkingTree();
    confirmYesNo = _MockConfirmYesNo();
    verifyReleaseCompleteness = _MockVerifyReleaseCompleteness();
    publishCalls = <PublishAttempt>[];
    publish = _okPublish(publishCalls);

    when(() => validatePackagePath(any(), any())).thenReturn(null);
    when(() => readPackageIdentity(any(), any())).thenAnswer(
      (_) async => const PackageIdentity(name: 'foo', version: '1.0.0'),
    );
    when(() => verifyReleaseCompleteness(
          repoRoot: any(named: 'repoRoot'),
          pkgPath: any(named: 'pkgPath'),
        )).thenAnswer((_) async {});
    when(() => hasCleanWorkingTree(any())).thenAnswer((_) async => true);
    when(() => confirmYesNo(any())).thenAnswer((_) async => true);

    sut = buildSut();
  });

  test(
    'should throw PublishValidationException when the release is incomplete',
    () async {
      when(() => verifyReleaseCompleteness(
            repoRoot: any(named: 'repoRoot'),
            pkgPath: any(named: 'pkgPath'),
          )).thenThrow(const PublishValidationException(
        'Error: Release is incomplete for foo@1.0.0.',
      ));

      await expectLater(
        sut(repoRoot: repoRoot, pkgPath: pkgPath),
        throwsA(isA<PublishValidationException>()),
      );
      expect(publishCalls, isEmpty);
    },
  );

  test(
    'should cancel when the working tree is dirty and the user declines',
    () async {
      when(() => hasCleanWorkingTree(any())).thenAnswer((_) async => false);
      when(() => confirmYesNo(any(that: equals(continuePrompt))))
          .thenAnswer((_) async => false);

      await expectLater(
        sut(repoRoot: repoRoot, pkgPath: pkgPath),
        completes,
      );

      expect(publishCalls, isEmpty);
    },
  );

  test(
    'should continue when the working tree is dirty and the user confirms',
    () async {
      when(() => hasCleanWorkingTree(any())).thenAnswer((_) async => false);
      when(() => confirmYesNo(any(that: equals(continuePrompt))))
          .thenAnswer((_) async => true);
      when(() => confirmYesNo(any(that: equals(publishPrompt))))
          .thenAnswer((_) async => true);

      await expectLater(
        sut(repoRoot: repoRoot, pkgPath: pkgPath),
        completes,
      );

      expect(publishSignatures(publishCalls), <(String, String, bool)>[
        (repoRoot, pkgPath, true),
        (repoRoot, pkgPath, false),
      ]);
    },
  );

  test('should throw PublishFailedException when the dry-run publish fails',
      () async {
    publishCalls.clear();
    publish = _failingPublish(failingDryRun: true, calls: publishCalls);
    sut = buildSut();

    await expectLater(
      sut(repoRoot: repoRoot, pkgPath: pkgPath),
      throwsA(isA<PublishFailedException>()),
    );
    expect(publishCalls.map((call) => call.dryRun), <bool>[true]);
  });

  test('should skip the actual publish when dryRunOnly is true', () async {
    await expectLater(
      sut(repoRoot: repoRoot, pkgPath: pkgPath, dryRunOnly: true),
      completes,
    );

    expect(publishSignatures(publishCalls), <(String, String, bool)>[
      (repoRoot, pkgPath, true),
    ]);
  });

  test('should cancel when the user declines the final publish prompt',
      () async {
    when(() => confirmYesNo(any(that: equals(publishPrompt))))
        .thenAnswer((_) async => false);

    await expectLater(
      sut(repoRoot: repoRoot, pkgPath: pkgPath),
      completes,
    );

    expect(publishSignatures(publishCalls), <(String, String, bool)>[
      (repoRoot, pkgPath, true),
    ]);
  });

  test('should publish successfully end to end', () async {
    await expectLater(
      sut(repoRoot: repoRoot, pkgPath: pkgPath),
      completes,
    );

    expect(publishSignatures(publishCalls), <(String, String, bool)>[
      (repoRoot, pkgPath, true),
      (repoRoot, pkgPath, false),
    ]);
    verify(() => verifyReleaseCompleteness(
          repoRoot: repoRoot,
          pkgPath: pkgPath,
        )).called(1);
    verify(() => confirmYesNo(publishPrompt)).called(1);
  });

  test('should throw PublishFailedException when the actual publish fails',
      () async {
    publishCalls.clear();
    publish = _failingPublish(failingDryRun: false, calls: publishCalls);
    sut = buildSut();

    await expectLater(
      sut(repoRoot: repoRoot, pkgPath: pkgPath),
      throwsA(isA<PublishFailedException>()),
    );
    expect(publishCalls.map((call) => call.dryRun), <bool>[true, false]);
  });
}

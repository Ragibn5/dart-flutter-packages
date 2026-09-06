// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dev_tools/src/use_cases/git/has_clean_working_tree.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/publish/build_publish_command.dart';
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

class _MockBuildPublishCommand extends Mock implements BuildPublishCommand {}

class PublishAttempt {
  final String repoRoot;
  final String pkgPath;
  final PublishTooling tooling;
  final bool dryRun;

  const PublishAttempt(this.repoRoot, this.pkgPath, this.tooling,
      {required this.dryRun});
}

List<(String, String, String, bool)> publishSignatures(
  List<PublishAttempt> calls,
) =>
    calls
        .map((call) => (
              call.repoRoot,
              call.pkgPath,
              call.tooling.command,
              call.dryRun,
            ))
        .toList();

PublishProcessRunner _okPublish(List<PublishAttempt> calls) {
  return (repoRoot, pkgPath, {required tooling, required dryRun}) async {
    calls.add(PublishAttempt(repoRoot, pkgPath, tooling, dryRun: dryRun));
    return 0;
  };
}

PublishProcessRunner _failingPublish({
  required bool failingDryRun,
  required List<PublishAttempt> calls,
}) {
  return (repoRoot, pkgPath, {required tooling, required dryRun}) async {
    calls.add(PublishAttempt(repoRoot, pkgPath, tooling, dryRun: dryRun));
    return dryRun == failingDryRun ? 1 : 0;
  };
}

void main() {
  const repoRoot = '/fake/repo';
  const pkgPath = 'pkg';
  const continuePrompt = 'Continue despite warnings?';
  const publishPrompt = 'Publish foo@1.0.0?';

  setUpAll(() {
    registerFallbackValue(
      const PackageIdentity(name: 'foo', version: '1.0.0'),
    );
  });

  late _MockValidatePackagePath validatePackagePath;
  late _MockReadPackageIdentity readPackageIdentity;
  late _MockHasCleanWorkingTree hasCleanWorkingTree;
  late _MockConfirmYesNo confirmYesNo;
  late _MockVerifyReleaseCompleteness verifyReleaseCompleteness;
  late _MockBuildPublishCommand buildPublishCommand;

  late List<PublishAttempt> publishCalls;
  late PublishProcessRunner publish;
  late RunPublishFlow sut;

  RunPublishFlow buildSut() => RunPublishFlow(
        validatePackagePath: validatePackagePath,
        readPackageIdentity: readPackageIdentity,
        hasCleanWorkingTree: hasCleanWorkingTree,
        confirmYesNo: confirmYesNo,
        verifyReleaseCompleteness: verifyReleaseCompleteness,
        buildPublishCommand: buildPublishCommand,
        publish: publish,
      );

  setUp(() {
    validatePackagePath = _MockValidatePackagePath();
    readPackageIdentity = _MockReadPackageIdentity();
    hasCleanWorkingTree = _MockHasCleanWorkingTree();
    confirmYesNo = _MockConfirmYesNo();
    verifyReleaseCompleteness = _MockVerifyReleaseCompleteness();
    buildPublishCommand = _MockBuildPublishCommand();
    publishCalls = <PublishAttempt>[];
    publish = _okPublish(publishCalls);

    when(() => validatePackagePath(any(), any())).thenReturn(null);
    when(() => readPackageIdentity(any(), any())).thenAnswer(
      (_) async => const PackageIdentity(name: 'foo', version: '1.0.0'),
    );
    when(() => buildPublishCommand(any())).thenAnswer(
      (_) async => const PublishTooling('fvm dart'),
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
    'should cancel on the single confirmation when there is no scoped '
    'version and the user declines',
    () async {
      when(() => buildPublishCommand(any()))
          .thenAnswer((_) async => const PublishTooling('dart'));
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
    'should proceed with the system-wide toolchain when the user confirms',
    () async {
      when(() => buildPublishCommand(any()))
          .thenAnswer((_) async => const PublishTooling('dart'));
      when(() => confirmYesNo(any(that: equals(publishPrompt))))
          .thenAnswer((_) async => true);

      await expectLater(
        sut(repoRoot: repoRoot, pkgPath: pkgPath),
        completes,
      );

      expect(publishSignatures(publishCalls), <(String, String, String, bool)>[
        (repoRoot, pkgPath, 'dart', true),
        (repoRoot, pkgPath, 'dart', false),
      ]);
    },
  );

  test(
    'should forward the resolved fvm tooling to both publish calls',
    () async {
      when(() => buildPublishCommand(any()))
          .thenAnswer((_) async => const PublishTooling('fvm flutter'));

      await expectLater(
        sut(repoRoot: repoRoot, pkgPath: pkgPath),
        completes,
      );

      expect(publishSignatures(publishCalls), <(String, String, String, bool)>[
        (repoRoot, pkgPath, 'fvm flutter', true),
        (repoRoot, pkgPath, 'fvm flutter', false),
      ]);
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

      expect(publishSignatures(publishCalls), <(String, String, String, bool)>[
        (repoRoot, pkgPath, 'fvm dart', true),
        (repoRoot, pkgPath, 'fvm dart', false),
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

    expect(publishSignatures(publishCalls), <(String, String, String, bool)>[
      (repoRoot, pkgPath, 'fvm dart', true),
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

    expect(publishSignatures(publishCalls), <(String, String, String, bool)>[
      (repoRoot, pkgPath, 'fvm dart', true),
    ]);
  });

  test('should publish successfully end to end', () async {
    await expectLater(
      sut(repoRoot: repoRoot, pkgPath: pkgPath),
      completes,
    );

    expect(publishSignatures(publishCalls), <(String, String, String, bool)>[
      (repoRoot, pkgPath, 'fvm dart', true),
      (repoRoot, pkgPath, 'fvm dart', false),
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

  test(
    'should publish via the default runner using the resolved tooling prefix',
    () async {
      final tempDir =
          Directory.systemTemp.createTempSync('run_publish_flow_default');
      Directory('${tempDir.path}/pkg').createSync(recursive: true);
      final logFile = '${tempDir.path}/args.log';
      final script = _executableScript(
        tempDir,
        exitCode: 0,
        logFile: logFile,
      );
      when(() => buildPublishCommand(any()))
          .thenAnswer((_) async => PublishTooling(script));
      addTearDown(() {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      });

      sut = RunPublishFlow(
        validatePackagePath: validatePackagePath,
        readPackageIdentity: readPackageIdentity,
        hasCleanWorkingTree: hasCleanWorkingTree,
        confirmYesNo: confirmYesNo,
        verifyReleaseCompleteness: verifyReleaseCompleteness,
        buildPublishCommand: buildPublishCommand,
      );

      await expectLater(
        sut(repoRoot: tempDir.path, pkgPath: 'pkg'),
        completes,
      );

      final lines = File(logFile).readAsStringSync().trim().split('\n');
      expect(lines, <String>['pub publish --dry-run', 'pub publish']);
    },
  );

  test('should throw PublishFailedException when the default runner fails',
      () async {
    final tempDir =
        Directory.systemTemp.createTempSync('run_publish_flow_default_fail');
    Directory('${tempDir.path}/pkg').createSync(recursive: true);
    final logFile = '${tempDir.path}/args.log';
    final script = _executableScript(
      tempDir,
      exitCode: 1,
      logFile: logFile,
    );
    when(() => buildPublishCommand(any()))
        .thenAnswer((_) async => PublishTooling(script));
    addTearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    sut = RunPublishFlow(
      validatePackagePath: validatePackagePath,
      readPackageIdentity: readPackageIdentity,
      hasCleanWorkingTree: hasCleanWorkingTree,
      confirmYesNo: confirmYesNo,
      verifyReleaseCompleteness: verifyReleaseCompleteness,
      buildPublishCommand: buildPublishCommand,
    );

    await expectLater(
      sut(repoRoot: tempDir.path, pkgPath: 'pkg'),
      throwsA(isA<PublishFailedException>()),
    );

    final lines = File(logFile).readAsStringSync().trim().split('\n');
    expect(lines, <String>['pub publish --dry-run']);
  });
}

String _executableScript(
  Directory dir, {
  required int exitCode,
  required String logFile,
}) {
  final script = File('${dir.path}/cmd.sh')
    ..writeAsStringSync(
      '#!/bin/sh\nprintf "%s\\n" "\$*" >> "$logFile"\nexit $exitCode\n',
    );
  Process.runSync('chmod', ['+x', script.path]);
  return script.path;
}

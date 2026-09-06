import 'package:dev_tools/src/use_cases/dart_flutter/find_fvm_aware_dart_command.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_fvm_aware_flutter_command.dart';
import 'package:dev_tools/src/use_cases/publish/read_package_identity.dart';

/// Tooling selected for publishing a package.
class PublishTooling {
  /// The tool to run `pub publish` under, e.g. `fvm flutter`,
  /// `flutter`, `fvm dart` or `dart`.
  final String command;

  const PublishTooling(this.command);

  /// The command prefix to run `pub publish`, e.g. `['fvm', 'dart']`.
  List<String> get prefix =>
      command.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();

  /// True when publishing through the fvm wrapper.
  bool get usesFvm => prefix.isNotEmpty && prefix.first == 'fvm';
}

/// Resolves the executable used to publish a package, reusing the existing
/// fvm-aware Dart and Flutter command finders.
class BuildPublishCommand {
  final FindFvmAwareDartCommand _findDartCommand;
  final FindFvmAwareFlutterCommand _findFlutterCommand;

  const BuildPublishCommand({
    FindFvmAwareDartCommand findDartCommand = const FindFvmAwareDartCommand(),
    FindFvmAwareFlutterCommand findFlutterCommand =
        const FindFvmAwareFlutterCommand(),
  })  : _findDartCommand = findDartCommand,
        _findFlutterCommand = findFlutterCommand;

  /// Decides how to publish a package.
  ///
  /// Params:
  /// - `identity`: the package identity, whose `isFlutterPackage` selects
  ///   between the Flutter and Dart fvm-aware finders.
  ///
  /// Returns: the [PublishTooling] for the package.
  Future<PublishTooling> call(PackageIdentity identity) async {
    final command = identity.isFlutterPackage
        ? await _findFlutterCommand()
        : await _findDartCommand();
    return PublishTooling(command);
  }
}

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/git/detect_folder_changes_command.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';

class GitCommand extends Command<void> {
  static const String commandName = 'git';
  static const String commandDescription = 'Git related commands.\n\n'
      'Notes:\n'
      '- Release tags use the naming convention '
      '"${ResolveGitTagFormat.defaultGitTagFormat}" (the {name}/{version} '
      "placeholders are substituted with the package's name and version) "
      'by default.\n'
      '- This is a global setting shared by every command that creates or '
      'checks a release tag (e.g. validate-release-mr).\n'
      '- Override it for all of them at once by setting the '
      '${ResolveGitTagFormat.gitTagFormatEnvVar} environment variable to '
      'your own "{name}"/"{version}" template (e.g. "{name}@{version}").';

  GitCommand() {
    addSubcommand(DetectFolderChangesCommand());
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;
}

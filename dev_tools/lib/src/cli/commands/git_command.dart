import 'package:args/command_runner.dart';
import 'package:dev_tools/src/cli/commands/detect_folder_changes_command.dart';

/// Branch command with git-related helpers.
class GitCommand extends Command<void> {
  GitCommand() {
    addSubcommand(DetectFolderChangesCommand());
  }

  @override
  String get name => 'git';

  @override
  String get description => 'Git helpers for CI change detection.';
}

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/git/detect_folder_changes_command.dart';

class GitCommand extends Command<void> {
  static const String commandName = 'git';
  static const String commandDescription = 'Git related commands.';

  GitCommand() {
    addSubcommand(DetectFolderChangesCommand());
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;
}

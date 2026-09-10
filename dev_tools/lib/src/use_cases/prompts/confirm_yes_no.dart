import 'dart:io';

class ConfirmYesNo {
  const ConfirmYesNo();

  /// Prompts [question] and reads a yes/no answer from stdin.
  ///
  /// Params:
  /// - `question`: the question to print before `[y/n]: `.
  ///
  /// Returns: true for `y`/`yes` (case-insensitive); false for anything
  /// else, including no input.
  Future<bool> call(String question) async {
    stdout.write('$question [y/n]: ');
    final response = (stdin.readLineSync() ?? '').trim().toLowerCase();
    return response == 'y' || response == 'yes';
  }
}

import 'dart:io';

/// Interactive prompting utilities for the terminal.
///
/// Mirrors `prompt_utils.sh`.
class PromptUtils {
  const PromptUtils();

  /// Prompts the user with [question] and returns `true` when the response is
  /// an affirmative `y`/`yes` (case-insensitive), otherwise `false`.
  Future<bool> confirmYesNo(String question) async {
    stdout.write('$question [y/n]: ');
    final response = (stdin.readLineSync() ?? '').trim().toLowerCase();
    return response == 'y' || response == 'yes';
  }

  /// Prompts the user with [prompt], showing [defaultValue] as a suggestion.
  ///
  /// Returns [defaultValue] when the user provides no input.
  Future<String> promptWithDefault(String prompt, String defaultValue) async {
    stdout.write('$prompt [$defaultValue]: ');
    final input = (stdin.readLineSync() ?? '').trim();
    return input.isEmpty ? defaultValue : input;
  }
}

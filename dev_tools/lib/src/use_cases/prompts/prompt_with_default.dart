import 'dart:io';

class PromptWithDefault {
  const PromptWithDefault();

  /// Prompts [prompt] and reads a line from stdin, falling back to a default.
  ///
  /// Params:
  /// - `prompt`: the prompt to print before `[defaultValue]: `.
  /// - `defaultValue`: returned when the input is empty.
  ///
  /// Returns: the trimmed input, or [defaultValue] when empty.
  Future<String> call(String prompt, String defaultValue) async {
    stdout.write('$prompt [$defaultValue]: ');
    final input = (stdin.readLineSync() ?? '').trim();
    return input.isEmpty ? defaultValue : input;
  }
}

import 'dart:io';

class PromptWithDefault {
  const PromptWithDefault();

  Future<String> call(String prompt, String defaultValue) async {
    stdout.write('$prompt [$defaultValue]: ');
    final input = (stdin.readLineSync() ?? '').trim();
    return input.isEmpty ? defaultValue : input;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('should return default value when response is empty', () async {
    expect(await _runScript(''), 'default_value');
  });

  test('should return typed value when response is provided', () async {
    expect(await _runScript('typed'), 'typed');
  });

  test('should trim whitespace from response', () async {
    expect(await _runScript('  spaced  '), 'spaced');
  });
}

Future<String> _runScript(String input) async {
  final dir = Directory('${Directory.current.path}/test/src/use_cases/');
  final script = File('${dir.path}/_prompt_with_default_script.dart');
  script.writeAsString('''
import 'dart:io';

import 'package:dev_tools/src/use_cases/prompt_with_default.dart';

Future<void> main() async {
  final result = await const PromptWithDefault()('Prompt?', 'default_value');
  stdout.writeln('RESULT=\$result');
}
''');
  addTearDown(() {
    if (script.existsSync()) script.deleteSync();
  });

  final proc = await Process.start('dart', ['run', script.path]);
  proc.stdin.writeln(input);
  proc.stdin.close();
  final out = await proc.stdout.transform(utf8.decoder).join();
  await proc.exitCode;
  return out
      .split('\n')
      .firstWhere((line) => line.contains('RESULT='))
      .split('RESULT=')[1];
}

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('should return true when response is y', () async {
    expect(await _runScript('y'), 'true');
  });

  test('should return true when response is yes', () async {
    expect(await _runScript('yes'), 'true');
  });

  test('should return true when response is uppercase', () async {
    expect(await _runScript('Y'), 'true');
  });

  test('should return false when response is n', () async {
    expect(await _runScript('n'), 'false');
  });

  test('should return false when response is anything else', () async {
    expect(await _runScript('maybe'), 'false');
  });
}

Future<String> _runScript(String input) async {
  final dir = Directory('${Directory.current.path}/test/src/use_cases/');
  final script = File('${dir.path}/_confirm_yes_no_script.dart');
  script.writeAsString('''
import 'dart:io';

import 'package:dev_tools/src/use_cases/confirm_yes_no.dart';

Future<void> main() async {
  final result = await const ConfirmYesNo()('Confirm?');
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

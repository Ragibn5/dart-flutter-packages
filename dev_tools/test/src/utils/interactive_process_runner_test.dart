import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dev_tools/src/utils/interactive_process_runner.dart';
import 'package:test/test.dart';

class _BufferSink implements IOSink {
  final StringBuffer _buffer;

  _BufferSink(this._buffer);

  @override
  Encoding get encoding => utf8;

  @override
  set encoding(Encoding value) {}

  @override
  Future<void> get done => Future.value();

  @override
  void add(List<int> data) => _buffer.write(utf8.decode(data));

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      add(chunk);
    }
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> flush() async {}

  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = '']) {}
}

IOSink _stringBufferSink(StringBuffer buffer) => _BufferSink(buffer);

void main() {
  late Directory tempDir;
  late File script;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('runner_test');
    script = File('${tempDir.path}/_echo_script.dart');
    await script.writeAsString(r'''
      import 'dart:io';
      
      Future<void> main() async {
        stdout.writeln('HELLO_STDOUT');
        stderr.writeln('HELLO_STDERR');
        final input = stdin.readLineSync();
        stdout.writeln('GOT: $input');
      }
      ''');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('run returns the child exit code when process completes', () async {
    final out = StringBuffer();
    final err = StringBuffer();
    final runner = InteractiveProcessRunner(
      executable: 'dart',
      arguments: ['run', script.path],
      stdOut: _stringBufferSink(out),
      stdErr: _stringBufferSink(err),
    );

    final exitCode = await runner.run();

    expect(exitCode, 0);
  });

  test('run forwards stdout when child writes to stdout', () async {
    final out = StringBuffer();
    final err = StringBuffer();
    final runner = InteractiveProcessRunner(
      executable: 'dart',
      arguments: ['run', script.path],
      stdOut: _stringBufferSink(out),
      stdErr: _stringBufferSink(err),
    );

    await runner.run();

    expect(out.toString(), contains('HELLO_STDOUT'));
  });

  test('run forwards stderr when child writes to stderr', () async {
    final out = StringBuffer();
    final err = StringBuffer();
    final runner = InteractiveProcessRunner(
      executable: 'dart',
      arguments: ['run', script.path],
      stdOut: _stringBufferSink(out),
      stdErr: _stringBufferSink(err),
    );

    await runner.run();

    expect(err.toString(), contains('HELLO_STDERR'));
  });

  test('run forwards stdin when input is provided', () async {
    final out = StringBuffer();
    final err = StringBuffer();
    final inputController = StreamController<List<int>>();
    final runner = InteractiveProcessRunner(
      executable: 'dart',
      arguments: ['run', script.path],
      stdOut: _stringBufferSink(out),
      stdErr: _stringBufferSink(err),
      stdIn: inputController.stream,
    );

    final runFuture = runner.run();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    inputController.add(utf8.encode('from parent\n'));
    await inputController.close();

    final exitCode = await runFuture;
    expect(exitCode, 0);
    expect(out.toString(), contains('GOT: from parent'));
  });
}

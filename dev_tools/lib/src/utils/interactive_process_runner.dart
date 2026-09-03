import 'dart:async';
import 'dart:io';

class InteractiveProcessRunner {
  final String _executable;
  final List<String> _arguments;
  final IOSink _stdout;
  final IOSink _stderr;
  final Stream<List<int>>? _stdin;
  final String? _workingDirectory;

  InteractiveProcessRunner({
    required String executable,
    required List<String> arguments,
    String? workingDirectory,
    IOSink? stdOut,
    IOSink? stdErr,
    Stream<List<int>>? stdIn,
  })  : _executable = executable,
        _arguments = arguments,
        _workingDirectory = workingDirectory,
        _stdout = stdOut ?? stdout,
        _stderr = stdErr ?? stderr,
        _stdin = stdIn;

  Future<int> run() async {
    final process = await Process.start(
      _executable,
      _arguments,
      workingDirectory: _workingDirectory,
    );

    final stdoutDone = process.stdout.forEach(_stdout.add);
    final stderrDone = process.stderr.forEach(_stderr.add);
    final futures = <Future<void>>[stdoutDone, stderrDone];
    if (_stdin != null) {
      futures.add(process.stdin.addStream(_stdin!));
    } else {
      await process.stdin.close();
    }
    await Future.wait(futures);

    return process.exitCode;
  }
}

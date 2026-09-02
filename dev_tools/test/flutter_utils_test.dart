import 'package:dev_tools/dev_tools.dart';
import 'package:test/test.dart';

void main() {
  group('FlutterCommandFinder', () {
    test('returns a flutter command string', () async {
      final cmd = await const FvmAwareFlutterCommandFinder()();
      expect(cmd, anyOf('fvm flutter', 'flutter'));
    });
  });

  group('DartCommandFinder', () {
    test('returns a dart command string', () async {
      final cmd = await const FvmAwareDartCommandFinder()();
      expect(cmd, anyOf('fvm dart', 'dart'));
    });
  });
}

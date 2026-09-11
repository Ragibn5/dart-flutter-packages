import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:test/test.dart';

void main() {
  test('should expose the missing programs', () {
    const e = CommandNotFoundException(['lcov', 'genhtml']);
    expect(e.programs, ['lcov', 'genhtml']);
  });

  test('should list the missing programs in its message', () {
    const e = CommandNotFoundException(['lcov']);
    expect(e.toString(), contains("'lcov'"));
  });

  test('should list multiple missing programs separated by commas', () {
    const e = CommandNotFoundException(['lcov', 'genhtml']);
    final msg = e.toString();
    expect(msg, contains("'lcov'"));
    expect(msg, contains("'genhtml'"));
  });
}

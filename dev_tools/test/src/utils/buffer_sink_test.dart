import 'dart:convert';

import 'package:dev_tools/src/utils/buffer_sink.dart';
import 'package:test/test.dart';

void main() {
  late BufferSink sut;

  setUp(() {
    sut = BufferSink();
  });

  test('should start with empty contents', () {
    expect(sut.contents, isEmpty);
  });

  test('should capture bytes written via add', () {
    sut
      ..add(utf8.encode('hello '))
      ..add(utf8.encode('world'));

    expect(sut.contents, 'hello world');
  });

  test('should capture text written via write', () {
    sut
      ..write('foo')
      ..write(42);

    expect(sut.contents, 'foo42');
  });

  test('should capture a newline-terminated line written via writeln', () {
    sut.writeln('line');

    expect(sut.contents, 'line\n');
  });

  test('should join objects with the given separator via writeAll', () {
    sut.writeAll(['a', 'b', 'c'], '-');

    expect(sut.contents, 'a-b-c');
  });

  test('should capture a single character written via writeCharCode', () {
    sut.writeCharCode(65); // 'A'

    expect(sut.contents, 'A');
  });

  test('should capture bytes added via addStream', () async {
    final stream = Stream<List<int>>.fromIterable([
      utf8.encode('chunk1 '),
      utf8.encode('chunk2'),
    ]);

    await sut.addStream(stream);

    expect(sut.contents, 'chunk1 chunk2');
  });

  test('should not throw when addError, close, flush, or done are used', () {
    expect(() => sut.addError('boom'), returnsNormally);
    expect(sut.close(), completes);
    expect(sut.flush(), completes);
    expect(sut.done, completes);
  });
}

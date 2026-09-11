import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// A minimal [IOSink] that captures written bytes instead of printing them.
class BufferSink implements IOSink {
  final BytesBuilder _bytes = BytesBuilder();

  String get contents => utf8.decode(_bytes.toBytes(), allowMalformed: true);

  @override
  Encoding encoding = utf8;

  @override
  void add(List<int> data) => _bytes.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) => stream.forEach(add);

  @override
  Future<void> close() async {}

  @override
  Future<void> get done => Future.value();

  @override
  Future<void> flush() async {}

  @override
  void write(Object? object) => add(encoding.encode('$object'));

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) =>
      write(objects.join(separator));

  @override
  void writeCharCode(int charCode) => add([charCode]);

  @override
  void writeln([Object? object = '']) => write('$object\n');
}

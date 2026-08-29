import 'package:net_client/src/contracts/mappable.dart';

sealed class FileSource implements Mappable {
  const FileSource();
}

final class BytesSource extends FileSource {
  final List<int> bytes;

  const BytesSource(this.bytes);

  @override
  Map<String, dynamic> toMap() {
    return {'bytes': bytes};
  }
}

final class StreamSource extends FileSource {
  final int length;
  final Stream<List<int>> stream;

  const StreamSource(this.length, this.stream);

  @override
  Map<String, dynamic> toMap() {
    return {'length': length, 'stream': stream};
  }
}

import 'package:net_client/src/contracts/mappable.dart';

sealed class RawData implements Mappable {
  const RawData();
}

final class RawString extends RawData {
  final String value;

  const RawString(this.value);

  @override
  Map<String, dynamic> toMap() {
    return {'value': value};
  }
}

final class RawBytes extends RawData {
  final List<int> bytes;

  const RawBytes(this.bytes);

  @override
  Map<String, dynamic> toMap() {
    return {'bytes': bytes};
  }
}

final class RawStream extends RawData {
  final int length;
  final Stream<List<int>> stream;

  const RawStream(this.length, this.stream);

  @override
  Map<String, dynamic> toMap() {
    return {'length': length, 'stream': stream};
  }
}

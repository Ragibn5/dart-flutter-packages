import 'package:net_client/net_client.dart';
import 'package:net_models/net_models.dart';

abstract interface class NetClientResponseDecoder<Err, Res> {
  ApiResponse<Err, Res> decodeResponse(NetClientResponse response);
}

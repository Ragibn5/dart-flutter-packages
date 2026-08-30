import 'package:net_client/net_client.dart';

abstract interface class NetClientRequestBuilder<Req> {
  RequestSpec createRequest(Req body);
}

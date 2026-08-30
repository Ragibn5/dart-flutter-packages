import 'package:dart_functionals/dart_functionals.dart';
import 'package:net_client/src/models/net_client_exception.dart';
import 'package:net_client/src/models/net_client_response.dart';

typedef ApiCallResult = Result<NetClientException, NetClientResponse>;

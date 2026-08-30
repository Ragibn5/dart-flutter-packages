import 'package:meta/meta.dart';
import 'package:net_client/src/clients/dio/dio_factory.dart';
import 'package:net_client/src/clients/dio/dio_request_adapter.dart';
import 'package:net_client/src/clients/interceptor_pipeline.dart';
import 'package:net_client/src/clients/net_client.dart';
import 'package:net_client/src/clients/net_client_impl.dart';
import 'package:net_client/src/models/client_config.dart';

/// Public construction entry point for [NetClient] implementations.
final class NetClientFactory {
  final DioFactory _dioFactory;

  NetClientFactory() : this._(const DioFactory());

  @visibleForTesting
  const NetClientFactory.test(DioFactory dioFactory) : this._(dioFactory);

  const NetClientFactory._(this._dioFactory);

  NetClient create([ClientConfig clientConfig = const ClientConfig()]) {
    return NetClientImpl(
      clientConfig: clientConfig,
      interceptorPipeline: InterceptorPipeline(),
      requestAdapter: DioRequestAdapter(_dioFactory.createDio(clientConfig)),
    );
  }
}

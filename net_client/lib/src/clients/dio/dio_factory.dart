import 'package:dio/dio.dart';
import 'package:net_client/src/models/client_config.dart';

class DioFactory {
  const DioFactory();

  Dio createDio(ClientConfig clientConfig) {
    return Dio(
      BaseOptions(
        baseUrl: clientConfig.baseUrl ?? '',
        connectTimeout: clientConfig.connectionTimeout,
        sendTimeout: clientConfig.sendTimeout,
        receiveTimeout: clientConfig.receiveTimeout,
        queryParameters: clientConfig.queryParameters,
        headers: clientConfig.headers,
        followRedirects: clientConfig.followRedirects,
        maxRedirects: clientConfig.maxRedirects,
      ),
    );
  }
}

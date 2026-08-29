import 'package:dio/dio.dart';
import 'package:net_client/net_client.dart';
import 'package:net_client/src/clients/dio/dio_cancel_token_builder.dart';
import 'package:net_client/src/clients/dio/dio_request_body_transformer.dart';
import 'package:net_client/src/services/mappers/response_status_validator.dart';
import 'package:net_client/src/types/progress_listener.dart';

class DioRequestOptionsBuilder {
  final ResponseStatusValidator _responseStatusValidator;

  final DioCancelTokenBuilder _cancelTokenBuilder;
  final DioRequestBodyTransformer _requestBodyTransformer;

  const DioRequestOptionsBuilder([
    this._responseStatusValidator = const DefaultResponseStatusValidator(),
    this._cancelTokenBuilder = const DioCancelTokenBuilder(),
    this._requestBodyTransformer = const DioRequestBodyTransformer(),
  ]);

  RequestOptions build({
    required RequestSpec spec,
    required RequestCanceller? canceller,
    required ProgressListener? onSendProgress,
    required ProgressListener? onReceiveProgress,
  }) {
    return RequestOptions(
      path: spec.pathOrUrl,
      data: _requestBodyTransformer.transform(spec.body),
      method: spec.method.value,
      contentType: spec.body?.contentType,
      cancelToken: _cancelTokenBuilder.create(spec, canceller),
      sendTimeout: spec.sendTimeout,
      receiveTimeout: spec.receiveTimeout,
      connectTimeout: spec.connectionTimeout,
      queryParameters: spec.queryParameters,
      baseUrl: spec.baseUrl,
      headers: spec.headers,
      followRedirects: spec.followRedirects,
      maxRedirects: spec.maxRedirects,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      validateStatus: _responseStatusValidator.validateStatus,
    );
  }
}

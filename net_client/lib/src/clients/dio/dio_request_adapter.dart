import 'package:dart_functionals/dart_functionals.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:net_client/net_client.dart';
import 'package:net_client/src/clients/dio/dio_exception_mapper.dart';
import 'package:net_client/src/clients/dio/dio_request_options_builder.dart';
import 'package:net_client/src/services/adapters/network_request_adapter.dart';
import 'package:net_client/src/types/progress_listener.dart';

class DioRequestAdapter implements NetworkRequestAdapter {
  static const _defaultResponseCode = 0;

  final Dio _dio;
  final DioExceptionMapper _dioExceptionMapper;
  final DioRequestOptionsBuilder _dioRequestOptionsBuilder;

  DioRequestAdapter(Dio dio)
      : _dio = dio,
        _dioRequestOptionsBuilder = const DioRequestOptionsBuilder(),
        _dioExceptionMapper = const DioExceptionMapper();

  @visibleForTesting
  DioRequestAdapter.test(
    Dio dio,
    DioExceptionMapper dioExceptionMapper,
    DioRequestOptionsBuilder dioRequestOptionsBuilder,
  ) : this._(dio, dioExceptionMapper, dioRequestOptionsBuilder);

  DioRequestAdapter._(
    this._dio,
    this._dioExceptionMapper,
    this._dioRequestOptionsBuilder,
  );

  @override
  Future<Result<NetClientException, RawResponse>> performRequest({
    required RequestSpec spec,
    RequestCanceller? requestCanceller,
    ProgressListener? onSendProgress,
    ProgressListener? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.fetch<dynamic>(
        _dioRequestOptionsBuilder.build(
          spec: spec,
          canceller: requestCanceller,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
      );

      return Success(
        RawResponse(
          statusCode: response.statusCode ?? _defaultResponseCode,
          responseHeaders: Map.of(response.headers.map),
          rawResponseBody: response.data,
          request: spec,
        ),
      );
    } catch (e, st) {
      return Failure(
        _dioExceptionMapper.mapException(
          request: spec,
          exception: e,
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<void> close() async => _dio.close();
}

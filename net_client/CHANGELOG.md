# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-29

### Added

- Initial release of `net_client`.
- `NetClient` interface and `NetClientImpl` implementation, exposing `execute`, `uploadMultipartData`, `uploadFormData`, `uploadRawData`, and `uploadFile` methods.
- `NetClientFactory` for creating client instances.
- `RequestSpec` model with content-type inference for `JsonBody`, `FormUrlEncodedBody`, `MultipartBody`, and explicit content types for `RawBody`.
- Sealed `NetClientException` hierarchy: `TransportException`, `CancellationException`, and `UnexpectedException`, each carrying the originating `RequestSpec`.
- `RawResponse` and `NetClientResponse` models supporting `Mappable`.
- Interceptor pipeline with `NetClientInterceptor` and `QueuedNetClientInterceptor` abstractions.
- `DioRequestAdapter`, `DioExceptionMapper`, `DioCancellationTokenBuilder`, and related Dio infrastructure.
- Request cancellation support via `RequestCanceller`.
- API result types via `ApiCallResult`.

// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/data/repositories/auth_data_mapper.dart';
import 'package:app_template/features/auth/data/repositories/auth_data_repository_impl.dart';
import 'package:app_template/features/auth/data/repositories/auth_refresh_error_mapper.dart';
import 'package:app_template/features/auth/data/sources/local_auth_data_source.dart';
import 'package:app_template/features/auth/data/sources/remote_auth_data_source.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_models/net_models.dart';
import 'package:shared_models/shared_models.dart';

class _MockAuthDataStreamController extends Mock
    implements StreamController<AuthData?> {}

class _MockAuthDataMapper extends Mock implements AuthDataMapper {}

class _MockAuthDataRefreshErrorMapper extends Mock
    implements AuthRefreshErrorMapper {}

class _MockLocalAuthDataDataSource extends Mock
    implements LocalAuthDataSource {}

class _MockRemoteAuthDataDataSource extends Mock
    implements RemoteAuthDataSource {}

void main() {
  const tokenRefreshRequest = TokenRefreshRequest(refreshToken: 'refreshToken');

  final authDataDTO = AuthDataDTO(
    userId: 'userId',
    accessToken: 'accessToken',
    refreshToken: 'refreshToken',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );
  final refreshedAuthDataDTO = AuthDataDTO(
    userId: 'userId',
    accessToken: 'accessTokenNew',
    refreshToken: 'refreshTokenNew',
    accessTokenExpiry: DateTime.now(),
    refreshTokenExpiry: DateTime.now(),
  );
  final authData = AuthData(
    userId: authDataDTO.userId,
    accessToken: authDataDTO.accessToken,
    refreshToken: authDataDTO.refreshToken,
    accessTokenExpiry: authDataDTO.accessTokenExpiry,
    refreshTokenExpiry: authDataDTO.refreshTokenExpiry,
  );
  final refreshedAuthData = AuthData(
    userId: refreshedAuthDataDTO.userId,
    accessToken: refreshedAuthDataDTO.accessToken,
    refreshToken: refreshedAuthDataDTO.refreshToken,
    accessTokenExpiry: refreshedAuthDataDTO.accessTokenExpiry,
    refreshTokenExpiry: refreshedAuthDataDTO.refreshTokenExpiry,
  );
  const serverMessage = ServerMessage(code: 'refresh_token_expired');
  const authDataStream = Stream<AuthData?>.empty();
  final authRefreshDomainError = InvalidRefreshToken();

  late StreamController<AuthData?> mockAuthDataStreamController;
  late AuthDataMapper mockAuthDataMapper;
  late AuthRefreshErrorMapper mockAuthDataRefreshErrorMapper;
  late LocalAuthDataSource mockLocalAuthDataSource;
  late RemoteAuthDataSource mockRemoteAuthDataSource;

  late AuthDataRepositoryImpl sut;

  setUpAll(() {
    registerFallbackValue(authData);
    registerFallbackValue(authDataDTO);
    registerFallbackValue(tokenRefreshRequest);
    registerFallbackValue(serverMessage);
  });

  setUp(() {
    mockAuthDataStreamController = _MockAuthDataStreamController();
    mockAuthDataMapper = _MockAuthDataMapper();
    mockAuthDataRefreshErrorMapper = _MockAuthDataRefreshErrorMapper();
    mockLocalAuthDataSource = _MockLocalAuthDataDataSource();
    mockRemoteAuthDataSource = _MockRemoteAuthDataDataSource();

    sut = AuthDataRepositoryImpl(
      mockAuthDataStreamController,
      mockAuthDataMapper,
      mockAuthDataRefreshErrorMapper,
      mockLocalAuthDataSource,
      mockRemoteAuthDataSource,
    );

    when(
      () => mockAuthDataMapper.convertDataToDomain(authDataDTO),
    ).thenAnswer((_) => authData);
    when(
      () => mockAuthDataMapper.convertDomainToData(authData),
    ).thenAnswer((_) => authDataDTO);
    when(
      () => mockAuthDataMapper.convertDataToDomain(refreshedAuthDataDTO),
    ).thenAnswer((_) => refreshedAuthData);
    when(
      () => mockAuthDataMapper.convertDomainToData(refreshedAuthData),
    ).thenAnswer((_) => refreshedAuthDataDTO);
    when(
      () => mockAuthDataRefreshErrorMapper.convertDataToDomain(serverMessage),
    ).thenAnswer((_) => authRefreshDomainError);
    when(
      () => mockLocalAuthDataSource.getCurrentAuthData(),
    ).thenAnswer((_) async => authDataDTO);
    when(
      () => mockLocalAuthDataSource.setCurrentAuthData(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockAuthDataStreamController.stream,
    ).thenAnswer((_) => authDataStream);
    when(() => mockAuthDataStreamController.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    sut.dispose();
  });

  test(
    'getCurrentAuthData should return null if data-source returns null',
    () async {
      when(
        () => mockLocalAuthDataSource.getCurrentAuthData(),
      ).thenAnswer((_) async => null);

      final result = await sut.getCurrentAuthData();

      expect(result, null);
      verify(() => mockLocalAuthDataSource.getCurrentAuthData()).called(1);
      verifyNever(() => mockAuthDataMapper.convertDataToDomain(any()));
    },
  );

  test(
    'getCurrentAuthData should returns non-null AuthData if data-source returns valid non-null DTO',
    () async {
      when(
        () => mockLocalAuthDataSource.getCurrentAuthData(),
      ).thenAnswer((_) async => authDataDTO);

      final result = await sut.getCurrentAuthData();

      expect(result, authData);
      verify(() => mockLocalAuthDataSource.getCurrentAuthData()).called(1);
      verify(
        () => mockAuthDataMapper.convertDataToDomain(authDataDTO),
      ).called(1);
    },
  );

  test(
    'setCurrentAuthData(null) should add to the auth data stream and call AuthDataSource.setCurrentAuthData with null',
    () async {
      await sut.setCurrentAuthData(null);

      verify(() => mockLocalAuthDataSource.setCurrentAuthData(null)).called(1);
      verifyNever(() => mockAuthDataMapper.convertDomainToData(authData));
    },
  );

  test(
    'setCurrentAuthData(authData) should add to the auth data stream and call AuthDataSource.setCurrentAuthData with proper data',
    () async {
      await sut.setCurrentAuthData(authData);

      verify(() => mockAuthDataMapper.convertDomainToData(authData)).called(1);
      verify(
        () => mockLocalAuthDataSource.setCurrentAuthData(authDataDTO),
      ).called(1);
    },
  );

  test(
    'refreshCurrentAuthData success, persists and returns refreshed domain auth data',
    () async {
      when(
        () => mockRemoteAuthDataSource.getRefreshedAuthData(any()),
      ).thenAnswer((_) async => Right(Right(refreshedAuthDataDTO)));

      final result = await sut.refreshCurrentAuthData(authData);

      // Correct request
      verify(
        () => mockRemoteAuthDataSource.getRefreshedAuthData(
          TokenRefreshRequest(refreshToken: authData.refreshToken),
        ),
      ).called(1);

      // Mapping
      verify(
        () => mockAuthDataMapper.convertDataToDomain(refreshedAuthDataDTO),
      ).called(1);

      // Persistence side effects
      verify(
        () => mockAuthDataMapper.convertDomainToData(refreshedAuthData),
      ).called(1);
      verify(
        () => mockLocalAuthDataSource.setCurrentAuthData(refreshedAuthDataDTO),
      ).called(1);

      // Return
      result.fold(
        onLeft: (_) => fail('Expected success'),
        onRight: (inner) => inner.fold(
          onLeft: (_) => fail('Expected success'),
          onRight: (data) => expect(data, refreshedAuthData),
        ),
      );
    },
  );

  test(
    'On failure, refreshCurrentAuthData should return failure result',
    () async {
      when(
        () => mockRemoteAuthDataSource.getRefreshedAuthData(any()),
      ).thenAnswer(
        (_) async => Left(
          const UnexpectedError(cause: 'error', stackTrace: StackTrace.empty),
        ),
      );

      final result = await sut.refreshCurrentAuthData(authData);

      // Correct request
      verify(
        () => mockRemoteAuthDataSource.getRefreshedAuthData(
          TokenRefreshRequest(refreshToken: authData.refreshToken),
        ),
      ).called(1);

      // No side effects on transport error
      verifyNever(
        () => mockAuthDataRefreshErrorMapper.convertDataToDomain(any()),
      );

      // Return
      result.fold(
        onLeft: (error) => expect(error, isA<UnexpectedError>()),
        onRight: (_) => fail('Expected failure'),
      );
    },
  );

  test(
    'On server error, refreshCurrentAuthData should map to domain error',
    () async {
      when(
        () => mockRemoteAuthDataSource.getRefreshedAuthData(any()),
      ).thenAnswer((_) async => Right(Left(serverMessage)));

      final result = await sut.refreshCurrentAuthData(authData);

      // Error mapping
      verify(
        () => mockAuthDataRefreshErrorMapper.convertDataToDomain(serverMessage),
      ).called(1);

      // No success side effects
      verifyNever(() => mockAuthDataMapper.convertDataToDomain(any()));

      // Return
      result.fold(
        onLeft: (_) => fail('Expected a server error result'),
        onRight: (inner) => inner.fold(
          onLeft: (error) => expect(error, isA<InvalidRefreshToken>()),
          onRight: (_) => fail('Expected server error'),
        ),
      );
    },
  );

  test(
    '`getAuthDataStream` should return the stream from the auth data stream',
    () async {
      final result = sut.getAuthDataStream();

      expect(result, authDataStream);
    },
  );

  test('`dispose` should close the auth data stream', () async {
    sut.dispose();

    verify(() => mockAuthDataStreamController.close()).called(1);
  });
}

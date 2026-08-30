// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/app/application/use_cases/get_auth_info_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_refreshed_auth_info_use_case.dart';
import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/collaborators/app_auth_data_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetAuthInfoUseCase extends Mock implements GetAuthInfoUseCase {}

class _MockGetRefreshedAuthInfoUseCase extends Mock
    implements GetRefreshedAuthInfoUseCase {}

void main() {
  final authInfo = AuthInfo(
    accessToken: 'access',
    refreshToken: 'refresh',
    accessTokenExpiry: DateTime.now().add(const Duration(days: 1)),
    refreshTokenExpiry: DateTime.now().add(const Duration(days: 2)),
  );

  late _MockGetAuthInfoUseCase mockGetAuthInfo;
  late _MockGetRefreshedAuthInfoUseCase mockGetRefreshedAuthInfo;
  late AppAuthDataProvider sut;

  setUp(() {
    mockGetAuthInfo = _MockGetAuthInfoUseCase();
    mockGetRefreshedAuthInfo = _MockGetRefreshedAuthInfoUseCase();
    sut = AppAuthDataProvider(mockGetAuthInfo, mockGetRefreshedAuthInfo);
  });

  test('getAuthData delegates to GetAuthInfoUseCase', () async {
    when(() => mockGetAuthInfo()).thenAnswer((_) async => authInfo);

    final result = await sut.getAuthData();

    expect(result, authInfo);
    verify(() => mockGetAuthInfo()).called(1);
    verifyNever(() => mockGetRefreshedAuthInfo());
  });

  test('getAuthData returns null when use case returns null', () async {
    when(() => mockGetAuthInfo()).thenAnswer((_) async => null);

    final result = await sut.getAuthData();

    expect(result, isNull);
  });

  test(
    'requestAuthDataRefresh delegates to GetRefreshedAuthInfoUseCase',
    () async {
      when(() => mockGetRefreshedAuthInfo()).thenAnswer((_) async => authInfo);

      final result = await sut.requestAuthDataRefresh(authInfo);

      expect(result, authInfo);
      verify(() => mockGetRefreshedAuthInfo()).called(1);
      verifyNever(() => mockGetAuthInfo());
    },
  );

  test(
    'requestAuthDataRefresh returns null when use case returns null',
    () async {
      when(() => mockGetRefreshedAuthInfo()).thenAnswer((_) async => null);

      final result = await sut.requestAuthDataRefresh(authInfo);

      expect(result, isNull);
    },
  );
}

import 'package:app_template/features/app/application/use_cases/is_authed_use_case.dart';
import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:app_template/features/app/infrastructure/router/guards/root_redirection_route_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rover/rover.dart';

class _MockIsAuthedUseCase extends Mock implements IsAuthedUseCase {}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late _MockIsAuthedUseCase mockIsAuthed;

  late RootRedirectRouteGuard sut;

  setUp(() {
    mockIsAuthed = _MockIsAuthedUseCase();
    sut = RootRedirectRouteGuard(mockIsAuthed);
  });

  test('If not authenticated should redirect to login', () async {
    when(() => mockIsAuthed()).thenAnswer((_) async => true);

    final result = await sut.onNavigationRequest(
      _FakeBuildContext(),
      RouteContext(info: AppRoute.HOME.routeInfo),
      RouteContext(info: AppRoute.LOGIN.routeInfo),
    );

    expect(result, isA<RedirectNavigation>());
    expect(
      (result as RedirectNavigation).redirectRoute.info.name,
      AppRoute.LOGIN.routeInfo.name,
    );
  });

  test('If authenticated should redirect to home', () async {
    when(() => mockIsAuthed()).thenAnswer((_) async => false);

    final result = await sut.onNavigationRequest(
      _FakeBuildContext(),
      RouteContext(info: AppRoute.LOGIN.routeInfo),
      RouteContext(info: AppRoute.HOME.routeInfo),
    );

    expect(result, isA<RedirectNavigation>());
    expect(
      (result as RedirectNavigation).redirectRoute.info.name,
      AppRoute.HOME.routeInfo.name,
    );
  });
}

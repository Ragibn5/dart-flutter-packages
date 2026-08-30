import 'package:app_template/di/di.dart';
import 'package:app_template/features/app/application/use_cases/is_authed_use_case.dart';
import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:app_template/features/app/infrastructure/router/guards/root_redirection_route_guard.dart';
import 'package:app_template/features/app/presentation/widgets/root_redirection/root_redirection_page.dart';
import 'package:app_template/features/auth/presentation/bloc/login_bloc.dart';
import 'package:app_template/features/auth/presentation/widgets/login/login_page.dart';
import 'package:app_template/features/home/presentation/widgets/home_screen/home_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rover/rover.dart';

List<RouteDef> getAppRouteDefs(IsAuthedUseCase isAuthedUseCase) => [
  RouteDef(
    info: AppRoute.ROOT.routeInfo,
    builder: (_, __, ___) => const RootRedirectionPage(),
    guards: [RootRedirectRouteGuard(isAuthedUseCase)],
  ),
  RouteDef(
    info: AppRoute.LOGIN.routeInfo,
    builder: (_, router, ___) => BlocProvider(
      create: (_) => LoginBloc(di.get()),
      child: LoginPage(
        onLoginComplete: () =>
            router.pushWithName(AppRoute.HOME.routeInfo.name),
      ),
    ),
  ),
  RouteDef(
    info: AppRoute.HOME.routeInfo,
    builder: (_, __, ___) => const HomePage(),
  ),
];

import 'package:app_template/features/app/domain/models/error_report.dart';
import 'package:app_template/features/app/infrastructure/models/app_config.dart';
import 'package:app_template/features/app/presentation/bloc/app_root_bloc.dart';
import 'package:app_template/features/app/presentation/widgets/startup_error/startup_error_page.dart';
import 'package:app_template/features/app/presentation/widgets/startup_loader/startup_loader_page.dart';
import 'package:app_template/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rover/rover.dart';

/// The root widget of the app.
///
/// This widget is omni present, as long as the app is running.
class AppRoot extends StatefulWidget {
  /// The app config used to load the app.
  final AppConfig appConfig;

  /// The router to use.
  final Rover appRouter;

  /// Global scaffold messenger key.
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const AppRoot({
    super.key,
    required this.appConfig,
    required this.appRouter,
    required this.scaffoldMessengerKey,
  });

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppRootBloc, AppRootState>(
      builder: (_, state) => ScreenUtilInit(
        designSize: widget.appConfig.designSize,
        builder: (_, child) => MaterialApp.router(
          restorationScopeId: widget.appConfig.restorationScopeId,
          scaffoldMessengerKey: widget.scaffoldMessengerKey,
          localizationsDelegates: widget.appConfig.localizationDelegates,
          supportedLocales: widget.appConfig.supportedLocales,
          locale: _extractLocale(state, widget.appConfig),
          theme: widget.appConfig.lightThemeData,
          darkTheme: widget.appConfig.darkThemeData,
          themeMode: _extractThemeMode(state, widget.appConfig),
          onGenerateTitle: (context) => S.of(context).appTitle,
          routerConfig: _routerConfig,
          builder: (_, child) => _StateAwareRootPage(
            appConfig: widget.appConfig,
            state: state,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Future<void> didChangePlatformBrightness() async {
    super.didChangePlatformBrightness();
    context.read<AppRootBloc>().add(SystemBrightnessModeChanged());
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    context.read<AppRootBloc>().add(SystemLocaleChanged());
  }

  RouterConfig<Object> get _routerConfig => widget.appRouter.routerConfig;

  Locale _extractLocale(AppRootState state, AppConfig platformConfig) {
    if (state is! AppInitializationSuccess) {
      return platformConfig.defaultLocale;
    }

    return Locale.fromSubtags(
      languageCode: state.locale.languageCode,
      scriptCode: state.locale.scriptCode,
      countryCode: state.locale.countryCode,
    );
  }

  ThemeMode _extractThemeMode(AppRootState state, AppConfig platformConfig) {
    if (state is! AppInitializationSuccess) {
      return platformConfig.defaultThemeMode;
    }

    return switch (state.themeMode) {
      .LIGHT => ThemeMode.light,
      .DARK => ThemeMode.dark,
      .SYSTEM => ThemeMode.system,
    };
  }
}

class _StateAwareRootPage extends StatelessWidget {
  final AppConfig appConfig;
  final AppRootState state;
  final Widget? child;

  const _StateAwareRootPage({
    // ignore: unused_element_parameter
    super.key,
    required this.appConfig,
    required this.state,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scopedState = state;
    switch (scopedState) {
      case AppInitializationInitial() || AppInitializationInProgress():
        return const StartupLoaderPage();
      case AppInitializationError():
        return StartupErrorPage(
          errorReport: scopedState.errorReport,
          onRetry: () =>
              context.read<AppRootBloc>().add(AppInitializationRequested()),
        );
      case AppInitializationSuccess():
        return child ??
            StartupErrorPage(
              errorReport: ErrorReport(
                source: '$_StateAwareRootPage:$build',
                description: 'No initial route or widget was found',
                stackTrace: StackTrace.current,
              ),
              onRetry: () =>
                  context.read<AppRootBloc>().add(AppInitializationRequested()),
            );
    }
  }
}

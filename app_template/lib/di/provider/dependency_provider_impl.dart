import 'dart:async';

import 'package:app_template/di/config/dependencies.dart';
import 'package:app_template/di/provider/dependency_provider.dart';
import 'package:app_template/features/app/infrastructure/enums/app_flavor.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

@visibleForTesting
typedef ConfigureDependencies = Future<GetIt> Function(GetIt, Environment?);

class DependencyProviderImpl implements DependencyProvider {
  static DependencyProvider? _instance;

  static DependencyProvider getInstance() =>
      _instance ??= DependencyProviderImpl._(
        GetIt.asNewInstance(),
        configureDependencies,
        false,
      );

  final GetIt _registrar;
  final ConfigureDependencies _configuratorFunc;

  bool _isInitialized = false;

  @visibleForTesting
  DependencyProviderImpl.test(
    GetIt registrar,
    ConfigureDependencies configuratorFunc, {
    bool isInitialized = false,
  }) : this._(registrar, configuratorFunc, isInitialized);

  DependencyProviderImpl._(
    this._registrar,
    this._configuratorFunc,
    this._isInitialized,
  );

  @override
  T get<T extends Object>({String? name}) =>
      _registrar.get<T>(instanceName: name);

  @override
  T? getOrNull<T extends Object>({String? name}) {
    if (!_registrar.isRegistered<T>(instanceName: name)) {
      return null;
    }

    return get<T>(name: name);
  }

  @override
  FutureOr<void> initialize(AppFlavor? flavor) async {
    if (_isInitialized) {
      return;
    }

    try {
      await _configuratorFunc.call(
        _registrar,
        flavor != null ? Environment(flavor.name) : null,
      );
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  @override
  FutureOr<void> dispose() async {
    await _registrar.reset();

    _isInitialized = false;
  }

  @override
  void registerFactory<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    if (!_isInitialized) {
      throw StateError('$DependencyProvider is not initialized');
    }

    _registrar.registerFactory<T>(factoryFunc, instanceName: instanceName);
  }

  @override
  void registerSingleton<T extends Object>(
    T instance, {
    String? instanceName,
    FutureOr<T> Function(T param)? disposeFunc,
  }) {
    if (!_isInitialized) {
      throw StateError('$DependencyProvider is not initialized');
    }

    _registrar.registerSingleton<T>(
      instance,
      instanceName: instanceName,
      dispose: disposeFunc,
    );
  }

  @override
  void registerLazySingleton<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
    FutureOr<T> Function(T param)? disposeFunc,
  }) {
    if (!_isInitialized) {
      throw StateError('$DependencyProvider is not initialized');
    }

    _registrar.registerLazySingleton<T>(
      factoryFunc,
      instanceName: instanceName,
      dispose: disposeFunc,
    );
  }
}

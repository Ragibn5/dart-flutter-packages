import 'package:net_client/src/clients/net_client.dart';
import 'package:net_client/src/services/interceptors/net_client_interceptor.dart';

/// Manages the ordered list of interceptors for a [NetClient].
///
/// Owns its own list — no external reference is shared.
final class InterceptorPipeline {
  final List<NetClientInterceptor> _interceptors;

  InterceptorPipeline({List<NetClientInterceptor> interceptors = const []})
      : _interceptors = List.of(interceptors);

  /// Appends [interceptor] to the end of the chain.
  void add(NetClientInterceptor interceptor) => _interceptors.add(interceptor);

  /// Appends all [interceptors] to the end of the chain, in given order.
  void addAll(Iterable<NetClientInterceptor> interceptors) =>
      _interceptors.addAll(interceptors);

  /// Removes the first occurrence of [interceptor].
  /// Returns `true` if the interceptor was found and removed.
  bool remove(NetClientInterceptor interceptor) =>
      _interceptors.remove(interceptor);

  /// Removes all interceptors from the chain.
  void clear() => _interceptors.clear();

  /// The number of interceptors in the pipeline.
  int get length => _interceptors.length;

  /// Whether the pipeline is empty.
  bool get isEmpty => _interceptors.isEmpty;

  /// Returns a snapshot copy of the current interceptor list.
  List<NetClientInterceptor> snapshot() => List.of(_interceptors);
}

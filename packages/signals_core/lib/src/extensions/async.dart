import '../async/state.dart';
import '../core/signals.dart';
import '../extensions/signal.dart';

/// Extensions for [Signal<AsyncState<T>>]
extension AsyncSignalState<T, E> on Signal<AsyncState<T, E>> {
  /// Select from data when available, preserving async state
  Computed<AsyncState<R, E>> selectData<R>(R Function(T data) selector) {
    return select(
      (asyncState) {
        final value = asyncState().value;
        return AsyncState(
          value: value == null ? null : selector(value),
          isLoading: asyncState().isLoading,
          isReloading: asyncState().isReloading,
          error: asyncState().error,
          stackTrace: asyncState().stackTrace,
        );
      },
    );
  }
}

/// Error builder for [AsyncState]
///
/// The `Function` below stands for one of two types:
/// - (dynamic) -> FutureOr
/// - (dynamic, StackTrace) -> FutureOr
typedef AsyncErrorBuilder<E> = Function;

/// Value builder for [AsyncState]
typedef AsyncDataBuilder<E, T> = E Function(
  T value,
);

/// Generic builder for [AsyncState]
typedef AsyncStateBuilder<E> = E Function();

/// {@template state}
/// `AsyncState` is class commonly used with Future/Stream signals to represent the states the signal can be in.
///
/// ## AsyncSignal
///
/// `AsyncState` is the default state if you want to create a `AsyncSignal` directly:
///
/// ```dart
/// final s = asyncSignal(AsyncState.data(1));
/// s.value = AsyncState.loading(); // or AsyncLoading();
/// s.value = AsyncState.error('Error', null); // or AsyncError();
/// ```
///
/// ## AsyncState
///
/// `AsyncState` is a sealed union made up of `AsyncLoading`, `AsyncData` and `AsyncError`.
///
/// ### .future
///
/// Sometimes you need to await a signal value in a async function until a value is completed and in this case use the .future getter.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// s.value = AsyncState.data(1);
/// await s.future; // Waits until data or error is set
/// ```
///
/// ### .isCompleted
///
/// Returns true if the future has completed with an error or value:
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// s.value = AsyncState.data(1);
/// print(s.isCompleted); // true
/// ```
///
/// ### .hasValue
///
/// Returns true if the state has a value - `AsyncData`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.hasValue); // false
/// s.value = AsyncState.data(1);
/// print(s.hasValue); // true
/// ```
///
/// ### .hasError
///
/// Returns true if the state has a error - `AsyncError`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.hasError); // false
/// s.value = AsyncState.error('error');
/// print(s.hasError); // true
/// ```
///
/// ### .isRefreshing
///
/// Returns true if the state is refreshing - `AsyncDataRefreshing` or `AsyncErrorRefreshing`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.isRefreshing); // false
/// s.value = AsyncState.errorRefreshing('error');
/// print(s.isRefreshing); // true
/// s.value = AsyncState.dataRefreshing(1);
/// print(s.isRefreshing); // true
/// ```
///
/// ### .isReloading
///
/// Returns true if the state is refreshing - `AsyncDataReloading` or `AsyncErrorReloading`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.loading());
/// print(s.isReloading); // false
/// s.value = AsyncState.dataReloading(1);
/// print(s.isReloading); // true
/// s.value = AsyncState.errorReloading('error');
/// print(s.isReloading); // true
/// ```
///
/// ### .requireValue
///
/// Force unwrap the value of the state
/// and throw an error if it has an error or is null - `AsyncData`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.data(1));
/// print(s.requireValue); // 1
/// ```
///
/// ### .value
///
/// Return the current value if exists - `AsyncData`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.data(1));
/// print(s.value); // 1 or null
/// ```
///
/// ### .error
///
/// Return the current error if exists - `AsyncError`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.error('error'));
/// print(s.error); // 'error' or null
/// ```
///
/// ### .stackTrace
///
/// Return the current stack trace if exists - `AsyncError`.
///
/// ```dart
/// final s = asyncSignal<int>(AsyncState.error('error', StackTrace(...)));
/// print(s.stackTrace); // StackTrace(...) or null
/// ```
///
/// ### .map
///
/// If you want to handle the states of the signal `map` will enforce all branching.
///
/// ```dart
/// final signal = asyncSignal<int>(AsyncState.data(1));
/// signal.value.map(
///  data: (value) => 'Value: $value',
///  error: (error, stackTrace) => 'Error: $error',
///  loading: () => 'Loading...',
/// );
/// ```
///
/// ### .maybeMap
///
/// If you want to handle some of the states of the signal `maybeMap` will provide a default and optional overrides.
///
/// ```dart
/// final signal = asyncSignal<int>(AsyncState.data(1));
/// signal.value.maybeMap(
///  data: (value) => 'Value: $value',
///  orElse: () => 'Loading...',
/// );
/// ```
///
/// ### Pattern Matching
///
/// Instead of `map` and `maybeMap` it is also possible to use [dart switch expressions](https://dart.dev/language/patterns) to handle the branching.
///
/// ```dart
/// final signal = asyncSignal<int>(AsyncState.data(1));
/// final value = switch (signal.value) {
///     AsyncData<int> data => 'value: ${data.value}',
///     AsyncError<int> error => 'error: ${error.error}',
///     AsyncLoading<int>() => 'loading',
/// };
/// ```
/// @link https://dartsignals.dev/async/state
/// {@endtemplate}

class AsyncState<T, E> {
  final E? error;
  final StackTrace? stackTrace;
  final T? value;
  final bool isLoading;
  final bool isReloading;

  const AsyncState({
    this.error,
    this.stackTrace,
    this.value,
    this.isLoading = false,
    this.isReloading = false,
  });

  bool get hasError => error != null;
  bool get hasValue => value != null;
  T get requireValue => value!;

  factory AsyncState.loading() => AsyncState(
        error: null,
        stackTrace: null,
        value: null,
        isLoading: true,
        isReloading: false,
      );

  factory AsyncState.data(T value) => AsyncState(
        error: null,
        stackTrace: null,
        value: value,
        isLoading: false,
        isReloading: false,
      );
  factory AsyncState.error(E error, [StackTrace? stackTrace]) => AsyncState(
        error: error,
        stackTrace: stackTrace,
        value: null,
        isLoading: false,
        isReloading: false,
      );

  AsyncState<T, E> withError(E error, [StackTrace? stackTrace]) {
    return AsyncState(
      error: error,
      stackTrace: stackTrace,
      value: value,
      isLoading: false,
      isReloading: false,
    );
  }

  AsyncState<T, E> withValue(T? value) {
    return AsyncState(
      error: null,
      stackTrace: null,
      value: value,
      isLoading: false,
      isReloading: false,
    );
  }

  AsyncState<T, E> withLoading() {
    return AsyncState(
      error: error,
      stackTrace: stackTrace,
      value: value,
      isLoading: true,
      isReloading: false,
    );
  }

  AsyncState<T, E> withReloading() {
    return AsyncState(
      error: error,
      stackTrace: stackTrace,
      value: value,
      isLoading: false,
      isReloading: true,
    );
  }

  /// Map the state to a value.
  ///
  /// ```dart
  /// final signal = StreamSignal<int>();
  /// signal.value.map(
  ///  data: (value) => 'Value: $value',
  ///  error: (error, stackTrace) => 'Error: $error',
  ///  loading: () => 'Loading...',
  /// );
  /// ```
  ///
  /// The error `Function` below can be one of two types:
  /// - (dynamic) -> FutureOr
  /// - (dynamic, StackTrace) -> FutureOr
  E map<E>({
    required AsyncDataBuilder<E, T> data,
    required AsyncErrorBuilder<E> error,
    required AsyncStateBuilder<E> loading,
    AsyncStateBuilder<E>? reloading,
    AsyncStateBuilder<E>? refreshing,
  }) {
    if (isReloading) if (reloading != null) return reloading();
    if (hasValue) return data(value as T);
    if (hasError) {
      if (error is Function(dynamic, dynamic)) {
        return error(this.error, stackTrace);
      } else if (error is Function(dynamic)) {
        return error(this.error);
      } else {
        return error();
      }
    }
    return loading();
  }

  /// Map the state to a value with optional or else.
  ///
  /// ```dart
  /// final signal = StreamSignal<int>();
  /// signal.value.maybeMap(
  ///  data: (value) => 'Value: $value',
  ///  orElse: () => 'Loading...',
  /// );
  /// ```
  ///
  /// The error `Function` below can be one of two types:
  /// - (dynamic) -> FutureOr
  /// - (dynamic, StackTrace) -> FutureOr
  E maybeMap<E>({
    AsyncDataBuilder<E, T>? data,
    AsyncErrorBuilder<E>? error,
    AsyncStateBuilder<E>? loading,
    AsyncStateBuilder<E>? reloading,
    AsyncStateBuilder<E>? refreshing,
    required AsyncStateBuilder<E> orElse,
  }) {
    if (isReloading) if (reloading != null) return reloading();
    if (hasValue) if (data != null) return data(value as T);
    if (hasError) {
      if (error != null) {
        if (error is Function(Object, StackTrace?)) {
          return error(this.error as Object, stackTrace);
        } else if (error is Function(Object)) {
          return error(this.error as Object);
        } else {
          return error();
        }
      }
    }
    if (isLoading) if (loading != null) return loading();
    return orElse();
  }

  @override
  bool operator ==(covariant AsyncState<T, E> other);

  @override
  int get hashCode;
}

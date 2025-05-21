import 'dart:async';

import '../async/state.dart';
import '../core/signals.dart';

/// [EventSink] implementation for [AsyncState]
mixin EventSinkSignalMixin<T, E> on Signal<AsyncState<T, E>>
    implements EventSink<T> {
  @override
  void add(T event) {
    set(AsyncState(value: event));
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    set(AsyncState(error: error as E, stackTrace: stackTrace));
  }

  @override
  void close() {
    dispose();
  }
}

import 'package:signals_core/signals_core.dart';
import 'package:test/test.dart';

void main() {
  SignalsObserver.instance = null;
  group('AsyncSignal', () {
    test('data', () async {
      final s = asyncSignal(AsyncState(value: 0));
      expect(s.peek().isLoading, false);
      expect(s.peek().hasError, false);
      expect(s.peek().hasValue, true);
      expect(s.peek().requireValue, 0);
      expect(s.requireValue, 0);
    });

    test('isCompleted', () async {
      final s = asyncSignal(AsyncState(value: 0));
      expect(s.isCompleted, false);
      s.setValue(1);
      expect(s.isCompleted, true);
    });

    test('error', () async {
      final s = asyncSignal(AsyncState(error: 'error'));
      expect(s.peek().isLoading, false);
      expect(s.peek().hasError, true);
      expect(s.peek().hasValue, false);
      expect(s.peek().error, 'error');
    });

    test('loading', () async {
      final s = asyncSignal(AsyncState(isLoading: true));
      expect(s.peek().isLoading, true);
      expect(s.peek().hasError, false);
      expect(s.peek().hasValue, false);
    });

    test('state', () async {
      final s = asyncSignal(AsyncState(isLoading: true));
      expect(s().isLoading, true);
      s.setValue(0);
      expect(s().isLoading, false);
      expect(s().hasError, false);
      expect(s().hasValue, true);
      expect(s().requireValue, 0);
      expect(s.requireValue, 0);
      s.setError('error');
      expect(s().isLoading, false);
      expect(s().hasError, true);
      expect(s().hasValue, true);
      expect(s().error, 'error');
      s.setLoading();
      expect(s().isLoading, true);
      expect(s().hasError, true);
      expect(s().hasValue, true);
    });

    group('reload', () {
      test('data', () async {
        final s = asyncSignal(AsyncState(value: 0));
        s.reload();
        expect(s.value.isLoading, true);
        expect(s.value.hasValue, true);
        expect(s.value.isReloading, true);
        expect(s.value.isLoading, true);
        expect(s.value.isReloading, true);
      });

      test('error', () async {
        final s = asyncSignal(AsyncState(error: 'error'));
        s.reload();
        expect(s.value.isLoading, true);
        expect(s.value.hasError, true);
        expect(s.value.isReloading, true);
      });

      test('loading', () async {
        final s = asyncSignal(AsyncState(isLoading: true));
        s.reload();
        expect(s.value.isLoading, true);
        expect(s.value.isReloading, true);
      });

      test('await reload() waits for setValue', () async {
        final s = asyncSignal(AsyncState(value: 0));

        var reloadCompleted = false;
        final reloadFuture = s.reload().then((_) {
          reloadCompleted = true;
        });

        // Reload should not complete immediately
        await Future.delayed(Duration(milliseconds: 10));
        expect(reloadCompleted, false);

        // Set new value
        s.setValue(1);

        // Now reload should complete
        await reloadFuture;
        expect(reloadCompleted, true);
        expect(s.value.value, 1);
      });

      test('await reload() waits for setError', () async {
        final s = asyncSignal(AsyncState(value: 0));

        var reloadCompleted = false;
        final reloadFuture = s.reload().then((_) {
          reloadCompleted = true;
        });

        // Reload should not complete immediately
        await Future.delayed(Duration(milliseconds: 10));
        expect(reloadCompleted, false);

        // Set error
        s.setError('new error');

        // Now reload should complete
        await reloadFuture;
        expect(reloadCompleted, true);
        expect(s.value.error, 'new error');
      });

      test('multiple sequential await reload() calls', () async {
        final s = asyncSignal(AsyncState(value: 0));

        // First reload
        final reload1Future = s.reload();
        s.setValue(1);
        await reload1Future;
        expect(s.value.value, 1);

        // Second reload
        final reload2Future = s.reload();
        s.setValue(2);
        await reload2Future;
        expect(s.value.value, 2);
      });

      test('await reload() with clearError', () async {
        final s = asyncSignal(AsyncState(error: 'error'));

        var reloadCompleted = false;
        final reloadFuture = s.reload().then((_) {
          reloadCompleted = true;
        });

        // Reload should not complete immediately
        await Future.delayed(Duration(milliseconds: 10));
        expect(reloadCompleted, false);

        // Clear error
        s.clearError();

        // Now reload should complete
        await reloadFuture;
        expect(reloadCompleted, true);
        expect(s.value.hasError, false);
      });
    });
  });
}

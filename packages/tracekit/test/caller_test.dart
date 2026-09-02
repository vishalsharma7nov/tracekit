import 'package:test/test.dart';
import 'package:tracekit/tracekit.dart';

void main() {
  group('CallerInfo', () {
    test('manual factory sets fields', () {
      final info = CallerInfo.manual(
        'lib/auth.dart',
        10,
        column: 4,
        member: 'signIn',
        package: 'my_app',
      );
      expect(info.locationLabel, 'auth.dart:10');
      expect(info.column, 4);
      expect(info.package, 'my_app');
      expect(info.toString(), contains('signIn'));
    });

    test('toJson serializes fields', () {
      final json = CallerInfo.manual('a.dart', 1).toJson();
      expect(json['file'], 'a.dart');
      expect(json['line'], 1);
    });
  });

  group('CallerInfoConfig', () {
    test('off never captures', () {
      const config = CallerInfoConfig(mode: CallerInfoMode.off);
      expect(
        config.shouldCaptureForLevel(TraceLevel.error, isReleaseMode: false),
        isFalse,
      );
    });

    test('debugOnly skips in release', () {
      const config = CallerInfoConfig(mode: CallerInfoMode.debugOnly);
      expect(
        config.shouldCaptureForLevel(TraceLevel.info, isReleaseMode: true),
        isFalse,
      );
      expect(
        config.shouldCaptureForLevel(TraceLevel.info, isReleaseMode: false),
        isTrue,
      );
    });

    test('errorsOnly captures warn and above', () {
      const config = CallerInfoConfig(mode: CallerInfoMode.errorsOnly);
      expect(
        config.shouldCaptureForLevel(TraceLevel.debug, isReleaseMode: false),
        isFalse,
      );
      expect(
        config.shouldCaptureForLevel(TraceLevel.warn, isReleaseMode: true),
        isTrue,
      );
    });

    test('always captures regardless of release mode', () {
      const config = CallerInfoConfig(mode: CallerInfoMode.always);
      expect(
        config.shouldCaptureForLevel(TraceLevel.trace, isReleaseMode: true),
        isTrue,
      );
    });
  });

  group('CallerResolver', () {
    test('skips tracekit internal frames', () {
      const resolver = CallerResolver();
      final info = resolver.resolve(StackTrace.current);
      // Stack from test file should resolve to a non-tracekit frame.
      expect(info, isNotNull);
      expect(info!.file, isNot(contains('tracekit')));
    });

    test('returns null for empty stack', () {
      const resolver = CallerResolver();
      expect(resolver.resolve(StackTrace.empty), isNull);
    });
  });
}

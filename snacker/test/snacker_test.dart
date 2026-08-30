// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snacker/snacker.dart';

/// A concrete [Snacker] that delegates context resolution to a settable
/// field so test code can inject any [BuildContext].
class _TestSnacker extends Snacker {
  BuildContext? _context;

  _TestSnacker([SnackBarBuilder? snackBarBuilder])
    : super(snackBarBuilder: snackBarBuilder ?? const DefaultSnackBarBuilder());

  // ignore: use_setters_to_change_properties
  void provideContext(BuildContext context) => _context = context;

  @override
  BuildContext getCurrentContext() {
    final ctx = _context;
    if (ctx == null) throw StateError('No context set');
    return ctx;
  }
}

class _CustomContentBuilder extends SnackBarBuilder {
  const _CustomContentBuilder();

  @override
  Text buildSnackContent(SnackData data) {
    return Text(
      'CUSTOM: ${data.message}',
      textAlign: data.textAlignment,
      style: const TextStyle(color: Colors.white),
    );
  }
}

class _CustomColorBuilder extends SnackBarBuilder {
  const _CustomColorBuilder();

  @override
  Color getSnackBarBackgroundColor(SnackType type) => Colors.purple;
}

extension on WidgetTester {
  Future<void> pumpSnacker({
    required _TestSnacker snacker,
    required Widget child,
  }) async {
    await pumpWidget(
      MaterialApp(
        home: ScaffoldMessenger(
          key: GlobalKey<ScaffoldMessengerState>(),
          child: Scaffold(
            body: Builder(
              builder: (context) {
                snacker.provideContext(context);
                return child;
              },
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('showTextSnack', () {
    testWidgets('Throws StateError when no context is available', (
      tester,
    ) async {
      final snacker = _TestSnacker();

      expect(
        () => snacker.showTextSnack(SnackData.info(message: 'test')),
        throwsA(isA<StateError>()),
      );
    });

    testWidgets('Displays the snack message', (tester) async {
      final snacker = _TestSnacker();

      await tester.pumpSnacker(
        snacker: snacker,
        child: ElevatedButton(
          onPressed: () =>
              snacker.showTextSnack(SnackData.info(message: 'Hello')),
          child: const Text('Show'),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('Clears previous snack before showing new one', (tester) async {
      final snacker = _TestSnacker();

      await tester.pumpSnacker(
        snacker: snacker,
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              snacker
                ..showTextSnack(SnackData.info(message: 'First'))
                ..showTextSnack(SnackData.info(message: 'Second'));
            },
            child: const Text('Show'),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets(
      'Renders message, duration, and text alignment from SnackData',
      (tester) async {
        final snacker = _TestSnacker();

        await tester.pumpSnacker(
          snacker: snacker,
          child: ElevatedButton(
            onPressed: () => snacker.showTextSnack(
              SnackData.error(
                message: 'Something went wrong',
                duration: const Duration(seconds: 5),
                textAlignment: TextAlign.start,
              ),
            ),
            child: const Text('Show'),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pump();

        final text = tester.widget<Text>(find.text('Something went wrong'));
        expect(text.textAlign, TextAlign.start);

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.duration, const Duration(seconds: 5));
      },
    );
  });

  group('SnackData', () {
    test('Each factory sets the correct SnackType', () {
      expect(SnackData.info(message: '').snackType, SnackType.INFO);
      expect(SnackData.success(message: '').snackType, SnackType.SUCCESS);
      expect(SnackData.warning(message: '').snackType, SnackType.WARNING);
      expect(SnackData.error(message: '').snackType, SnackType.ERROR);
    });

    test('Defaults to 2s duration and center alignment', () {
      final data = SnackData.info(message: 'test');
      expect(data.duration, const Duration(seconds: 2));
      expect(data.textAlignment, TextAlign.center);
    });
  });

  group('Component overrides', () {
    testWidgets('buildSnackContent override changes the displayed text', (
      tester,
    ) async {
      final snacker = _TestSnacker(const _CustomContentBuilder());

      await tester.pumpSnacker(
        snacker: snacker,
        child: ElevatedButton(
          onPressed: () =>
              snacker.showTextSnack(SnackData.info(message: 'Original')),
          child: const Text('Show'),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      expect(find.text('CUSTOM: Original'), findsOneWidget);
      expect(find.text('Original'), findsNothing);
    });

    testWidgets('getSnackBarBackgroundColor override changes bar color', (
      tester,
    ) async {
      final snacker = _TestSnacker(const _CustomColorBuilder());

      await tester.pumpSnacker(
        snacker: snacker,
        child: ElevatedButton(
          onPressed: () =>
              snacker.showTextSnack(SnackData.info(message: 'test')),
          child: const Text('Show'),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.purple);
    });
  });
}

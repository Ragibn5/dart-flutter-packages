import 'package:common_widgets/src/centered_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('CenteredLoader', () {
    testWidgets('Renders a centered CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(wrap(const CenteredLoader()));

      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

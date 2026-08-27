import 'package:common_widgets/src/titled_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('TitledWidget', () {
    testWidgets('Renders title above child', (tester) async {
      await tester.pumpWidget(wrap(
        const TitledWidget(
          title: Text('Title'),
          child: Text('Child'),
        ),
      ));

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Child'), findsOneWidget);
    });

    testWidgets('Uses default spacing', (tester) async {
      await tester.pumpWidget(wrap(
        const TitledWidget(
          title: Text('Title'),
          child: Text('Child'),
        ),
      ));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.spacing, 8);
    });

    testWidgets('noSpacing constructor sets spacing to 0', (tester) async {
      await tester.pumpWidget(wrap(
        const TitledWidget.noSpacing(
          title: Text('Title'),
          child: Text('Child'),
        ),
      ));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.spacing, 0);
    });

    testWidgets('Applies titlePadding and childPadding', (tester) async {
      await tester.pumpWidget(wrap(
        const TitledWidget(
          title: Text('Title'),
          child: Text('Child'),
          titlePadding: EdgeInsets.all(16),
          childPadding: EdgeInsets.all(8),
        ),
      ));

      final paddings = tester
          .widgetList<Padding>(find.byType(Padding))
          .toList();
      expect(paddings, hasLength(2));

      expect(paddings[0].padding, const EdgeInsets.all(8));
      expect(paddings[1].padding, const EdgeInsets.all(16));
    });
  });
}

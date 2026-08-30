// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snacker/snacker.dart';

void main() {
  const builder = DefaultSnackBarBuilder();
  final data = SnackData.error(
    message: 'Something went wrong',
    duration: const Duration(seconds: 5),
    textAlignment: TextAlign.start,
  );

  group('buildSnackBar', () {
    test('creates a SnackBar using the data and background color', () {
      final snackBar = builder.buildSnackBar(data);

      expect(snackBar.duration, const Duration(seconds: 5));
      expect(snackBar.backgroundColor, const Color(0xFFF44336));

      final content = snackBar.content as Text;
      expect(content.data, 'Something went wrong');
      expect(content.textAlign, TextAlign.start);
      expect(content.style?.color, Colors.white);
    });
  });

  group('buildSnackContent', () {
    test('renders message, alignment, and white text style', () {
      final text = builder.buildSnackContent(data);

      expect(text.data, 'Something went wrong');
      expect(text.textAlign, TextAlign.start);
      expect(text.style?.color, Colors.white);
    });
  });

  group('getSnackBarBackgroundColor', () {
    test('returns the expected color for each SnackType', () {
      expect(
        builder.getSnackBarBackgroundColor(SnackType.INFO),
        const Color(0xFF2196F3),
      );
      expect(
        builder.getSnackBarBackgroundColor(SnackType.SUCCESS),
        const Color(0xFF4CAF50),
      );
      expect(
        builder.getSnackBarBackgroundColor(SnackType.WARNING),
        const Color(0xFFFF9800),
      );
      expect(
        builder.getSnackBarBackgroundColor(SnackType.ERROR),
        const Color(0xFFF44336),
      );
    });
  });
}

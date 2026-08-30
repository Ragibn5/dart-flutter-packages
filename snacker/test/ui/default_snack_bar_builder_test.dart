// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snacker/snacker.dart';

void main() {
  const builder = DefaultSnackBarBuilder();
  final data = SnackData.info(message: 'Hello');

  test('is a SnackBarBuilder', () {
    expect(builder, isA<SnackBarBuilder>());
  });

  test('builds a SnackBar with the default background color and duration', () {
    final snackBar = builder.buildSnackBar(data);

    expect(snackBar.duration, const Duration(seconds: 2));
    expect(snackBar.backgroundColor, const Color(0xFF2196F3));

    final content = snackBar.content as Text;
    expect(content.data, 'Hello');
    expect(content.textAlign, TextAlign.center);
    expect(content.style?.color, Colors.white);
  });
}

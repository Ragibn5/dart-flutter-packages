import 'package:flutter/material.dart';
import 'package:snacker/src/models/snack_data.dart';
import 'package:snacker/src/snack_bar_builder.dart';

/// Presents snacks on top of the app's [ScaffoldMessenger].
abstract class Snacker {
  /// Builds the snack UI.
  final SnackBarBuilder snackBarBuilder;

  const Snacker({this.snackBarBuilder = const DefaultSnackBarBuilder()});

  /// Provides the current context.
  ///
  /// This is used as the context on top of which our snack is shown.
  BuildContext getCurrentContext();

  /// Shows a text snack.
  void showTextSnack(SnackData data, {AnimationStyle? snackBarAnimationStyle}) {
    final currentState = ScaffoldMessenger.maybeOf(getCurrentContext());
    if (currentState == null) {
      throw StateError(
        'No `$ScaffoldMessengerState` is available at this context',
      );
    }

    currentState
      ..clearSnackBars()
      ..showSnackBar(
        snackBarBuilder.buildSnackBar(data),
        snackBarAnimationStyle: snackBarAnimationStyle,
      );
  }
}

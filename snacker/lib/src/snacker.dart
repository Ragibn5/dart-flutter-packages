import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:snacker/src/enums/snack_type.dart';
import 'package:snacker/src/models/snack_data.dart';

abstract class Snacker {
  const Snacker();

  /// Shows a text snack.
  ///
  /// Customize the appearance by overriding any of the hook methods
  /// (e.g., [buildSnackContent], [getSnackBarBackgroundColor] etc.).
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
        buildSnackBar(data),
        snackBarAnimationStyle: snackBarAnimationStyle,
      );
  }

  /// Provides the current context.
  ///
  /// This is used as the context on top of which our snack is shown.
  @visibleForOverriding
  BuildContext getCurrentContext();

  /// Build the root [SnackBar] instance.
  ///
  /// Override this method if you want to customize the entire snack UI.
  /// But in case you want to customize only the components, you can do so
  /// by overriding any of the hook methods (e.g., [buildSnackContent],
  /// [getSnackBarBackgroundColor] etc.).
  @visibleForOverriding
  SnackBar buildSnackBar(SnackData data) {
    return SnackBar(
      content: buildSnackContent(data),
      duration: data.duration,
      backgroundColor: getSnackBarBackgroundColor(data.snackType),
    );
  }

  /// Build the snack content (body) widget.
  @visibleForOverriding
  Text buildSnackContent(SnackData data) {
    return Text(
      data.message,
      textAlign: data.textAlignment,
      style: const TextStyle(color: Colors.white),
    );
  }

  /// Get the background color of the snack.
  @visibleForOverriding
  Color getSnackBarBackgroundColor(SnackType type) {
    switch (type) {
      case .INFO:
        return const Color(0xFF2196F3);
      case .SUCCESS:
        return const Color(0xFF4CAF50);
      case .WARNING:
        return const Color(0xFFFF9800);
      case .ERROR:
        return const Color(0xFFF44336);
    }
  }
}

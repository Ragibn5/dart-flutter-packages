import 'package:flutter/material.dart';
import 'package:snacker/src/enums/snack_type.dart';
import 'package:snacker/src/models/snack_data.dart';

/// Builds the [SnackBar] UI for a given [SnackData].
///
/// This separates the *appearance* of a snack from the *presentation* logic
/// (handled by a presenter such as `ScaffoldMessengerSnacker`). Subclass and
/// override any of the hook methods to customize the look.
abstract class SnackBarBuilder {
  const SnackBarBuilder();

  /// Build the root [SnackBar] instance.
  ///
  /// Override this method if you want to customize the entire snack UI.
  /// But in case you want to customize only the components, you can do so
  /// by overriding any of the hook methods (e.g., [buildSnackContent],
  /// [getSnackBarBackgroundColor] etc.).
  SnackBar buildSnackBar(SnackData data) {
    return SnackBar(
      content: buildSnackContent(data),
      duration: data.duration,
      backgroundColor: getSnackBarBackgroundColor(data.snackType),
    );
  }

  /// Build the snack content (body) widget.
  Text buildSnackContent(SnackData data) {
    return Text(
      data.message,
      textAlign: data.textAlignment,
      style: const TextStyle(color: Colors.white),
    );
  }

  /// Get the background color of the snack.
  Color getSnackBarBackgroundColor(SnackType type) {
    switch (type) {
      case SnackType.INFO:
        return const Color(0xFF2196F3);
      case SnackType.SUCCESS:
        return const Color(0xFF4CAF50);
      case SnackType.WARNING:
        return const Color(0xFFFF9800);
      case SnackType.ERROR:
        return const Color(0xFFF44336);
    }
  }
}

/// The default [SnackBarBuilder] with standard styling.
class DefaultSnackBarBuilder extends SnackBarBuilder {
  const DefaultSnackBarBuilder();
}

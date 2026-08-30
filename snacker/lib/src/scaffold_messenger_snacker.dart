import 'package:flutter/material.dart';
import 'package:snacker/src/snacker.dart';
import 'package:snacker/src/ui/default_snack_bar_builder.dart';

/// A [Snacker] that shows snacks via a [ScaffoldMessenger] referenced by a
/// [GlobalKey].
///
/// Pass [snackBarBuilder] to customize the snack appearance.
class ScaffoldMessengerSnacker extends Snacker {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  const ScaffoldMessengerSnacker(
    this._scaffoldMessengerKey, {
    super.snackBarBuilder = const DefaultSnackBarBuilder(),
  });

  @override
  BuildContext getCurrentContext() {
    final context = _scaffoldMessengerKey.currentContext;
    if (context == null) {
      throw StateError(
        'Invalid scaffold messenger state, '
        'make sure you are using the same scaffold messenger key in your app.',
      );
    }

    return context;
  }
}

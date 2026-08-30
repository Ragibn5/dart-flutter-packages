import 'package:flutter/material.dart';

class TitledWidget extends StatelessWidget {
  final Widget title;
  final Widget child;

  final double spacing;
  final EdgeInsets titlePadding;
  final EdgeInsets childPadding;

  const TitledWidget({
    super.key,
    required this.title,
    required this.child,
    this.spacing = 8,
    this.titlePadding = EdgeInsets.zero,
    this.childPadding = EdgeInsets.zero,
  });

  const TitledWidget.noSpacing({
    super.key,
    required this.title,
    required this.child,
    this.titlePadding = EdgeInsets.zero,
    this.childPadding = EdgeInsets.zero,
  }) : spacing = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: spacing,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(padding: childPadding, child: child),
        Padding(padding: titlePadding, child: title),
      ],
    );
  }
}

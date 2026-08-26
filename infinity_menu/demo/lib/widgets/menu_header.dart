import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

class MenuHeader extends StatelessWidget {
  const MenuHeader({super.key, required this.parentItemData, this.rootTitle});

  final MenuItemData<String>? parentItemData;
  final String? rootTitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final title = parentItemData?.itemTitle ?? rootTitle ?? 'Menu';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: cs.primary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

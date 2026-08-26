import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

const List<Color> _itemColors = [
  Color(0xFF4F46E5),
  Color(0xFF0EA5E9),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFF8B5CF6),
  Color(0xFFF43F5E),
];

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({super.key, required this.item, required this.index});

  final MenuItemData<String> item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasSubmenu = item.subMenuData != null;
    final color = _itemColors[index % _itemColors.length];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            switch (item.itemIcon) {
              final IconFromPath path => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Image.asset(path.iconPath, width: 20, height: 20),
                ),
              final IconFromIconData iconData => Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(iconData.iconData, size: 16, color: color),
                ),
              null => const SizedBox.shrink(),
            },
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.itemTitle,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (hasSubmenu)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

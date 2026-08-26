import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

import 'package:example/menu_data/deep_nesting_menu.dart';
import 'package:example/menu_data/overlay_feedback_menu.dart';
import 'package:example/menu_data/settings_menu.dart';
import 'package:example/menu_data/simple_menu.dart';

class MenuDemoOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final MenuData<String> Function(void Function(String?)) buildMenu;

  const MenuDemoOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.buildMenu,
  });
}

const List<MenuDemoOption> menuDemoOptions = [
  MenuDemoOption(
    icon: Icons.account_tree_rounded,
    title: 'Deep Nesting',
    subtitle: '5 items, 4 levels deep',
    color: Color(0xFF0EA5E9),
    buildMenu: buildDeepNestingMenu,
  ),
  MenuDemoOption(
    icon: Icons.color_lens_rounded,
    title: 'Overlay Feedback',
    subtitle: 'Colored overlay on tap',
    color: Color(0xFF8B5CF6),
    buildMenu: buildOverlayFeedbackMenu,
  ),
  MenuDemoOption(
    icon: Icons.devices_rounded,
    title: 'Multi-Level Settings',
    subtitle: 'Real-world settings hierarchy',
    color: Color(0xFF10B981),
    buildMenu: buildSettingsMenu,
  ),
  MenuDemoOption(
    icon: Icons.help_outline_rounded,
    title: 'Simple Menu',
    subtitle: 'Flat list, no nesting',
    color: Color(0xFFF59E0B),
    buildMenu: buildSimpleMenu,
  ),
];

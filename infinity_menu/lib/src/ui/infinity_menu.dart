import 'package:flutter/material.dart';
import 'package:infinity_menu/src/configs/menu_layout_config.dart';
import 'package:infinity_menu/src/models/menu_data.dart';
import 'package:infinity_menu/src/models/menu_item_data.dart';
import 'package:infinity_menu/src/ui/feedback/click_feedback_container.dart';

/// Construct a menu based on the given [menuData].
///
/// This widget delegates item/header/separator UI construction to the
/// provided builders. The widget itself handles tap feedback, dismissal,
/// and submenu dispatch.
class InfinityMenu<D> extends StatelessWidget {
  /// The parent menu item, if this is a submenu.
  ///
  /// In case of a root menu, this should be `null`.
  final MenuItemData<D>? parent;

  /// The menu model to render.
  final MenuData<D> menuData;

  /// Builds the visible content for a single menu item.
  ///
  /// Do not wrap the returned widget in gesture handlers such as [InkWell] or
  /// [GestureDetector]. [InfinityMenu] already handles pointer interaction and
  /// selection feedback for each item.
  ///
  /// To customize tap feedback, use [MenuData.menuLayoutConfig] and
  /// [MenuLayoutConfig.selectionFeedbackConfig].
  final Widget Function(int index, int hostMenuSize, MenuItemData<D> item)
      menuItemBuilder;

  /// Builds the optional header shown above the first menu item.
  ///
  /// If omitted, no header is shown.
  ///
  /// The second argument is:
  /// - null when building a root menu (no parent/owner)
  /// - non-null when building a submenu (submenu's parent/owner)
  ///
  /// This lets the header reflect the context of the current menu,
  /// for example, by showing the title or icon of the parent item of
  /// the current menu.
  final Widget Function(BuildContext menuContext, MenuItemData<D>? parent)?
      menuHeaderBuilder;

  /// Builds the separator between adjacent menu items.
  ///
  /// If omitted, no separators are shown.
  ///
  /// The callback receives the item before the separator, along with its index
  /// and the total item count, so you can vary separators by position.
  final Widget Function(int index, int hostMenuSize, MenuItemData<D> item)?
      separatorBuilder;

  /// Called after an item with a non-empty submenu is tapped.
  ///
  /// If omitted, submenu requests are ignored.
  ///
  /// The current menu is dismissed first using [onPop], or [Navigator.pop] if
  /// [onPop] is not provided. After that, this callback is invoked with:
  /// - the current menu [BuildContext]
  /// - the tapped item that requested the submenu
  /// - the submenu data to open
  ///
  /// It is the caller's responsibility to present the submenu in a way that
  /// matches how the current menu was presented.
  final void Function(
    BuildContext menuContext,
    MenuData<D> submenu,
    MenuItemData<D> parent,
  )? onSubmenuRequest;

  /// Handles dismissal of the current menu after an item is selected.
  ///
  /// If omitted, [Navigator.pop] is used.
  final void Function(BuildContext menuContext)? onPop;

  /// Creates a [InfinityMenu].
  const InfinityMenu({
    super.key,
    this.parent,
    required this.menuData,
    required this.menuItemBuilder,
    this.menuHeaderBuilder,
    this.separatorBuilder,
    this.onSubmenuRequest,
    this.onPop,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: menuData.menuLayoutConfig.shrinkWrap,
      physics: menuData.menuLayoutConfig.scrollPhysics,
      padding: menuData.menuLayoutConfig.padding,
      itemCount: menuData.menuItems.length + 1,
      separatorBuilder: (_, index) => _buildSeparator(index),
      itemBuilder: _buildMenuItem,
    );
  }

  Widget _buildSeparator(int index) {
    if (index == 0 || separatorBuilder == null) {
      return const SizedBox.shrink();
    }

    return separatorBuilder!(
      index - 1,
      menuData.menuItems.length,
      menuData.menuItems[index - 1],
    );
  }

  Widget _buildMenuItem(BuildContext context, int index) {
    if (index == 0) {
      return menuHeaderBuilder?.call(context, parent) ??
          const SizedBox.shrink();
    }

    final itemIndex = index - 1;
    final item = menuData.menuItems[itemIndex];
    return ClickFeedbackContainer(
      feedbackConfig: menuData.menuLayoutConfig.selectionFeedbackConfig,
      onTap: () => _handleTap(context, item),
      child: menuItemBuilder(itemIndex, menuData.menuItems.length, item),
    );
  }

  void _handleTap(BuildContext context, MenuItemData<D> item) {
    // pop the current menu page
    onPop != null ? onPop!(context) : Navigator.pop(context);

    // fire the given callback for this item
    item.onItemAction?.call(item.data);

    // if there is a non-empty submenu, send request to open it
    // (if `onSubmenuRequest` is not null)
    final submenu = item.subMenuData;
    if (submenu != null && submenu.menuItems.isNotEmpty) {
      onSubmenuRequest?.call(context, submenu, item);
    }
  }
}

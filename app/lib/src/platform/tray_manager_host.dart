import 'dart:async';

import 'package:owghat_lib/owghat_lib.dart';
import 'package:tray_manager/tray_manager.dart' as native;

/// [TrayHost] on `tray_manager` (the native `TrayIcon` and `Menu` API).
///
/// The menu is rebuilt from the model on every [setMenu]; the previous native
/// menu is simply dropped (its handles are released when the wrappers are
/// collected). A checked row is shown as a check mark.
class TrayManagerHost implements TrayHost {
  /// Creates the host.
  TrayManagerHost();

  final StreamController<TrayEvent> _events =
      StreamController<TrayEvent>.broadcast();

  // The icon wrapper must stay referenced for as long as the icon should be
  // visible: a collected wrapper removes the icon.
  native.TrayIcon? _icon;
  final List<_ItemListener> _itemListeners = [];

  @override
  Stream<TrayEvent> get events => _events.stream;

  @override
  Future<void> setIcon(String asset) async {
    final icon = _icon ?? native.TrayIcon.create();
    if (icon == null) {
      throw StateError('The tray icon could not be created');
    }
    final image = native.ImageAsset.fromAsset(asset);
    if (image == null) {
      throw StateError('The tray icon image could not be loaded: $asset');
    }
    icon.icon = image;
    if (_icon == null) {
      _icon = icon;
      // The default context-menu trigger is "none": a menu needs this to
      // open at all.
      icon
        ..addListener(_onIconEvent)
        ..setContextMenuTrigger(native.ContextMenuTrigger.rightClicked);
    }
    icon.setVisible(true);
  }

  @override
  Future<void> setTooltip(String text) async => _icon?.setTooltip(text);

  @override
  Future<void> setMenu(TrayMenu menu) async {
    final icon = _icon;
    if (icon == null) return;
    for (final listener in _itemListeners) {
      listener.item.removeListener(listener.id);
    }
    _itemListeners.clear();
    icon.setContextMenu(_build(menu.entries));
  }

  @override
  Future<void> dispose() async {
    for (final listener in _itemListeners) {
      listener.item.removeListener(listener.id);
    }
    _itemListeners.clear();
    final icon = _icon;
    _icon = null;
    icon?.setVisible(false);
    icon?.dispose();
    await _events.close();
  }

  native.Menu _build(List<TrayMenuEntry> entries) {
    final menu = native.Menu.create();
    if (menu == null) throw StateError('The tray menu could not be created');
    for (final entry in entries) {
      switch (entry) {
        case TrayMenuSeparator():
          menu.addSeparator();
        case TrayMenuItem():
          final item = _buildItem(entry);
          if (item != null) menu.addItem(item);
      }
    }
    return menu;
  }

  native.MenuItem? _buildItem(TrayMenuItem entry) {
    final type = entry.children.isNotEmpty
        ? native.MenuItemType.submenu
        : entry.checked != null
        ? native.MenuItemType.checkbox
        : native.MenuItemType.normal;
    final item = native.MenuItem.createWithLabelAndType(entry.label, type);
    if (item == null) return null;
    item.isEnabled = entry.enabled;
    if (entry.checked != null) {
      item.state = entry.checked!
          ? native.MenuItemState.checked
          : native.MenuItemState.unchecked;
    }
    if (entry.children.isNotEmpty) {
      item.submenu = _build(entry.children);
    } else {
      final id = item.addListener((event) {
        if (event is native.MenuItemClickedEvent) {
          _events.add(TrayEvent(TrayEventKind.menuItem, menuItemId: entry.id));
        }
      });
      _itemListeners.add(_ItemListener(item, id));
    }
    return item;
  }

  void _onIconEvent(native.TrayIconEvent event) {
    switch (event) {
      case native.TrayIconClickedEvent():
        _events.add(const TrayEvent(TrayEventKind.iconClicked));
      case native.TrayIconDoubleClickedEvent():
        _events.add(const TrayEvent(TrayEventKind.iconDoubleClicked));
      case native.TrayIconRightClickedEvent():
        break; // The context menu opens by itself.
    }
  }
}

class _ItemListener {
  _ItemListener(this.item, this.id);

  final native.MenuItem item;
  final native.ListenerId id;
}

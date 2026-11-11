import 'package:flutter/foundation.dart';

/// One entry of the tray menu.
@immutable
sealed class TrayMenuEntry {
  const TrayMenuEntry();
}

/// A separator line.
class TrayMenuSeparator extends TrayMenuEntry {
  /// Creates a separator.
  const TrayMenuSeparator();

  @override
  bool operator ==(Object other) => other is TrayMenuSeparator;

  @override
  int get hashCode => 0;
}

/// A menu row: an action, a disabled caption, a radio row or a submenu.
class TrayMenuItem extends TrayMenuEntry {
  /// Creates a row. A row with [children] opens a submenu.
  const TrayMenuItem({
    required this.id,
    required this.label,
    this.enabled = true,
    this.checked,
    this.children = const [],
  });

  /// Stable id reported by `TrayEvent.menuItemId` when the row is clicked.
  final String id;

  /// Text of the row.
  final String label;

  /// Whether the row can be clicked.
  final bool enabled;

  /// Radio / check state, or null when the row has none.
  final bool? checked;

  /// Submenu rows (empty for a plain row).
  final List<TrayMenuEntry> children;

  @override
  bool operator ==(Object other) =>
      other is TrayMenuItem &&
      other.id == id &&
      other.label == label &&
      other.enabled == enabled &&
      other.checked == checked &&
      listEquals(other.children, children);

  @override
  int get hashCode =>
      Object.hash(id, label, enabled, checked, Object.hashAll(children));

  @override
  String toString() => 'TrayMenuItem($id: $label)';
}

/// The whole tray menu, top to bottom.
@immutable
class TrayMenu {
  /// Creates a menu.
  const TrayMenu(this.entries);

  /// The rows.
  final List<TrayMenuEntry> entries;

  /// Finds the row with [id] anywhere in the menu.
  TrayMenuItem? find(String id) => _find(entries, id);

  static TrayMenuItem? _find(List<TrayMenuEntry> list, String id) {
    for (final entry in list) {
      if (entry is! TrayMenuItem) continue;
      if (entry.id == id) return entry;
      final inner = _find(entry.children, id);
      if (inner != null) return inner;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is TrayMenu && listEquals(other.entries, entries);

  @override
  int get hashCode => Object.hashAll(entries);
}

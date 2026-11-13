import 'dart:convert';

import 'package:owghat_lib/owghat_lib.dart';
import 'package:web/web.dart' as web;

/// A [JsonStore] in the browser's local storage, one key per document. It
/// stays on this computer and in this browser only.
class BrowserJsonStore implements JsonStore {
  /// Creates the store for [name] (for example `settings.json`).
  BrowserJsonStore(String name) : _key = 'salaat.$name';

  final String _key;

  @override
  Future<StoreReadResult> read() async {
    final String? text;
    try {
      text = web.window.localStorage.getItem(_key);
    } on Object {
      // Storage blocked (private mode, site data off): start from defaults.
      return (json: null, existed: false, quarantined: false);
    }
    if (text == null) return (json: null, existed: false, quarantined: false);
    try {
      return (json: jsonDecode(text), existed: true, quarantined: false);
    } on FormatException {
      // Keep the broken text under another key instead of losing it.
      try {
        web.window.localStorage
          ..setItem('$_key.corrupt', text)
          ..removeItem(_key);
      } on Object {
        // Nothing more to do.
      }
      return (json: null, existed: true, quarantined: true);
    }
  }

  @override
  Future<void> write(Object? json) async {
    try {
      web.window.localStorage.setItem(_key, jsonEncode(json));
    } on Object {
      // Storage full or blocked: the settings live for this visit only.
    }
  }
}

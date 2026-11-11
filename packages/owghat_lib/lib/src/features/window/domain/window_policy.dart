/// What to do when the user closes the window.
enum CloseDecision {
  /// Hide the window; the app keeps running in the tray.
  hideToTray,

  /// Really quit.
  quit,
}

/// Decides what closing the window does.
///
/// It only hides when the user chose close-to-tray and a tray icon is
/// actually there to bring the window back; otherwise the app would be
/// running with no way to reach it.
CloseDecision decideClose({
  required bool closeToTray,
  required bool trayReady,
}) => closeToTray && trayReady ? CloseDecision.hideToTray : CloseDecision.quit;

/// Whether the window starts hidden: Windows started the app with
/// `--minimized` and the user wants that ("start minimised" setting).
bool startsHidden({
  required bool minimizedArgument,
  required bool startMinimizedSetting,
}) => minimizedArgument && startMinimizedSetting;

/// Whether the one-time "the app stays in the tray" hint is due.
bool shouldShowTrayHint({required bool alreadyShown}) => !alreadyShown;

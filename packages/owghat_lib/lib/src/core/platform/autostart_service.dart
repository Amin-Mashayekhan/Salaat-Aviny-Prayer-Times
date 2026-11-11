/// Starts the app with Windows (`HKCU\...\Run`, value `Owghat`, data
/// `"<exe>" --minimized`). Never needs administrator rights.
abstract interface class AutostartService {
  /// Whether the app is registered to start with Windows.
  Future<bool> isEnabled();

  /// Registers the app for the current user.
  Future<void> enable();

  /// Removes the registration.
  Future<void> disable();
}

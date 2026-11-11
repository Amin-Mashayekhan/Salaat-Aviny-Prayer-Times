/// Keeps one copy of the app running.
///
/// The Windows implementation lives in the app package
/// (`windows_single_instance`).
abstract interface class SingleInstance {
  /// Claims the instance. Returns false when another copy already runs: the
  /// arguments were forwarded to it and this process must exit.
  Future<bool> ensure(List<String> args);

  /// Arguments of later launches, forwarded by [ensure] of the second copy.
  Stream<List<String>> get forwardedArgs;
}

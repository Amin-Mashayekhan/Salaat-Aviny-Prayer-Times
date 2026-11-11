import 'dart:io';

/// Reads and writes backup files chosen by the user. Tests replace it with an
/// in-memory fake.
abstract interface class BackupFiles {
  /// The text of the file at [path]. Throws if it cannot be read.
  Future<String> read(String path);

  /// Writes [text] to [path], replacing it. Throws if it cannot be written.
  Future<void> write(String path, String text);
}

/// [BackupFiles] over `dart:io`.
class IoBackupFiles implements BackupFiles {
  /// Creates the implementation.
  const IoBackupFiles();

  @override
  Future<String> read(String path) => File(path).readAsString();

  @override
  Future<void> write(String path, String text) async {
    await File(path).writeAsString(text, flush: true);
  }
}

/// Native file pickers. Each returns the chosen absolute path, or null when
/// the user cancelled. Reading and writing the file is the caller's job.
abstract interface class FileDialogs {
  /// Chooses an audio file for an azan (wav, mp3, ogg, m4a, flac...).
  Future<String?> pickSoundFile();

  /// Chooses where to save a settings backup.
  Future<String?> pickBackupSavePath({required String suggestedName});

  /// Chooses a settings backup to restore.
  Future<String?> pickBackupOpenPath();
}

import 'package:file_selector/file_selector.dart';
import 'package:owghat_lib/owghat_lib.dart';

/// [FileDialogs] on `file_selector` (the native Windows dialogs).
///
/// The filters carry no label: a label would be user-visible text, and the
/// Windows dialog shows the extension list on its own.
class FileSelectorDialogs implements FileDialogs {
  /// Creates the dialogs.
  const FileSelectorDialogs();

  static const XTypeGroup _audio = XTypeGroup(
    extensions: ['wav', 'mp3', 'ogg', 'm4a', 'aac', 'flac', 'wma'],
  );

  static const XTypeGroup _json = XTypeGroup(extensions: ['json']);

  @override
  Future<String?> pickSoundFile() async {
    final file = await openFile(acceptedTypeGroups: const [_audio]);
    return file?.path;
  }

  @override
  Future<String?> pickBackupSavePath({required String suggestedName}) async {
    final location = await getSaveLocation(
      acceptedTypeGroups: const [_json],
      suggestedName: suggestedName,
    );
    return location?.path;
  }

  @override
  Future<String?> pickBackupOpenPath() async {
    final file = await openFile(acceptedTypeGroups: const [_json]);
    return file?.path;
  }
}

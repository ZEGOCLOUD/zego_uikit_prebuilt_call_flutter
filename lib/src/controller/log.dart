part of 'package:zego_uikit_prebuilt_call/src/controller.dart';

mixin ZegoCallControllerLog {
  final _logImpl = ZegoCallControllerLogImpl();

  ZegoCallControllerLogImpl get log => _logImpl;
}

/// Log controller for exporting and collecting call-related logs.
class ZegoCallControllerLogImpl {
  /// Export log files.
  ///
  /// [title] export title, defaults to current timestamp
  /// [content] export content description
  /// [fileName] Zip file name (without extension), defaults to current timestamp
  /// [fileTypes] List of file types to collect, defaults to [ZegoLogExporterFileType.txt, ZegoLogExporterFileType.log, ZegoLogExporterFileType.zip]
  /// [directories] List of directory types to collect, defaults to 5 log directories
  /// [onProgress] Optional progress callback, returns progress percentage (0.0 to 1.0)
  Future<bool> exportLogs({

    /// The title for the exported log file.
    String? title,

    /// The content description for the exported log file.
    String? content,

    /// The name of the exported zip file (without extension).
    String? fileName,

    /// List of file types to collect.
    List<ZegoLogExporterFileType> fileTypes = const [
      ZegoLogExporterFileType.txt,
      ZegoLogExporterFileType.log,
      ZegoLogExporterFileType.zip
    ],

    /// List of directory types to collect.
    List<ZegoLogExporterDirectoryType> directories = const [
      ZegoLogExporterDirectoryType.zegoUIKits,
      ZegoLogExporterDirectoryType.zimAudioLog,
      ZegoLogExporterDirectoryType.zimLogs,
      ZegoLogExporterDirectoryType.zefLogs,
      ZegoLogExporterDirectoryType.zegoLogs,
    ],

    /// Callback function for export progress updates.
    void Function(double progress)? onProgress,
  }) async {
    return ZegoUIKit().exportLogs(
      title: title,
      content: content,
      fileName: fileName,
      fileTypes: fileTypes,
      directories: directories,
      onProgress: onProgress,
    );
  }
}

/// uikit-${library_type}-${error_type}-${error_code}
/// 3-xx-xxx-xxx
///
/// library_type: {
///   00:uikit;
///
///   01:signaling plugin;
///   02:adapter plugin;
///   03:beauty plugin;
///
///   10:call prebuilt;
///   11:live audio room prebuilt;
///   12:live streaming prebuilt;
///   13:video conference prebuilt;
///   14:zim-kit;
/// }
///
/// --------------------------------
///
/// Error codes for the call functionality.
///
/// This class defines error codes following the pattern: uikit-{library_type}-{error_type}-{error_code}
///
/// Error code format: 3-XX-XXX-XXX
///
/// - library_type 00: uikit
/// - library_type 01: signaling plugin
/// - library_type 02: adapter plugin
/// - library_type 03: beauty plugin
/// - library_type 10: call prebuilt
/// - library_type 11: live audio room prebuilt
/// - library_type 12: live streaming prebuilt
/// - library_type 13: video conference prebuilt
/// - library_type 14: zim-kit
///
/// Example error code: 3-10-000-000
class ZegoCallErrorCode {
  /// Execution successful.
  static const int success = 0;

  /// Description:
  /// static const int XXX = 310000001;
}

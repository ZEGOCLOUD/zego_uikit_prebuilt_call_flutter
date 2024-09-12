class ZegoCallConfirmDialogInfo {
  /// The title of the dialog
  String title;

  /// The message content of the dialog
  String message;

  /// The text for the cancel button
  String cancelButtonName;

  /// The text for the confirm button
  String confirmButtonName;

  ZegoCallConfirmDialogInfo({
    required this.title,
    required this.message,
    this.cancelButtonName = 'Cancel',
    this.confirmButtonName = 'OK',
  });
}

/// Set the key for modifying CallKit variables.
/// If you want to modify certain variables in CallKit, you can invoke [ZegoUIKitPrebuiltCallInvitationService].[setCallKitVariables].
enum CallKitInnerVariable {
  /// string, Text Accept used in Android
  textAccept,

  /// string, Text Decline used in Android
  textDecline,

  /// string, Text Missed Call used in Android (show in miss call notification)
  textMissedCall,

  /// string, Text Call back used in Android (show in miss call notification)
  textCallback,

  /// 	Incoming call screen background color.	#0955fa
  backgroundColor,

  /// Using image background for Incoming call screen. example: http://... https://... or "assets/abc.png"	None
  backgroundUrl,

  /// Color used in button/text on notification.
  actionColor,

  /// string, App's name. using for display inside Callkit(iOS).
  /// App Name, Deprecated for iOS > 14, default using App name
  textAppName,

  /// string, ringtone path
  ringtonePath,

  /// show call id or not
  callIDVisibility,

  /// show fullscreen or not
  showFullScreen,
}

extension CallKitInnerVariableExtension on CallKitInnerVariable {
  /// The keys used to cache CallKit variables.
  String get cacheKey {
    switch (this) {
      case CallKitInnerVariable.textAccept:
        return 'zg_ck_t_accept';
      case CallKitInnerVariable.textDecline:
        return 'zg_ck_t_decline';
      case CallKitInnerVariable.textMissedCall:
        return 'zg_ck_t_m_call';
      case CallKitInnerVariable.textCallback:
        return 'zg_ck_t_cb';
      case CallKitInnerVariable.textAppName:
        return 'zg_ck_t_app_name';
      case CallKitInnerVariable.backgroundColor:
        return 'zg_ck_bg_clr';
      case CallKitInnerVariable.backgroundUrl:
        return 'zg_ck_bg_url';
      case CallKitInnerVariable.actionColor:
        return 'zg_ck_ac_clr';
      case CallKitInnerVariable.ringtonePath:
        return 'zg_ck_t_rg_p';
      case CallKitInnerVariable.callIDVisibility:
        return 'zg_ck_call_id_v';
      case CallKitInnerVariable.showFullScreen:
        return 'zg_ck_s_f_c';
    }
  }

  /// The default values of CallKit variables.
  dynamic get defaultValue {
    switch (this) {
      case CallKitInnerVariable.textAccept:
        return 'Accept';
      case CallKitInnerVariable.textDecline:
        return 'Decline';
      case CallKitInnerVariable.textMissedCall:
        return 'Missed Call';
      case CallKitInnerVariable.textCallback:
        return 'Call back';
      case CallKitInnerVariable.backgroundColor:
        return '#0955fa';
      case CallKitInnerVariable.backgroundUrl:
        return '';
      case CallKitInnerVariable.actionColor:
        return '#4CAF50';
      case CallKitInnerVariable.textAppName:
        return '';
      case CallKitInnerVariable.ringtonePath:
        return 'system_ringtone_default';
      case CallKitInnerVariable.callIDVisibility:
      case CallKitInnerVariable.showFullScreen:
        return false;
    }
  }
}

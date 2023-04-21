enum CallKitInnerVariable {
  /// double, Incoming call/Outgoing call display time (millisecond). If the time is over, the call will be missed.
  duration,

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

  /// App's Icon. using for display inside Callkit(iOS)	CallKitLogo
  /// using from Images.xcassets/CallKitLogo
  iconName,

  /// string, App's name. using for display inside Callkit(iOS).
  /// App Name, Deprecated for iOS > 14, default using App name
  textAppName,
}

extension CallKitInnerVariableExtension on CallKitInnerVariable {
  String get cacheKey {
    switch (this) {
      case CallKitInnerVariable.duration:
        return 'zg_ck_duration';
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
      case CallKitInnerVariable.iconName:
        return 'zg_ck_t_icon_name';
    }
  }

  dynamic get defaultValue {
    switch (this) {
      case CallKitInnerVariable.duration:
        return 30000.0; //  30 seconds
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
        return 'assets/test.png';
      case CallKitInnerVariable.actionColor:
        return '#4CAF50';
      case CallKitInnerVariable.iconName:
      case CallKitInnerVariable.textAppName:
        return '';
    }
  }
}

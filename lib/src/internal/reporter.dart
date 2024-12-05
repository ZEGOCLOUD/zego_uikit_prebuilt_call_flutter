import 'package:flutter/cupertino.dart';

class ZegoCallReporter {
  static String eventInit = "call/init";
  static String eventUninit = "call/unInit";
  static String eventSendInvitation = 'call/invite';
  static String eventReceivedInvitation = 'call/invitationReceived';
  static String eventDisplayInvitationNotification = 'call/displayNotification';
  static String eventRespondInvitation = 'call/respondInvitation';

  static String eventKeyInvitationID = "call_id";
  static String eventKeyInvitationSource = "source";
  static String eventKeyInvitationSourceAPI = "api";
  static String eventKeyInvitationSourceButton = "button";
  static String eventKeyCallID = "room_id";

  static String eventKeyExtendedData = "extended_data";

  static String eventKeyInviter = "inviter";
  static String eventKeyInvitees = "invitees";
  static String eventKeyInviteesCount = "count";
  static String eventKeyErrorUsers = "error_userlist";
  static String eventKeyErrorUsersCount = "error_count";

  static String eventKeyAppState = "app_state";
  static String eventKeyAppStateActive = "active";
  static String eventKeyAppStateBackground = "background";
  static String eventKeyAppStateRestarted = "restarted";

  static String eventKeyAction = "action";
  static String eventKeyActionAccept = "accept";
  static String eventKeyActionRefuse = "refuse";
  static String eventKeyActionBusy = "busy";
  static String eventKeyActionCancel = "inviterCancel";
  static String eventKeyActionTimeout = "timeout";

  static String currentAppState() {
    final appStateMap = <AppLifecycleState, String>{
      AppLifecycleState.resumed: eventKeyAppStateActive,
      AppLifecycleState.inactive: eventKeyAppStateBackground,
      AppLifecycleState.hidden: eventKeyAppStateBackground,
      AppLifecycleState.paused: eventKeyAppStateBackground,
      AppLifecycleState.detached: eventKeyAppStateBackground,
    };

    return appStateMap[WidgetsBinding.instance.lifecycleState] ??
        eventKeyAppStateBackground;
  }
}

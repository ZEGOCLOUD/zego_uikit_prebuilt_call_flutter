class ZegoCallReporter {
  static String eventInit = "call/init";
  static String eventUninit = "call/unInit";
  static String eventSendInvitation = 'call/invite';
  static String eventReceivedInvitation = 'call/invitationReceived';
  static String eventDisplayInvitationNotification = 'call/displayNotification';
  static String eventRespondInvitation = 'call/respondInvitation';

  static String eventKeyInvitationSource = "source";
  static String eventKeyInvitationSourceAPI = "api";
  static String eventKeyInvitationSourceButton = "button";

  static String eventKeyExtendedData = "extended_data";

  static String eventKeyAction = "action";
  static String eventKeyActionAccept = "accept";
  static String eventKeyActionRefuse = "refuse";
  static String eventKeyActionBusy = "busy";
  static String eventKeyActionCancel = "inviterCancel";
  static String eventKeyActionTimeout = "timeout";
}

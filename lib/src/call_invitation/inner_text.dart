/// %0: is a string placeholder, represents the first parameter of prompt,
/// in here, default is user name
const String param_1 = "%0";

class ZegoCallInvitationInnerText {
  String incomingVideoCallDialogTitle;
  String incomingVideoCallDialogMessage;
  String incomingVoiceCallDialogTitle;
  String incomingVoiceCallDialogMessage;
  String incomingVideoCallPageTitle;
  String incomingVideoCallPageMessage;
  String incomingVoiceCallPageTitle;
  String incomingVoiceCallPageMessage;

  String outgoingVideoCallPageTitle;
  String outgoingVideoCallPageMessage;
  String outgoingVoiceCallPageTitle;
  String outgoingVoiceCallPageMessage;

  String incomingGroupVideoCallDialogTitle;
  String incomingGroupVideoCallDialogMessage;
  String incomingGroupVoiceCallDialogTitle;
  String incomingGroupVoiceCallDialogMessage;
  String incomingGroupVideoCallPageTitle;
  String incomingGroupVideoCallPageMessage;
  String incomingGroupVoiceCallPageTitle;
  String incomingGroupVoiceCallPageMessage;

  String outgoingGroupVideoCallPageTitle;
  String outgoingGroupVideoCallPageMessage;
  String outgoingGroupVoiceCallPageTitle;
  String outgoingGroupVoiceCallPageMessage;

  String incomingCallPageDeclineButton;
  String incomingCallPageAcceptButton;

  ZegoCallInvitationInnerText({
    String? incomingVideoCallDialogTitle,
    String? incomingVideoCallDialogMessage,
    String? incomingVoiceCallDialogTitle,
    String? incomingVoiceCallDialogMessage,
    String? incomingVideoCallPageTitle,
    String? incomingVideoCallPageMessage,
    String? incomingVoiceCallPageTitle,
    String? incomingVoiceCallPageMessage,
    String? incomingCallPageDeclineButton,
    String? incomingCallPageAcceptButton,
    String? outgoingVideoCallPageTitle,
    String? outgoingVideoCallPageMessage,
    String? outgoingVoiceCallPageTitle,
    String? outgoingVoiceCallPageMessage,
    String? incomingGroupVideoCallDialogTitle,
    String? incomingGroupVideoCallDialogMessage,
    String? incomingGroupVoiceCallDialogTitle,
    String? incomingGroupVoiceCallDialogMessage,
    String? incomingGroupVideoCallPageTitle,
    String? incomingGroupVideoCallPageMessage,
    String? incomingGroupVoiceCallPageTitle,
    String? incomingGroupVoiceCallPageMessage,
    String? outgoingGroupVideoCallPageTitle,
    String? outgoingGroupVideoCallPageMessage,
    String? outgoingGroupVoiceCallPageTitle,
    String? outgoingGroupVoiceCallPageMessage,
  })  : incomingVideoCallDialogTitle = incomingVideoCallDialogTitle ?? param_1,
        incomingVideoCallDialogMessage =
            incomingVideoCallDialogMessage ?? "Incoming video call...",
        incomingVoiceCallDialogTitle = incomingVoiceCallDialogTitle ?? param_1,
        incomingVoiceCallDialogMessage =
            incomingVoiceCallDialogMessage ?? "Incoming voice call...",
        incomingVideoCallPageTitle = incomingVideoCallPageTitle ?? param_1,
        incomingVideoCallPageMessage =
            incomingVideoCallPageMessage ?? "Incoming video call...",
        incomingVoiceCallPageTitle = incomingVoiceCallPageTitle ?? param_1,
        incomingVoiceCallPageMessage =
            incomingVoiceCallPageMessage ?? "Incoming voice call...",
        incomingCallPageDeclineButton =
            incomingCallPageDeclineButton ?? "Decline",
        incomingCallPageAcceptButton = incomingCallPageAcceptButton ?? "Accept",
        outgoingVideoCallPageTitle = outgoingVideoCallPageTitle ?? param_1,
        outgoingVideoCallPageMessage =
            outgoingVideoCallPageMessage ?? "Calling...",
        outgoingVoiceCallPageTitle = outgoingVoiceCallPageTitle ?? param_1,
        outgoingVoiceCallPageMessage =
            outgoingVoiceCallPageMessage ?? "Calling...",
        incomingGroupVideoCallDialogTitle =
            incomingGroupVideoCallDialogTitle ?? param_1,
        incomingGroupVideoCallDialogMessage =
            incomingGroupVideoCallDialogMessage ??
                "Incoming group video call...",
        incomingGroupVoiceCallDialogTitle =
            incomingGroupVoiceCallDialogTitle ?? param_1,
        incomingGroupVoiceCallDialogMessage =
            incomingGroupVoiceCallDialogMessage ??
                "Incoming group voice call...",
        incomingGroupVideoCallPageTitle =
            incomingGroupVideoCallPageTitle ?? param_1,
        incomingGroupVideoCallPageMessage =
            incomingGroupVideoCallPageMessage ?? "Incoming group video call...",
        incomingGroupVoiceCallPageTitle =
            incomingGroupVoiceCallPageTitle ?? param_1,
        incomingGroupVoiceCallPageMessage =
            incomingGroupVoiceCallPageMessage ?? "Incoming group voice call...",
        outgoingGroupVideoCallPageTitle =
            outgoingGroupVideoCallPageTitle ?? param_1,
        outgoingGroupVideoCallPageMessage =
            outgoingGroupVideoCallPageMessage ?? "Calling...",
        outgoingGroupVoiceCallPageTitle =
            outgoingGroupVoiceCallPageTitle ?? param_1,
        outgoingGroupVoiceCallPageMessage =
            outgoingGroupVoiceCallPageMessage ?? "Calling...";
}

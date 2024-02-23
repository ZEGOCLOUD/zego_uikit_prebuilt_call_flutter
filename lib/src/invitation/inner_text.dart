/// %0: is a string placeholder, represents the first parameter of prompt
const String param_1 = '%0';

/// Control the text on the UI.
/// Modify the values of the corresponding properties to modify the text on the UI.
/// You can also change it to other languages.
/// This class is used for the ZegoUIKitPrebuiltCall.innerText property.
/// **Note that the placeholder %0 in the text will be replaced with the corresponding username.**
class ZegoCallInvitationInnerText {
  /// The title of the incoming video call dialog,
  /// The **default value** is **inviter\'s name**.
  String incomingVideoCallDialogTitle;

  /// The message of the incoming video call dialog,
  /// The **default value** is *"Incoming video call..."*.
  String incomingVideoCallDialogMessage;

  /// The title of the incoming voice call dialog,
  /// The **default value** is **inviter\'s name**.
  String incomingVoiceCallDialogTitle;

  /// The message of the incoming voice call dialog,
  /// The **default value** is *"Incoming voice call..."*.
  String incomingVoiceCallDialogMessage;

  /// The title of the incoming video call page,
  /// The **default value** is **inviter\'s name**.
  String incomingVideoCallPageTitle;

  /// The message of the incoming video call page,
  /// The **default value** is *"Incoming video call..."*.
  String incomingVideoCallPageMessage;

  /// The title of the incoming voice call page,
  /// The **default value** is **inviter\'s name**.
  String incomingVoiceCallPageTitle;

  /// The message of the incoming voice call page,
  /// The **default value** is *"Incoming voice call..."*.
  String incomingVoiceCallPageMessage;

  /// The title of the outgoing video call page,
  /// The **default value** is **first invitee's name**.
  String outgoingVideoCallPageTitle;

  /// The message of the outgoing video call page,
  /// The **default value** is *"Calling..."*
  String outgoingVideoCallPageMessage;

  /// The title of the outgoing voice call page,
  /// The **default value** is **first invitee's name**.
  String outgoingVoiceCallPageTitle;

  /// The message of the outgoing voice call page,
  /// The **default value** is *"Calling..."*
  String outgoingVoiceCallPageMessage;

  /// The title of the incoming group video call dialog,
  /// The **default value** is **inviter\'s name**.
  String incomingGroupVideoCallDialogTitle;

  /// The message of the incoming group video call dialog,
  /// The **default value** is *"Incoming group video call..."*.
  String incomingGroupVideoCallDialogMessage;

  /// The title of the incoming group voice call dialog,
  /// The **default value** is **inviter\'s name**.
  String incomingGroupVoiceCallDialogTitle;

  /// The message of the incoming group voice call dialog,
  /// The **default value** is *"Incoming group voice call..."*.
  String incomingGroupVoiceCallDialogMessage;

  /// The title of the incoming group video call page,
  /// The **default value** is **inviter\'s name**.
  String incomingGroupVideoCallPageTitle;

  /// The message of the incoming group video call page,
  /// The **default value** is *"Incoming group video call..."*.
  String incomingGroupVideoCallPageMessage;

  /// The title of the incoming group voice call page,
  /// The **default value** is **inviter\'s name**.
  String incomingGroupVoiceCallPageTitle;

  /// The message of the incoming group voice call page,
  /// The **default value** is *"Incoming group voice call..."*.
  String incomingGroupVoiceCallPageMessage;

  /// The title of the outgoing group video call page,
  /// The **default value** is **first invitee's name**.
  String outgoingGroupVideoCallPageTitle;

  /// The message of the outgoing group video call page,
  /// The **default value** is *"Calling..."*.
  String outgoingGroupVideoCallPageMessage;

  /// The title of the outgoing group voice call page,
  /// The **default value** is **first invitee's name**.
  String outgoingGroupVoiceCallPageTitle;

  /// The message of the outgoing group voice call page,
  /// The **default value** is *"Calling..."*.
  String outgoingGroupVoiceCallPageMessage;

  /// The button on the call bottom bar to decline current incoming call.
  /// The **default value** is *"Decline"*.
  String incomingCallPageDeclineButton;

  /// The button on the call bottom bar to accept current incoming call.
  /// The **default value** is *"Accept"*.
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
            incomingVideoCallDialogMessage ?? 'Incoming video call...',
        incomingVoiceCallDialogTitle = incomingVoiceCallDialogTitle ?? param_1,
        incomingVoiceCallDialogMessage =
            incomingVoiceCallDialogMessage ?? 'Incoming voice call...',
        incomingVideoCallPageTitle = incomingVideoCallPageTitle ?? param_1,
        incomingVideoCallPageMessage =
            incomingVideoCallPageMessage ?? 'Incoming video call...',
        incomingVoiceCallPageTitle = incomingVoiceCallPageTitle ?? param_1,
        incomingVoiceCallPageMessage =
            incomingVoiceCallPageMessage ?? 'Incoming voice call...',
        incomingCallPageDeclineButton =
            incomingCallPageDeclineButton ?? 'Decline',
        incomingCallPageAcceptButton = incomingCallPageAcceptButton ?? 'Accept',
        outgoingVideoCallPageTitle = outgoingVideoCallPageTitle ?? param_1,
        outgoingVideoCallPageMessage =
            outgoingVideoCallPageMessage ?? 'Calling...',
        outgoingVoiceCallPageTitle = outgoingVoiceCallPageTitle ?? param_1,
        outgoingVoiceCallPageMessage =
            outgoingVoiceCallPageMessage ?? 'Calling...',
        incomingGroupVideoCallDialogTitle =
            incomingGroupVideoCallDialogTitle ?? param_1,
        incomingGroupVideoCallDialogMessage =
            incomingGroupVideoCallDialogMessage ??
                'Incoming group video call...',
        incomingGroupVoiceCallDialogTitle =
            incomingGroupVoiceCallDialogTitle ?? param_1,
        incomingGroupVoiceCallDialogMessage =
            incomingGroupVoiceCallDialogMessage ??
                'Incoming group voice call...',
        incomingGroupVideoCallPageTitle =
            incomingGroupVideoCallPageTitle ?? param_1,
        incomingGroupVideoCallPageMessage =
            incomingGroupVideoCallPageMessage ?? 'Incoming group video call...',
        incomingGroupVoiceCallPageTitle =
            incomingGroupVoiceCallPageTitle ?? param_1,
        incomingGroupVoiceCallPageMessage =
            incomingGroupVoiceCallPageMessage ?? 'Incoming group voice call...',
        outgoingGroupVideoCallPageTitle =
            outgoingGroupVideoCallPageTitle ?? param_1,
        outgoingGroupVideoCallPageMessage =
            outgoingGroupVideoCallPageMessage ?? 'Calling...',
        outgoingGroupVoiceCallPageTitle =
            outgoingGroupVoiceCallPageTitle ?? param_1,
        outgoingGroupVoiceCallPageMessage =
            outgoingGroupVoiceCallPageMessage ?? 'Calling...';

  /// if add a new text, need check [ZegoCallInvitationInnerTextForCallInvitationServicePrivate]
}

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

  /// The button on the call bottom bar to cancel current outgoing call.
  /// The **default value** is *"Cancel"*.
  String outgoingCallPageACancelButton;

  /// The title of the missed call notification,
  /// The **default value** is **Missed Call**.
  String missedCallNotificationTitle;

  /// The content of the group video missed call notification,
  /// The **default value** is **Group Video Call**.
  String missedGroupVideoCallNotificationContent;

  /// The content of the group audio missed call notification,
  /// The **default value** is **Group Audio Call**.
  String missedGroupAudioCallNotificationContent;

  /// The content of the video missed call notification,
  /// The **default value** is **Video Call**.
  String missedVideoCallNotificationContent;

  /// The content of the audio missed call notification,
  /// The **default value** is **Audio Call**.
  String missedAudioCallNotificationContent;

  /// The title of the systemAlertWindow permission request confirmation dialog,
  /// The **default value** is **Display over other apps**.
  String systemAlertWindowConfirmDialogSubTitle;

  /// The title of the dialog tips for some permissions cannot be obtained
  /// directly and must be set manually by the user
  /// The **default value** is:
  /// Please manually enable the following permissions:
  String permissionManuallyConfirmDialogTitle;

  /// The title of the dialog tips for some permissions cannot be obtained
  /// directly and must be set manually by the user
  /// The **default value** is:
  /// '• Allow auto launch\n'
  /// '• Allow notification on Banner and Lock screen\n'
  /// '• Allow display over other apps\n'
  /// '• Show on lock screen\n'
  /// '• Show floating window\n'
  /// '• Pop up interface in background\n'
  String permissionManuallyConfirmDialogSubTitle;

  /// The allow button text of the permission request,
  /// The **default value** is *"Allow $appName to $subTitle"*.
  String permissionConfirmDialogTitle;

  /// The allow button text of the permission request,
  /// The **default value** is *"Allow"*.
  String permissionConfirmDialogAllowButton;

  /// The deny button text of the permission request,
  /// The **default value** is *"Deny"*.
  String permissionConfirmDialogDenyButton;

  /// The deny button text of the permission request,
  /// The **default value** is *"Cancel"*.
  String permissionConfirmDialogCancelButton;

  /// The deny button text of the permission request,
  /// The **default value** is *"OK"*.
  String permissionConfirmDialogOKButton;

  /// The text below the microphone button in the calling toolbar,
  /// The **default value** is *"Microphone"*.
  String callingToolbarMicrophoneButtonText;

  /// The text below the microphone button when it's ON in the calling toolbar,
  /// The **default value** is *"Microphone ON"*.
  String callingToolbarMicrophoneOnButtonText;

  /// The text below the microphone button when it's OFF in the calling toolbar,
  /// The **default value** is *"Microphone OFF"*.
  String callingToolbarMicrophoneOffButtonText;

  /// The text below the speaker button in the calling toolbar,
  /// The **default value** is *"Speaker"*.
  String callingToolbarSpeakerButtonText;

  /// The text below the speaker button when it's ON in the calling toolbar,
  /// The **default value** is *"Speaker ON"*.
  String callingToolbarSpeakerOnButtonText;

  /// The text below the speaker button when it's OFF in the calling toolbar,
  /// The **default value** is *"Speaker OFF"*.
  String callingToolbarSpeakerOffButtonText;

  /// The text below the camera button in the calling toolbar,
  /// The **default value** is *"Camera"*.
  String callingToolbarCameraButtonText;

  /// The text below the camera button when it's ON in the calling toolbar,
  /// The **default value** is *"Camera ON"*.
  String callingToolbarCameraOnButtonText;

  /// The text below the camera button when it's OFF in the calling toolbar,
  /// The **default value** is *"Camera OFF"*.
  String callingToolbarCameraOffButtonText;

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
    String? outgoingCallPageACancelButton,
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
    String? missedCallNotificationTitle,
    String? missedGroupVideoCallNotificationContent,
    String? missedGroupAudioCallNotificationContent,
    String? missedVideoCallNotificationContent,
    String? missedAudioCallNotificationContent,
    String? systemAlertWindowConfirmDialogSubTitle,
    String? permissionManuallyConfirmDialogTitle,
    String? permissionManuallyConfirmDialogSubTitle,
    String? permissionConfirmDialogTitle,
    String? permissionConfirmDialogAllowButton,
    String? permissionConfirmDialogDenyButton,
    String? permissionConfirmDialogCancelButton,
    String? permissionConfirmDialogOKButton,
    String? callingToolbarMicrophoneButtonText,
    String? callingToolbarMicrophoneOnButtonText,
    String? callingToolbarMicrophoneOffButtonText,
    String? callingToolbarSpeakerButtonText,
    String? callingToolbarSpeakerOnButtonText,
    String? callingToolbarSpeakerOffButtonText,
    String? callingToolbarCameraButtonText,
    String? callingToolbarCameraOnButtonText,
    String? callingToolbarCameraOffButtonText,
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
        outgoingCallPageACancelButton =
            outgoingCallPageACancelButton ?? 'Cancel',
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
            outgoingGroupVoiceCallPageMessage ?? 'Calling...',
        missedCallNotificationTitle =
            missedCallNotificationTitle ?? 'Missed Call',
        missedGroupVideoCallNotificationContent =
            missedGroupVideoCallNotificationContent ?? 'Group Video Call',
        missedGroupAudioCallNotificationContent =
            missedGroupAudioCallNotificationContent ?? 'Group Audio Call',
        missedVideoCallNotificationContent =
            missedVideoCallNotificationContent ?? 'Video Call',
        missedAudioCallNotificationContent =
            missedAudioCallNotificationContent ?? 'Audio Call',
        systemAlertWindowConfirmDialogSubTitle =
            systemAlertWindowConfirmDialogSubTitle ?? 'Display over other apps',
        permissionManuallyConfirmDialogTitle =
            permissionManuallyConfirmDialogTitle ??
                'Please turn on the following permissions to receive call invitations',
        permissionManuallyConfirmDialogSubTitle =
            permissionManuallyConfirmDialogSubTitle ??
                '• Allow auto launch\n'
                    '• Allow notification on Banner and Lock screen\n'
                    '• Allow display over other apps\n'
                    '• Show on lock screen\n'
                    '• Show floating window\n'
                    '• Pop up interface in background\n',
        permissionConfirmDialogTitle =
            permissionConfirmDialogTitle ?? 'Allow $param_1 to',
        permissionConfirmDialogAllowButton =
            permissionConfirmDialogAllowButton ?? 'Allow',
        permissionConfirmDialogDenyButton =
            permissionConfirmDialogDenyButton ?? 'Deny',
        permissionConfirmDialogCancelButton =
            permissionConfirmDialogCancelButton ?? 'Cancel',
        permissionConfirmDialogOKButton =
            permissionConfirmDialogOKButton ?? 'OK',
        callingToolbarMicrophoneButtonText =
            callingToolbarMicrophoneButtonText ?? 'Microphone',
        callingToolbarMicrophoneOnButtonText =
            callingToolbarMicrophoneOnButtonText ?? 'Microphone ON',
        callingToolbarMicrophoneOffButtonText =
            callingToolbarMicrophoneOffButtonText ?? 'Microphone OFF',
        callingToolbarSpeakerButtonText =
            callingToolbarSpeakerButtonText ?? 'Speaker',
        callingToolbarSpeakerOnButtonText =
            callingToolbarSpeakerOnButtonText ?? 'Speaker ON',
        callingToolbarSpeakerOffButtonText =
            callingToolbarSpeakerOffButtonText ?? 'Speaker OFF',
        callingToolbarCameraButtonText =
            callingToolbarCameraButtonText ?? 'Camera',
        callingToolbarCameraOnButtonText =
            callingToolbarCameraOnButtonText ?? 'Camera ON',
        callingToolbarCameraOffButtonText =
            callingToolbarCameraOffButtonText ?? 'Camera OFF';

  /// if add a new text, need check [ZegoCallInvitationInnerTextForCallInvitationServicePrivate]
}

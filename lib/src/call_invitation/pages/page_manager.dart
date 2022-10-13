// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/call_invitation/internal/internal.dart';
import 'calling_machine.dart';
import 'invitation_notify.dart';

typedef ContextQuery = BuildContext Function();

class ZegoInvitationPageManager {
  factory ZegoInvitationPageManager() => instance;
  static final ZegoInvitationPageManager instance =
      ZegoInvitationPageManager._internal();

  ZegoInvitationPageManager._internal();

  String defaultPackagePrefix = 'packages/zego_uikit_prebuilt_call/';

  late int appID;
  late String appSign;
  late String userID;
  late String userName;
  late String tokenServerUrl;
  late ConfigQuery configQuery;
  late ContextQuery
      contextQuery; // we need a context object, to push/pop page when receive invitation request

  var callerRingtone = ZegoRingtone();
  var calleeRingtone = ZegoRingtone();

  late ZegoCallingMachine callingMachine;
  bool invitationTopSheetVisibility = false;
  List<StreamSubscription<dynamic>> streamSubscriptions = [];

  ZegoCallInvitationData invitationData = ZegoCallInvitationData.empty();
  List<ZegoUIKitUser> invitingInvitees = []; //  only change by inviter
  List<ZegoUIKitUser> inviteErrorInvitees = []; //  only change by inviter
  List<ZegoUIKitUser> refuseInvitees = [];
  List<ZegoUIKitUser> timeoutInvitees = [];

  bool get isGroupCall => invitationData.invitees.length > 1;

  Future<void> init({
    required int appID,
    String appSign = '',
    String tokenServerUrl = '',
    required String userID,
    required String userName,
    required ConfigQuery configQuery,
    required ContextQuery contextQuery,
    required ZegoRingtoneConfig ringtoneConfig,
  }) async {
    this.appID = appID;
    this.appSign = appSign;
    this.userID = userID;
    this.userName = userName;
    this.configQuery = configQuery;
    this.tokenServerUrl = tokenServerUrl;
    this.contextQuery = contextQuery;

    listenStream();

    callingMachine = ZegoCallingMachine();
    callingMachine.init();

    initRing(ringtoneConfig);

    debugPrint(
        'init, appID:$appID, appSign:$appSign, tokenServerUrl:$tokenServerUrl, userID:$userID, userName:$userName');
  }

  void uninit() {
    removeStreamListener();
  }

  void initRing(ZegoRingtoneConfig ringtoneConfig) {
    if (ringtoneConfig.callerPath != null) {
      debugPrint("reset caller ring, source path:${ringtoneConfig.callerPath}");
      callerRingtone.init(
        prefix: "",
        sourcePath: ringtoneConfig.callerPath!,
        isVibrate: false,
      );
    } else {
      callerRingtone.init(
        prefix: defaultPackagePrefix,
        sourcePath: "assets/invitation/audio/outgoing.mp3",
        isVibrate: false,
      );
    }
    if (ringtoneConfig.calleePath != null) {
      debugPrint("reset callee ring, source path:${ringtoneConfig.calleePath}");
      calleeRingtone.init(
        prefix: "",
        sourcePath: ringtoneConfig.calleePath!,
        isVibrate: true,
      );
    } else {
      calleeRingtone.init(
        prefix: defaultPackagePrefix,
        sourcePath: "assets/invitation/audio/incoming.mp3",
        isVibrate: true,
      );
    }
  }

  void listenStream() {
    // check plugin installed

    streamSubscriptions
      ..add(ZegoUIKitInvitationService()
          .getInvitationReceivedStream()
          .listen(onInvitationReceived))
      ..add(ZegoUIKitInvitationService()
          .getInvitationAcceptedStream()
          .listen(onInvitationAccepted))
      ..add(ZegoUIKitInvitationService()
          .getInvitationTimeoutStream()
          .listen(onInvitationTimeout))
      ..add(ZegoUIKitInvitationService()
          .getInvitationResponseTimeoutStream()
          .listen(onInvitationResponseTimeout))
      ..add(ZegoUIKitInvitationService()
          .getInvitationRefusedStream()
          .listen(onInvitationRefused))
      ..add(ZegoUIKitInvitationService()
          .getInvitationCanceledStream()
          .listen(onInvitationCanceled));
  }

  void removeStreamListener() {
    for (var streamSubscription in streamSubscriptions) {
      streamSubscription.cancel();
    }
  }

  void onLocalSendInvitation(
    String callID,
    List<ZegoUIKitUser> invitees,
    ZegoInvitationType invitationType,
    List<String> errorInvitees,
  ) {
    inviteErrorInvitees =
        errorInvitees.map((userID) => ZegoUIKit().getUser(userID)).toList();

    invitingInvitees = List.from(invitees);
    invitingInvitees
        .removeWhere((invitee) => errorInvitees.contains(invitee.id));

    invitationData.callID = callID;
    invitationData.inviter = ZegoUIKit().getLocalUser();
    invitationData.invitees = List.from(invitees);
    invitationData.type = invitationType;

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    if (invitingInvitees.isNotEmpty) {
      callerRingtone.startRing();

      if (isGroupCall) {
        /// group call, enter room directly
        callingMachine.stateOnlineAudioVideo.enter();
      } else {
        /// single call
        if (ZegoInvitationType.voiceCall == invitationData.type) {
          callingMachine.stateCallingWithVoice.enter();
        } else {
          if (configQuery(invitationData).turnOnCameraWhenJoining) {
            ZegoUIKit.instance.turnCameraOn(true);
          }

          callingMachine.stateCallingWithVideo.enter();
        }
      }
    } else {
      restoreToIdle();
    }
  }

  void onLocalAcceptInvitation() {
    debugPrint("local accept invitation");

    calleeRingtone.stopRing();

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    callingMachine.stateOnlineAudioVideo.enter();
  }

  void onLocalRefuseInvitation() {
    debugPrint("local refuse invitation");
    restoreToIdle();
  }

  void onLocalCancelInvitation() {
    debugPrint("local cancel invitation");

    invitingInvitees.clear();

    restoreToIdle();
  }

  void onInvitationReceived(Map params) {
    ZegoUIKitUser inviter = params['inviter']!;
    int type = params['type']!; // call type
    String data = params['data']!; // extended field

    debugPrint(
        "on invitation received, data:${inviter.toString()}, $type $data");

    if (CallingState.kIdle != callingMachine.getPageState()) {
      debugPrint("auto refuse this call, because call state is not idle, "
          "current state is ${callingMachine.getPageState()}");

      ZegoUIKitInvitationService().refuseInvitation(inviter.id, '');

      return;
    }

    calleeRingtone.startRing();

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    var invitationInternalData = InvitationInternalData.fromJson(data);
    invitationData.customData = invitationInternalData.customData;
    invitationData.callID = invitationInternalData.callID;
    invitationData.invitees = List.from(invitationInternalData.invitees);
    invitationData.inviter = ZegoUIKitUser(id: inviter.id, name: inviter.name);
    invitationData.type =
        ZegoInvitationTypeExtension.mapValue[type] as ZegoInvitationType;

    showInvitationTopSheet();
  }

  void onInvitationAccepted(Map params) {
    ZegoUIKitUser invitee = params['invitee']!;
    String data = params['data']!; // extended field

    debugPrint("on invitation accepted, data:${invitee.toString()}, $data");

    var inviteeIndex =
        invitingInvitees.indexWhere((_invitee) => _invitee.id == invitee.id);
    if (-1 == inviteeIndex) {
      debugPrint("invitation accepted, but invitee is not in list, "
          "invitee:{${invitee.id}, ${invitee.name}}, "
          "list:$invitingInvitees");
      return;
    }

    invitingInvitees.removeAt(inviteeIndex);

    callerRingtone.stopRing();

    //  if inputting right now
    FocusManager.instance.primaryFocus?.unfocus();

    callingMachine.stateOnlineAudioVideo.enter();
  }

  void onInvitationTimeout(Map params) {
    ZegoUIKitUser inviter = params['inviter']!;
    String data = params['data']!; // extended field

    debugPrint("on invitation timeout, data:${inviter.toString()}, $data");

    invitingInvitees.clear();

    restoreToIdle();
  }

  void onInvitationResponseTimeout(Map params) {
    List<ZegoUIKitUser> invitees = params['invitees']!;
    String data = params['data']!; // extended field

    debugPrint(
        "on invitation response timeout, data:${invitees.map((e) => e.toString())}, $data");

    for (var timeoutInvitee in invitees) {
      invitingInvitees
          .removeWhere((invitee) => timeoutInvitee.id == invitee.id);
    }

    if (isGroupCall) {
      timeoutInvitees.addAll(invitees);
      debugPrint("timeout invitees: $timeoutInvitees");
      var realInviteeCount =
          invitationData.invitees.length - inviteErrorInvitees.length;
      if (timeoutInvitees.length >= realInviteeCount) {
        debugPrint("invitation timeout, all invitee timeout");

        restoreToIdle();
      }
    } else {
      restoreToIdle();
    }
  }

  void onInvitationRefused(Map params) {
    ZegoUIKitUser invitee = params['invitee']!;
    String data = params['data']!; // extended field

    debugPrint("on invitation refused, data:${invitee.toString()}, $data");

    var inviteeIndex =
        invitingInvitees.indexWhere((_invitee) => _invitee.id == invitee.id);
    if (-1 == inviteeIndex) {
      debugPrint("invitation refused, but invitee is not in list, "
          "invitee:{${invitee.id}, ${invitee.name}}, "
          "list:$invitingInvitees");
      return;
    }

    invitingInvitees.removeAt(inviteeIndex);

    if (isGroupCall) {
      refuseInvitees.add(invitee);
      debugPrint(
          "invitation refuse, invitee:$invitee, now have:$refuseInvitees");
      var realInviteeCount =
          invitationData.invitees.length - inviteErrorInvitees.length;
      if (refuseInvitees.length >= realInviteeCount) {
        debugPrint("invitation refuse, all refuse");

        restoreToIdle();
      }
    } else {
      restoreToIdle();
    }
  }

  void onInvitationCanceled(Map params) {
    ZegoUIKitUser inviter = params['inviter']!;
    String data = params['data']!; // extended field

    debugPrint("on invitation canceled, data:${inviter.toString()}, $data");

    restoreToIdle();
  }

  void onHangUp() {
    debugPrint("on hang up");

    if (callerRingtone.isRingTimerRunning) {
      /// still nobody accept this call
      ZegoUIKitInvitationService().cancelInvitation(
          invitingInvitees.map((user) => user.id).toList(), '');
    }

    restoreToIdle();
  }

  void onPrebuiltCallPageDispose() {
    debugPrint("prebuilt call page dispose");

    invitingInvitees.clear();

    restoreToIdle(needPop: false);
  }

  void restoreToIdle({bool needPop = true}) {
    debugPrint("invitation page service to be idle");

    callerRingtone.stopRing();
    calleeRingtone.stopRing();

    ZegoUIKit.instance.turnCameraOn(false);

    hideInvitationTopSheet();

    if (CallingState.kIdle !=
        (callingMachine.machine.current?.identifier ?? CallingState.kIdle)) {
      debugPrint(
          'restore to idle, current state:${callingMachine.machine.current?.identifier}');

      if (needPop) {
        Navigator.of(contextQuery()).pop();
      }

      callingMachine.stateIdle.enter();
    }

    invitationData = ZegoCallInvitationData.empty();
    inviteErrorInvitees.clear();
    refuseInvitees.clear();
    timeoutInvitees.clear();
  }

  void onInvitationTopSheetEmptyClicked() {
    hideInvitationTopSheet();

    if (ZegoInvitationType.voiceCall == invitationData.type) {
      callingMachine.stateCallingWithVoice.enter();
    } else {
      callingMachine.stateCallingWithVideo.enter();
    }
  }

  void showInvitationTopSheet() {
    if (invitationTopSheetVisibility) {
      return;
    }

    invitationTopSheetVisibility = true;

    showTopModalSheet(
      contextQuery(),
      GestureDetector(
        onTap: () {
          onInvitationTopSheetEmptyClicked();
        },
        child: ZegoCallInvitationDialog(
          invitationData: invitationData,
          avatarBuilder: configQuery(invitationData).avatarBuilder,
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideInvitationTopSheet() {
    if (invitationTopSheetVisibility) {
      Navigator.of(contextQuery()).pop();

      invitationTopSheetVisibility = false;
    }
  }
}

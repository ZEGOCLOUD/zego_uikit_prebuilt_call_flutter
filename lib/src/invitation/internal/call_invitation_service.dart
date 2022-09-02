// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_call/src/call_config.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/defines.dart';
import 'package:zego_uikit_prebuilt_call/src/invitation/internal/page_service.dart';

typedef ContextQuery = BuildContext Function();
typedef ConfigQuery = ZegoUIKitPrebuiltCallConfig Function(
    ZegoCallInvitationData);

class ZegoCallInvitationService {
  ZegoCallInvitationService._internal();

  factory ZegoCallInvitationService() => instance;
  static final ZegoCallInvitationService instance =
      ZegoCallInvitationService._internal();

  late int appID;
  late String appSign;
  late String userID;
  late String userName;
  late String tokenServerUrl;

  ///
  late ConfigQuery configQuery;

  /// we need a context object, to push/pop page when receive invitation request
  late ContextQuery contextQuery;

  Future<void> init({
    required int appID,
    String appSign = '',
    String tokenServerUrl = '',
    required String userID,
    required String userName,
    required ConfigQuery configQuery,
    required ContextQuery contextQuery,
  }) async {
    this.appID = appID;
    this.appSign = appSign;
    this.userID = userID;
    this.userName = userName;
    this.configQuery = configQuery;
    this.tokenServerUrl = tokenServerUrl;
    this.contextQuery = contextQuery;

    await ZegoUIKit()
        .init(appID: appID, appSign: appSign, tokenServerUrl: tokenServerUrl);
    await ZegoUIKit().loadZIM(appID: appID, appSign: appSign);
    await ZegoUIKit().login(userID, userName);

    ZegoInvitationPageService.instance.init();

    debugPrint(
        'zim init, appID:$appID, appSign:$appSign, tokenServerUrl:$tokenServerUrl, userID:$userID, userName:$userName');
  }

  Future<void> uninit() async {
    debugPrint('zim uninit');

    await ZegoUIKit().logout();
    await ZegoUIKit().unloadZim();
    await ZegoUIKit().uninit();
  }

  Future<void> reLogin(String userID, String userName) async {
    if (this.userID == userID && this.userName == userName) {
      debugPrint("same user, cancel this reLogin");
      return;
    }

    await ZegoUIKit().logout();

    this.userID = userID;
    this.userName = userName;
    await ZegoUIKit().login(userID, userName);
  }
}

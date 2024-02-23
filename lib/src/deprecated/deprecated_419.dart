// Project imports:
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const deprecatedTipsV419 = ', '
    'deprecated since 4.1.9, '
    'will be removed after 4.5.0,'
    'Migrate Guide:https://pub.dev/documentation/zego_uikit_prebuilt_call/latest/topics/Migration_4.x-topic.html#419';

@Deprecated('use ZegoCallMiniOverlayPageState instead$deprecatedTipsV419')
typedef PrebuiltCallMiniOverlayPageState = ZegoCallMiniOverlayPageState;

@Deprecated('use ZegoCallMenuBarButtonName instead$deprecatedTipsV419')
typedef ZegoMenuBarButtonName = ZegoCallMenuBarButtonName;

@Deprecated('use ZegoCallAudioVideoViewConfig instead$deprecatedTipsV419')
typedef ZegoPrebuiltAudioVideoViewConfig = ZegoCallAudioVideoViewConfig;

@Deprecated('use ZegoCallTopMenuBarConfig instead$deprecatedTipsV419')
typedef ZegoTopMenuBarConfig = ZegoCallTopMenuBarConfig;

@Deprecated('use ZegoCallBottomMenuBarConfig instead$deprecatedTipsV419')
typedef ZegoBottomMenuBarConfig = ZegoCallBottomMenuBarConfig;

@Deprecated('use ZegoCallMemberListConfig instead$deprecatedTipsV419')
typedef ZegoMemberListConfig = ZegoCallMemberListConfig;

@Deprecated('use ZegoCallInRoomChatViewConfig instead$deprecatedTipsV419')
typedef ZegoInRoomChatViewConfig = ZegoCallInRoomChatViewConfig;

@Deprecated('use ZegoCallHangUpConfirmDialogInfo instead$deprecatedTipsV419')
typedef ZegoHangUpConfirmDialogInfo = ZegoCallHangUpConfirmDialogInfo;

extension ZegoUIKitPrebuiltCallConfigDeprecated on ZegoUIKitPrebuiltCallConfig {
  @Deprecated('use video instead$deprecatedTipsV419')
  ZegoUIKitVideoConfig get videoConfig => video;

  @Deprecated('use video instead$deprecatedTipsV419')
  set videoConfig(ZegoUIKitVideoConfig value) => video = value;

  @Deprecated('use audioVideoView instead$deprecatedTipsV419')
  ZegoPrebuiltAudioVideoViewConfig get audioVideoViewConfig => audioVideoView;

  @Deprecated('use audioVideoView instead$deprecatedTipsV419')
  set audioVideoViewConfig(ZegoPrebuiltAudioVideoViewConfig value) =>
      audioVideoView = value;

  @Deprecated('use topMenuBar instead$deprecatedTipsV419')
  ZegoTopMenuBarConfig get topMenuBarConfig => topMenuBar;

  @Deprecated('use topMenuBar instead$deprecatedTipsV419')
  set topMenuBarConfig(ZegoTopMenuBarConfig value) => topMenuBar = value;

  @Deprecated('use bottomMenuBar instead$deprecatedTipsV419')
  ZegoBottomMenuBarConfig get bottomMenuBarConfig => bottomMenuBar;

  @Deprecated('use bottomMenuBar instead$deprecatedTipsV419')
  set bottomMenuBarConfig(ZegoBottomMenuBarConfig value) =>
      bottomMenuBar = value;

  @Deprecated('use memberList instead$deprecatedTipsV419')
  ZegoMemberListConfig get memberListConfig => memberList;

  @Deprecated('use memberList instead$deprecatedTipsV419')
  set memberListConfig(ZegoMemberListConfig value) => memberList = value;

  @Deprecated('use beauty instead$deprecatedTipsV419')
  ZegoBeautyPluginConfig? get beautyConfig => beauty;

  @Deprecated('use beauty instead$deprecatedTipsV419')
  set beautyConfig(ZegoBeautyPluginConfig? value) => beauty = value;

  @Deprecated('use chatView instead$deprecatedTipsV419')
  ZegoInRoomChatViewConfig get chatViewConfig => chatView;

  @Deprecated('use chatView instead$deprecatedTipsV419')
  set chatViewConfig(ZegoInRoomChatViewConfig value) => chatView = value;
}

extension ZegoUIKitPrebuiltCallConfigParameterDeprecated
    on ZegoUIKitPrebuiltCallConfig {
  @Deprecated('use audioVideoView.containerBuilder instead$deprecatedTipsV419')
  ZegoCallAudioVideoContainerBuilder? get audioVideoContainerBuilder =>
      audioVideoView.containerBuilder;

  @Deprecated('use audioVideoView.containerBuilder instead$deprecatedTipsV419')
  set audioVideoContainerBuilder(ZegoCallAudioVideoContainerBuilder? value) =>
      audioVideoView.containerBuilder = value;
}
